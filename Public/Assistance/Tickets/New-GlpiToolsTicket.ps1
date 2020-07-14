<#
.SYNOPSIS
    Function is creating new ticket in GLPI
.DESCRIPTION
    This will create new ticket

.PARAMETER name
    Provide the name/subject of the new ticket

.PARAMETER content
    Provide the body/content of the new ticket

.PARAMETER Type
    Specifies if the ticket will be an Incident or a Request.
    Defaults to Incident

.PARAMETER itilcategories_id
    Provide the ID of the itil category

.PARAMETER urgency
    Specify the urgency.
    Possible values are "Very low", "Low", "Medium", "High" and "Very High"

.PARAMETER impact
    Specify the impact.
    Possible values are "Very low", "Low", "Medium", "High" and "Very High"

.PARAMETER priority
    Specify the priority.
    Possible values are "Very low", "Low", "Medium", "High" and "Very High"

.PARAMETER ApprovalRequired
    Sets the request as waiting for Approval.
    Only valid on type Request

.PARAMETER requester_id
    The user ID that is the requester

.PARAMETER technician_id
    Specify the id of the technician

.PARAMETER DisableNotification
    Disables notification
    Defaults to False

.PARAMETER requesttypes_id
    Provide the ID of the request type
    ***** I need to figure this one out *****

.PARAMETER item_id
    Provide the id of an item to be associated to this ticket
    Requires item_type to be also specified.

.PARAMETER item_type
    The item type that is added.
    These are the default types GLPI provides

.EXAMPLE
    PS C:\> New-GlpiToolsTicket -Name 'New ticket subject' -Content 'Ticket text' -Priority High -Impact Low
    Example creates a incident ticket with High Priority and low Impact

.EXAMPLE
    PS C:\> New-GlpiToolsTicket -Name 'New ticket subject' -Content 'Ticket text' -item_id 4609 -item_type Computer
    Example creates a incident ticket and associates computer 4609

.EXAMPLE
    PS C:\> New-GlpiToolsTicket -Name 'New ticket subject' -Content 'Ticket text' -Type Request -ApprovalRequired -Requester_id 2
    Example creates a request ticket waiting on validation for the user with id 2

.OUTPUTS
    Function returns PSCustomObject with id's and messages from the GLPI API
.NOTES
    Author:     Ron Peeters 
    Date:       20200708
    Version:    1.0.0
#>

function New-GlpiToolsTicket {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "ticket subject")]
        [alias('Subject')]
        [string]$name,
        
        [parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "ticket content")]
        [alias('Body')]
        [string]$content,
        
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "ticket id from GLPI")]
        [int]$itilcategories_id,
        
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Ticket urgency value"
            )]
        [ValidateSet("Very low", "Low", "Medium", "High", "Very High")]
        [string]$urgency = "Low",
        
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Ticket impact value"
            )]
        [ValidateSet("Very low", "Low", "Medium", "High", "Very High")]
        [string]$impact = "Low",
        
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Ticket priority value"
            )]
        [ValidateSet("Very low", "Low", "Medium", "High", "Very High")]
        [string]$priority = "Low",
        
        # [parameter(Mandatory = $false,
        #     ParameterSetName = "Default")]
        #     [ValidateSet("Incident", "Request")]
        # [string]$type = "Incident",
        
        [parameter(Mandatory = $false,
            #ParameterSetName = "Request",
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Ticket type"
        )]
        [ValidateSet("Incident", "Request")]
        [string]$Type = "Incident",

        [parameter(
            Mandatory = $false,
            #ParameterSetName = "Request",
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "request type id"
            )]
        [int]$requesttypes_id,

        [parameter(
            Mandatory = $false,
            #ParameterSetName = "Request",
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Approval required. Defaults to False"
            )]
        [switch]$ApprovalRequired,

        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Item ID to be linked to this new ticket"
        )]
        [int]$item_id = $null,

        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Item type to be added."
            )]
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
        
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "user id of the technician to be assigned"
        )]
        [int]$technician_id,

        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Disables notification"
            )]
        [switch]$DisableNotification = $false,

        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "user id of the requester"
            )]
        [int]$requester_id = 2

    )
    
    begin {

        If ($null -ne $PSBoundParameters['Item_id'] -and $null -eq $PSBoundParameters['Item_type']) {
            Write-Warning "[INVALID PARAMETERS] If item_id is specified, item_type needs to be specified accordingly"
            Exit
        }
        If ($PSBoundParameters['Type'] -ne 'Request' -and $PSBoundParameters['ApprovalRequired']) {
            Write-Warning "[INVALID PARAMETERS] Approval required specified but type is not a request."
            Exit
        }


        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        #$ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

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

        switch ($Type) {
            "Incident" { $type_id = 1 }
            "Request" { $type_id = 2 }
        }


        $Output = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {

        $hashNewTicket = @{
            name              = $name
            content           = $content
            type              = $type_id
        }

        If ($PSBoundParameters['Urgency']) {
            $hashNewTicket["urgency"] = $urgency_id
        }
        If ($PSBoundParameters['Impact']) {
            $hashNewTicket["impact"] = $impact_id
        }
        If ($PSBoundParameters['Priority']) {
            $hashNewTicket["priority"] = $priority_id
        }
        If ($PSBoundParameters['ApprovalRequired']) {
            $hashNewTicket["global_validation"] = 2
        }
        If ($PSBoundParameters['Type'] -eq 'Request' -and $PSBoundParameters['ApprovalRequired']) {
            $hashNewTicket["global_validation"] = 2
        }
        If ($PSBoundParameters['requester_id']) {
            #$hashNewTicket["_users_id_requester"] = $requester_id
            $hashAddRequester = @{
                tickets_id              = $null
                users_id           = $requester_id
                type              = 1 # 1 = requester, 2 = assign, 3 = observer
                use_notification = 1
            }
        }
        If ($PSBoundParameters['technician_id']) {
            $hashNewTicket["technician"] = $technician_id #3031 # The ID of the GLPI SelfServicePortal User account
        }
        If ($PSBoundParameters['itilcategories_id']) {
            $hashNewTicket["itilcategories_id"] = $itilcategories_id
        }
        If ($PSBoundParameters['DisableNotification'] -and $DisableNotification -eq $true) {
            $hashNewTicket["_disablenotif"] = 'true'
            #$hashNewTicket["_users_id_requester_notif[use_notification][0]"] = 0
            #$hashNewTicket["use_notif"] = 0    

            if ($hashAddRequester) {
                $hashAddRequester["use_notification"] = 0
            }
        }

        Write-Verbose ($hashNewTicket | Out-String)

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

            #Adding requester if specified
            If ($PSBoundParameters['requester_id']) {
                $hashAddRequester["tickets_id"] = $GlpiTicket.ID

                Write-Verbose "Invoking API to add requester with ID $requester_id to newly created ticket $($glpiticket.ID)"
                $GlpiUpload = $hashAddRequester | ConvertTo-Json
                    $Upload = '{ "input" : ' + $GlpiUpload + '}'

                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'post'
                        uri     = "$($PathToGlpi)/Ticket/$($GlpiTicket.id)/Ticket_User/"
                        body    = ([System.Text.Encoding]::UTF8.GetBytes($Upload))
                    }

                    $GlpiTicketAddRequester = Invoke-RestMethod @params -ErrorAction Stop
                    Write-Verbose $GlpiTicketAddRequester

            }

            
            If ($PSBoundParameters['Item_id'] -and $PSBoundParameters['Item_type']) {
               
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