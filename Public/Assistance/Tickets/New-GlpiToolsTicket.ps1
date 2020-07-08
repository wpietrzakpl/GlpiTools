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

function New-GlpiToolsTicket {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [alias('Subject')]
        [string]$name,
        
        [parameter(Mandatory = $true)]
        [alias('Body')]
        [string]$content,
        
        [parameter(Mandatory = $false)]
        [int]$itilcategories_id,
        
        [parameter(Mandatory = $false)]
        [ValidateSet("Very low", "Low", "Medium", "High", "Very High")]
        [string]$urgency = "Low",
        
        [parameter(Mandatory = $false)]
        [ValidateSet("Very low", "Low", "Medium", "High", "Very High")]
        [string]$impact = "Low",
        
        [parameter(Mandatory = $false)]
        [ValidateSet("Very low", "Low", "Medium", "High", "Very High")]
        [string]$priority = "Low",
        
        # [parameter(Mandatory = $false,
        #     ParameterSetName = "Default")]
        #     [ValidateSet("Incident", "Request")]
        # [string]$type = "Incident",

        [parameter(Mandatory = $true,
            ParameterSetName = "Incident")]
        [switch]$Incident,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "Request")]
        [switch]$Request,

        [parameter(Mandatory = $false,
            ParameterSetName = "Request")]
        [int]$requesttypes_id,

        [parameter(Mandatory = $false,
        ParameterSetName = "Request")]
        [switch]$ValidationNeeded,

        [parameter(Mandatory = $false)]
        [int]$item_id = $null,

        [parameter(Mandatory = $false)]
        [ValidateScript({
            $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
            $Values = (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents
            If ($Values -notcontains $_) {
                Write-Warning -Message "Invalid item type specified. Possible values for item_type are:  $Values"
                throw "Invalid item type specified."
                
            } else {
                $true
            }
        })]
        [string]$item_type = $null,
        
        [parameter(Mandatory = $false)]
        [int]$technician_id,

        [parameter(Mandatory = $false)]
        [int]$requester_id = 2

    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        switch ($urgency) {
            "Very low" { $urgency_id = 1 }
            "Low" { $urgency_id = 2 }
            "Medium" { $urgency_id = 3 }
            "High" { $urgency_id = 4 }
            "Very High" { $urgency_id = 5 }
            Default { $urgency_id = 2 }
        }
        switch ($impact) {
            "Very low" { $impact_id = 1 }
            "Low" { $impact_id = 2 }
            "Medium" { $impact_id = 3 }
            "High" { $impact_id = 4 }
            "Very High" { $impact_id = 5 }
            Default { $impact_id = 2 }
        }
        switch ($priority) {
            "Very low" { $priority_id = 1 }
            "Low" { $priority_id = 2 }
            "Medium" { $priority_id = 3 }
            "High" { $priority_id = 4 }
            "Very High" { $priority_id = 5 }
            Default { $priority_id = 2 }
        }

        If ($Incident) { $type_id = 1 }
        ElseIf ($Request) { $type_id = 2 }
        Else { $type_id = 1 }

        $Output = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {

        $hashNewTicket = @{
            name              = $name
            content           = $content
            urgency           = $urgency_id
            impact            = $impact_id
            priority          = $priority_id
            type              = $type_id
        }

        If ($ValidationNeeded) {
            $hashNewTicket["global_validation"] = 2
        }
        If ($requester_id) {
            $hashNewTicket["_users_id_requester"] = $requester_id
        }
        If ($technician_id) {
            $hashNewTicket["technician"] = $technician_id #3031 # The ID of the GLPI SelfServicePortal User account
        }
        If ($itilcategories_id) {
            $hashNewTicket["itilcategories_id"] = $itilcategories_id
        }

        $GlpiUpload = $hashNewTicket | ConvertTo-Json
        $Upload = '{ "input" : ' + $GlpiUpload + '}'

        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'post'
            uri     = "$($PathToGlpi)/Ticket/"
            body    = ([System.Text.Encoding]::UTF8.GetBytes($Upload))
        }

        Try {
            Write-Verbose "Invoking API to create new ticket"
            $GlpiTicket = Invoke-RestMethod @params -ErrorAction Stop

            If ($GlpiTicket -match "</body>") {
                $GLPITicket = $GlpiTicket.split(">")[-1] | ConvertFrom-JSON
            } else {
                #Do nothing
            }

            $Output.Add($GLPITicket)

            Write-Verbose "New ticket created with ID $($GLPITicket.id)"
            
            If ($Item_id -ne 0) {
               
                Try {
                    Write-Verbose "Invoking API to add Item with id $($Item_id) to newly created ticket"
                    # "items_id":'.$Itemid.',"itemtype":"Item","tickets_id":'.$ticketid.'}

                    $hashAddItemtoTicket = @{
                        items_id   = $item_id
                        itemtype   = $item_type
                        tickets_id = $GlpiTicket.id
                
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
                        uri     = "$($PathToGlpi)/Ticket/$($GlpiTicket.id)/Item_ticket/"
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
                    Write-Error "Unable to add Item to ticket"
                    Write-Error $_
                    # Write-Error ($params.GetEnumerator() | Out-string)
                    # Write-Error $Upload
                }
            }


        } Catch {
            Write-Error -Message "Unable to create new ticket."
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
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
}
Register-ArgumentCompleter -CommandName New-GlpiToolsTicket -ParameterName item_type -ScriptBlock $ItemTypeValidate