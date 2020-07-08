<#
.SYNOPSIS
    Function is creating new ticket in GLPI
.DESCRIPTION
    This will create new ticket
    Returns object with property's of new Ticket

    Parameter which you can use with TicketId Parameter. 
    If you want to get additional parameter of Ticket object like, disks, or logs, use this parameter.
.PARAMETER name
Provide the name/subject of the new ticket
.PARAMETER content
Provide the body/content of the new ticket
.PARAMETER itilcategories_id
Provide the ID of the itil category
.PARAMETER requesttypes_id
Provide the ID of the request type
.PARAMETER urgency
Specify the ID of the urgency
.PARAMETER impact
SPecifiy the ID of the impact
.PARAMETER priority
Specify the ID of the priority
.PARAMETER type
Specify the ticket type
1 = Incident
2 = Request
.PARAMETER technician_id
Specify the id of the technician


.OUTPUTS
    Function returns PSCustomObject with property's of Tickets from GLPI
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
        
        [parameter(Mandatory = $false)]
        [int]$technician_id

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
            "Low" {  $urgency_id = 2 }
            "Medium" {  $urgency_id = 3 }
            "High" {  $urgency_id = 4 }
            "Very High" {  $urgency_id = 5 }
            Default { $urgency_id = 2 }
        }
        switch ($impact) {
            "Very low" { $impact_id = 1 }
            "Low" {  $impact_id = 2 }
            "Medium" {  $impact_id = 3 }
            "High" {  $impact_id = 4 }
            "Very High" {  $impact_id = 5 }
            Default { $impact_id = 2 }
        }
        switch ($priority) {
            "Very low" { $priority_id = 1 }
            "Low" {  $priority_id = 2 }
            "Medium" {  $priority_id = 3 }
            "High" {  $priority_id = 4 }
            "Very High" {  $priority_id = 5 }
            Default { $priority_id = 2 }
        }

        If ($Incident)  { $type_id = 1 }
        ElseIf ($Request)  { $type_id = 2 }
        Else { $type_id = 1 }

    }
    
    process {

        $hashNewTicket = @{
            name              = $name
            content           = $content
            itilcategories_id = $itilcategories_id
            # requesttypes_id   = 4
            # "_itil_requester" = @{"_type" = " 0"}
            urgency           = $urgency_id
            impact            = $impact_id
            priority          = $priority_id
            type              = $type_id
            technician        = $technician_id #3031 # The ID of the GLPI SelfServicePortal User account
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
            $GlpiTicket = Invoke-RestMethod @params -ErrorAction Stop



        } Catch {
            Write-Error $_
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}