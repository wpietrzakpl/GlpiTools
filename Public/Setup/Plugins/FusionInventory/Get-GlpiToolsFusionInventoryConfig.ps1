<#
.SYNOPSIS
    Function to show Fusion Config from GLPI
.DESCRIPTION
    Function to show Fusion Config from GLPI
.EXAMPLE
    PS C:\> Get-GlpiToolsFusionInventoryConfig
    Function will show fusion config which are available in GLPI
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsFusionInventoryConfig {
    [CmdletBinding()]
    param (
        
    )
    
    begin {

        $InvocationCommand = $MyInvocation.MyCommand.Name

        if (Check-GlpiToolsPluginExist -InvocationCommand $InvocationCommand) {
            
        } else {
            throw "You don't have this plugin Enabled in GLPI"
        }

        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
    
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $FusionConfigArray = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/PluginFusioninventoryConfig/?range=0-999999999" 
        }
        $AllFusionConfig = Invoke-RestMethod @params

        foreach ($FusionConfig in $AllFusionConfig) {
            $FusionHash = [ordered]@{ }
                    $FusionProperties = $FusionConfig.PSObject.Properties | Select-Object -Property Name, Value 
                        
                    foreach ($FusionProp in $FusionProperties) {
                        $FusionHash.Add($FusionProp.Name, $FusionProp.Value)
                    }
                    $object = [pscustomobject]$FusionHash
                    $FusionConfigArray.Add($object)
        }
        $FusionConfigArray
        $FusionConfigArray = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}
