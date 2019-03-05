<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    PSP 03/2019
#>

function Get-GlpiToolsListSearchOptions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "Assets")]
        [ValidateSet("Computer",
            "Monitor",
            "Software",
            "NetworkEquipment",
            "Peripheral",
            "Printer",
            "CartridgeItem",
            "ConsumableItem",
            "Phone",
            "Rack",
            "Enclosure",
            "Pdu")]
        [String]$ListOptionsForAssets,

        [parameter(Mandatory = $false,
            ParameterSetName = "Assistance")]
        [ValidateSet("Ticket",
            "Problem",
            "Change",
            "Ticketrecurrent",
            "Softwarelicense",
            "Supplier",
            "Budget",
            "Users",
            "Group")]
        [String]$ListOptionsForAssistance,

        [parameter(Mandatory = $false, ParameterSetName = "Management")]
        [ValidateSet("Softwarelicense",
            "Budget",
            "Supplier",
            "Contact",
            "Contract",
            "Document",
            "Line",
            "Certificate",
            "Datacenter")]
        [String]$ListOptionsForManagement,

        [parameter(Mandatory = $false,
            ParameterSetName = "Tools")]
        [ValidateSet("Project",
            "Reminder",
            "Rssfeed",
            "Knowbaseitem",
            "Reservationitem",
            "Report",
            "Savedsearch")]
        [String]$ListOptionsForTools,

        [parameter(Mandatory = $false,
            ParameterSetName = "Administration")]
        [ValidateSet("User",
            "Group",
            "Entity",
            "Rule",
            "Profile",
            "Queuednotification",
            "Savedsearch")]
        [String]$ListOptionsForAdministration,

        [parameter(Mandatory = $false,
            ParameterSetName = "Setup")]
        [ValidateSet("Slm",
            "Fieldunicity",
            "Crontask",
            "Mailcollector",
            "Link",
            "Plugin")]
            # here add from dropdowns and more
        [String]$ListOptionsForSetup
    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
    }
    
    process {

    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}