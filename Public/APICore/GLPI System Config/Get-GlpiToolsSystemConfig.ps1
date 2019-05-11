<#
.SYNOPSIS
    Function Return the current $CFG_GLPI.
.DESCRIPTION
    Function Return the current $CFG_GLPI.
.EXAMPLE
    PS C:\> Get-GlpiToolsSystemConfig
    Example will show current cfg_glpi configuration.
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsSystemConfig {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/getGlpiConfig/"
        }
            
        $GlpiConfig = Invoke-RestMethod @params

        $GlpiConfig.cfg_glpi
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}