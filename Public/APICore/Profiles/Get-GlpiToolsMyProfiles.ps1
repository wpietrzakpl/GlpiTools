<#
.SYNOPSIS
    Function Return all the profiles associated to logged user.
.DESCRIPTION
    Function Return all the profiles associated to logged user.
.EXAMPLE
    PS C:\> Get-GlpiToolsMyProfiles
    Command Return all the profiles associated to logged user.
.INPUTS
    None
.OUTPUTS
    Function returns PSCustomObject with property's of Profiles results from GLPI
.NOTES
    PSP 04/2019
#>

function Get-GlpiToolsMyProfiles {
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

        $ProfileArray = @()
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/getMyProfiles/"
        }
            
        $MyProfiles = Invoke-RestMethod @params

        foreach ($GlpiProfile in $MyProfiles.myprofiles) {
            $ProfileHash = [ordered]@{ }
                    $ProfileProperties = $GlpiProfile.PSObject.Properties | Select-Object -Property Name, Value 
                        
                    foreach ($ProfileProp in $ProfileProperties) {
                        $ProfileHash.Add($ProfileProp.Name, $ProfileProp.Value)
                    }
                    $object = [pscustomobject]$ProfileHash
                    $ProfileArray += $object 
        }
        $ProfileArray
        $ProfileArray = @()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}