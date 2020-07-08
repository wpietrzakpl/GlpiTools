<#
.SYNOPSIS
    Function is creating new ticket in GLPI
.DESCRIPTION
    This will create new ticket
    Returns object with property's of new Ticket

    Parameter which you can use with TicketId Parameter. 
    If you want to get additional parameter of Ticket object like, disks, or logs, use this parameter.
.PARAMETER name
    [REQUIRED] Provide the name/subject of the new ticket
    Alias: Subject
.PARAMETER content
    [REQUIRED] Provide the body/content of the new ticket
    Alias: Body
.PARAMETER itilcategories_id
    Provide the ID of the itil category
.PARAMETER requesttypes_id
    Provide the ID of the request type
.PARAMETER urgency
    Specify the urgency.
    Possible values are "Very low", "Low", "Medium", "High" and "Very High"
.PARAMETER impact
    Specify the impact.
    Possible values are "Very low", "Low", "Medium", "High" and "Very High"
.PARAMETER priority
    Specify the priority.
    Possible values are "Very low", "Low", "Medium", "High" and "Very High"
.PARAMETER Incident
    [REQUIRED] Specify the ticket as Incident
.PARAMETER Request
    [REQUIRED] Specify the ticket as Request

.PARAMETER technician_id
Specify the id of the technician


.OUTPUTS
    Function returns PSCustomObject with id's and messages from the GLPI API
.NOTES
    Ron Peeters 20200708
#>

function Add-GlpiToolsTicketSolution {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [alias('TID')]
        [int]$ticket_id,
        
        [parameter(Mandatory = $true)]
        [alias('Body')]
        [string]$content
 
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys


        $Output = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {

        $hashNewTicket = @{
            # tickets_id         = $ticket_id
            content           = $content
            items_id = $ticket_id
            itemtype = "Ticket"
            solutiontypes_id = 0
            status = 5
            
        }
        #https://forum.glpi-project.org/viewtopic.php?id=159609
        # "items_id": "'.$ticket_id.'",
        #  "content": "OK: . Chamado fechado automaticamente atraves do evento '.$event_id.'",
        #  "solutiontypes_id": 2,
        #  "itemtype": "Ticket",
        # "status": 3
 

        $GlpiUpload = $hashNewTicket | ConvertTo-Json
        $Upload = '{ "input" : ' + $GlpiUpload + '}'

        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'post'
            uri     = "$($PathToGlpi)/Ticket/$($ticket_id)/ITILSolution/"
            body    = ([System.Text.Encoding]::UTF8.GetBytes($Upload))
        }

        Try {
            Write-Verbose "Invoking API to add ticket followup"
            $GlpiTicket = Invoke-RestMethod @params -ErrorAction Stop

            If ($GlpiTicket -match "</body>") {
                $GLPITicket = $GlpiTicket.split(">")[-1] | ConvertFrom-JSON
            } else {
                #Do nothing
            }

            $Output.Add($GLPITicket)

            Write-Verbose "new followup added with ID $($GLPITicket.id)"
            
  


        } Catch {
            Write-Error -Message "Unable to add new ticket followup."
            Write-Error $_
            Write-Error ($params.GetEnumerator() | Out-string)
            Write-Error $Upload
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
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
}
Register-ArgumentCompleter -CommandName Add-GlpiToolsTicketFollowup -ParameterName item_type -ScriptBlock $ItemTypeValidate