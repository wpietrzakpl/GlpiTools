<#
.SYNOPSIS
    Add an item to an existing ticket
.DESCRIPTION
    This function will add an item to an existing ticket.

.PARAMETER ticket_id
    The ticket id this item will be added to

.PARAMETER item_id
    The item id 
    Requires item_type to be specified

.PARAMETER item_type
    The item type that is added.
    These are the default types GLPI provides

.EXAMPLE
    PS C:\> Add-GlpiToolsTicketItem -ticket_id 165 -item_id 4609 -item_type Computer

.EXAMPLE
    PS C:\> Add-GlpiToolsTicketItem -ticket_id 165 -item_id 4609 -item_type NetworkEquipment

.OUTPUTS
    Function returns PSCustomObject with id's and messages from the GLPI API
.NOTES
    Author:     Ron Peeters 
    Date:       20200708
    Version:    1.0.0
#>

function Add-GlpiToolsTicketItem {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "ticket id from GLPI"
        )]
        [alias('TID')]
        [int]$ticket_id,

        [parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "item id from GLPI"
        )]
        [int]$item_id,

        [parameter(
            Mandatory = $true,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "item type specified at item_id"
        )]
        [ValidateScript( {
                $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
                $Values = (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents
                If ($Values -notcontains $_) {
                    Write-Warning -Message "Invalid item type specified. Possible values for item_type are:  $Values"
                    throw "Invalid item type specified."
                
                } else {
                    $true
                }
            })]
        [string]$item_type

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.


    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        #$ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $Output = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {

        Try {
            Write-Verbose "Invoking API to add Item with id $($Item_id) of type $item_type to ticket $ticket_id"
            # "items_id":'.$Itemid.',"itemtype":"Item","tickets_id":'.$ticketid.'}

            $hashAddItemtoTicket = @{
                items_id   = $item_id
                itemtype   = $item_type
                tickets_id = $ticket_id
            
            }
            $GlpiUpload = $hashAddItemtoTicket | ConvertTo-Json
            $Upload = '{ "input" : ' + $GlpiUpload + '}'

            $params = @{
                headers = @{
                    'Content-Type'  = 'application/json'
                    'App-Token'     = $AppToken
                    'Session-Token' = $SessionToken
                }
                method  = 'post'
                uri     = "$($PathToGlpi)/Ticket/$ticket_id/Item_ticket/"
                body    = ([System.Text.Encoding]::UTF8.GetBytes($Upload))
            }

            $GlpiTicketAddItem = Invoke-RestMethod @params -ErrorAction Stop
            Write-Verbose $GlpiTicketAddItem

            If ($GlpiTicketAddItem -match "</body>") {
                $GlpiTicketAddItem = $GlpiTicketAddItem.split(">")[-1] | ConvertFrom-JSON
            } else {
                #Do nothing
            }

            $Output.Add($GlpiTicketAddItem)


        } Catch {
            Write-Error -Message "Unable to add item to ticket."
            Write-Error $_
        }
    }

    end {
        $Output
        $Output = [System.Collections.Generic.List[PSObject]]::New()
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}

$ItemTypeValidate = {
    param ($commandName, $parameterName, $stringMatch)
    $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object { $_ -match "$stringMatch" }
}
Register-ArgumentCompleter -CommandName Add-GlpiToolsTicketItem -ParameterName item_type -ScriptBlock $ItemTypeValidate