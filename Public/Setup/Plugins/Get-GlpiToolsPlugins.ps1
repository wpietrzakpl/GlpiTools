<#
.SYNOPSIS
    Function to get GLPI Plugin list.
.DESCRIPTION
    Function is getting Plugin list from GLPI.
    You can choose for Raw list, or list with translated status.
.PARAMETER Raw
    Switch parameter, you can use this parameter to get raw Plugin list.
    Raw I mean, as that as it is from original object from GLPI.
.EXAMPLE
    PS C:\> Get-GlpiToolsPlugins
    Gets Plugin list from GLPI, with translated status from number to Enabled etc...
.EXAMPLE
    PS C:\> Get-GlpiToolsPlugins -Raw
    Gets Plugin list from GLPI, object isn't translated. Original as it comes from GLPI. 
.INPUTS
    None
.OUTPUTS
    Function returns PSCustomObject with property's of Plugins from GLPI
.NOTES
    PSP 04/2019
#>

function Get-GlpiToolsPlugins {
    [CmdletBinding()]
    param (
        [Switch]$Raw
    )
    
    begin {
        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
    
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $PluginsArray = @()

    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/Plugin/" 
        }
        $Plugins = Invoke-RestMethod @params

        if ($Raw) {
            foreach ($Plugin in $Plugins) {
                $PluginHash = [ordered]@{ }
                $PluginProperties = $Plugin.PSObject.Properties | Select-Object -Property Name, Value 
                
                foreach ($PluginProp in $PluginProperties) {
                    $PluginHash.Add($PluginProp.Name, $PluginProp.Value)
                }
                $object = [pscustomobject]$PluginHash
                $PluginsArray += $object 
            }
        }
        else {
            foreach ($Plugin in $Plugins) {
                $PluginHash = [ordered]@{ }
                $PluginProperties = $Plugin.PSObject.Properties | Select-Object -Property Name, Value 
                
                foreach ($PluginProp in $PluginProperties) {
                
                    if (($PluginProp.Name -eq "state") -and ($PluginProp.Value -eq "1")) {
                        $StateResolved = "Enabled"
                        $PluginHash.Add($PluginProp.Name, $StateResolved) 
                    }
                    elseif (($PluginProp.Name -eq "state") -and ($PluginProp.Value -eq "4")) {
                        $StateResolved = "Installed / not activated"
                        $PluginHash.Add($PluginProp.Name, $StateResolved)
                    }
                    elseif (($PluginProp.Name -eq "state") -and ($PluginProp.Value -eq "2")) {
                        $StateResolved = "Not installed"
                        $PluginHash.Add($PluginProp.Name, $StateResolved)
                    }
                    else {
                        $PluginHash.Add($PluginProp.Name, $PluginProp.Value)
                    }
                    
                }
                $object = [pscustomobject]$PluginHash
                $PluginsArray += $object 
            }
        }

        $PluginsArray
        $PluginsArray = @()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}