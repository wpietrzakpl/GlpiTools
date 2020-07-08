<#
.SYNOPSIS
    Function will update ticket in GLPI
.DESCRIPTION
    This will update existing ticket

.PARAMETER ticket_id
    The id of the ticket that will be updated

.PARAMETER name
    Provide the name/subject of the new ticket

.PARAMETER content
    Provide the body/content of the new ticket

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

.PARAMETER technician_id
    Specify the id of the technician

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
    PS C:\> Update-GlpiToolsTicket -ticket_id 123 -Priority High -Impact Low
    Example updates a incident ticket with High Priority and low Impact

.EXAMPLE
    PS C:\> Update-GlpiToolsTicket -ticket_id 123 -Name 'New ticket subject' -Content 'Ticket text'
    Example updates a incident ticket and associates changes subject and body

.EXAMPLE
    PS C:\> Update-GlpiToolsTicket -ticket_id 123 -Type Request -ApprovalRequired 
    Example changes a incident ticket to request ticket waiting on validation

.OUTPUTS
    Function returns PSCustomObject with id's and messages from the GLPI API
.NOTES
    Author:     Ron Peeters 
    Date:       20200708
    Version:    1.0.0
#>

function Update-GlpiToolsTicket {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [alias('TID')]
        [int]$ticket_id,

        [parameter(Mandatory = $false)]
        [alias('Subject')]
        [string]$name,
        
        [parameter(Mandatory = $false)]
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

        [parameter(Mandatory = $false)]
        [ValidateSet("New", "Pending", "Solved")]
        [string]$status,
        
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
        
        # [parameter(Mandatory = $false,
        #     ParameterSetName = "Request")]
        # [switch]$Request,

        # [parameter(Mandatory = $false,
        #     ParameterSetName = "Request")]
        # [int]$requesttypes_id,

        [parameter(Mandatory = $false)]
        [ValidateSet( "None", "Waiting", "Refused", "Granted")]
        [string]$Validation,

        
        [parameter(Mandatory = $false)]
        [int]$technician_id,

        [parameter(Mandatory = $false)]
        [int]$requester_id

    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        #$ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        switch ($Validation) {
            "None" { $validation_id = 1 }
            "Waiting" { $validation_id = 2 }
            "Refused" { $validation_id = 4 }
            "Granted" { $validation_id = 3 }
            Default { $validation_id = 1 }
        }
        switch ($status) {
            "New" { $status_id = 1 }
            "Pending" { $status_id = 4 }
            "Solved" { $status_id = 5 }
            Default { $status_id = 1 }
        }

        switch ($Type) {
            "Incident" { $type_id = 1 }
            "Request" { $type_id = 2 }
        }

        $Output = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {

        $hashNewTicket = @{
        }

        If ($PSBoundParameters['Type']) {
            $hashNewTicket["type"] = $type_id
        }

        If ($PSBoundParameters['Status']) {
            $hashNewTicket["status"] = $status_id
        }
        If ($Validation -and $PSBoundParameters['Validation']) {
            $hashNewTicket["global_validation"] = $validation_id
        }
        If ($PSBoundParameters['requester_id']) {
            $hashNewTicket["_users_id_requester"] = $requester_id
        }
        If ($PSBoundParameters['technician_id']) {
            $hashNewTicket["technician"] = $technician_id #3031 # The ID of the GLPI SelfServicePortal User account
        }
        If ($PSBoundParameters['itilcategories_id']) {
            $hashNewTicket["itilcategories_id"] = $itilcategories_id
        }
        If ($PSBoundParameters['name']) {
            $hashNewTicket["name"] = $name 
        }
        If ($PSBoundParameters['content']) {
            $hashNewTicket["content"] = $content 
        }

        $GlpiUpload = $hashNewTicket | ConvertTo-Json
        $Upload = '{ "input" : ' + $GlpiUpload + '}'

        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'put'
            uri     = "$($PathToGlpi)/Ticket/$($ticket_id)"
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

            Write-Verbose "Updated ticket. Change ID $($GLPITicket.id)"



        } Catch {
            Write-Error -Message "Unable to update ticket."
            Write-Error $_
        }
    }
    
    end {
        $Output
        $Output = [System.Collections.Generic.List[PSObject]]::New()
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}

# $ItemTypeValidate = {
#     param ($commandName, $parameterName, $stringMatch)
#     $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
#     (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
# }
# Register-ArgumentCompleter -CommandName Update-GlpiToolsTicket -ParameterName item_type -ScriptBlock $ItemTypeValidate