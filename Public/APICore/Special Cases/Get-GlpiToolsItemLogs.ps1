<#
.SYNOPSIS
    Function is getting Logs from Items from GLPI
.DESCRIPTION
    Function is based on ItemID which you can find on bookmark of item which you want to get logs.
    Returns object with Logs for specific id of item.
.PARAMETER LogsFor
    Parameter where you have to provide itemtype. You can choose itemtype from list.
.PARAMETER ItemId
    Parameter where you have to provide item id. You can find id in GLPI.
.EXAMPLE
    PS C:\> Get-GlpiToolsItemLogs -LogsFor Computer -ItemId 2
    Exaple will show logs for Computer which id is 2.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsItemLogs -LogsFor Computer
    Exaple will show logs for Computer which id is 2. Id is taken from pipeline.
.INPUTS
    You have to provide itemtype and itemid.
.OUTPUTS
    Function will return pscustomobject.
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsItemLogs {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "Logs")]
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
        [string]$LogsFor,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "Logs")]
        [alias('CID')]
        [int[]]$ItemId

    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $LogObjectArray = [System.Collections.ArrayList]::new()
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/$($LogsFor)/$($ItemId)/Log?range=0-9999999999999"
        }
        
        $GlpiLogAll = Invoke-RestMethod @params -Verbose:$false

        foreach ($GlpiLog in $GlpiLogAll) {
            $LogHash = [ordered]@{ }
                    $LogProperties = $GlpiLog.PSObject.Properties | Select-Object -Property Name, Value 
                        
                    foreach ($LogProp in $LogProperties) {
                        $LogHash.Add($LogProp.Name, $LogProp.Value)
                    }
                    $object = [pscustomobject]$LogHash
                    $LogObjectArray.Add($object)
        }
        $LogObjectArray
        $LogObjectArray = [System.Collections.ArrayList]::new()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}