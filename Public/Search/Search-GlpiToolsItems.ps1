<#
.SYNOPSIS
    Function is using GLPI Search Engine to get informations.
.DESCRIPTION
    Function is using GLPI Search Engine to get informations about:
    
    - Computer
    - Monitor
    - Software
    - NetworkEquipment
    - Peripheral
    - Printer
    - CartridgeItem
    - ConsumableItem
    - Phone
    - Rack
    - Enclosure
    - Pdu
    - User
    
    Based on his names.
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    PSP 02/2019
#>

function Search-GlpiToolsItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
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
            "Pdu",
            "Users",
            "Group")]
        [String]$SearchFor,
        [parameter(Mandatory = $true)]
        [ValidateSet("contains",
            "equals",
            "notequals",
            "lessthan",
            "morethan",
            "under",
            "notunder")]
        [String]$SearchType,
        [parameter(Mandatory = $true)]
        [String[]]$SearchValue

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
        foreach ($Value in $SearchValue) {
            $params = @{
                headers = @{
                    'Content-Type'  = 'application/json'
                    'App-Token'     = $AppToken
                    'Session-Token' = $SessionToken
                }
                method  = 'get'
                uri     = "$($PathToGlpi)/search/$($SearchFor)?\is_deleted=0&as_map=0&criteria[0][field]=1&criteria[0][searchtype]=$($SearchType)&criteria[0][value]=$($Value)&search=Search&itemtype=Computer&range=0-9999999999999"
            }
            
            $SearchResult = Invoke-RestMethod @params
        }
        $SearchResult
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}