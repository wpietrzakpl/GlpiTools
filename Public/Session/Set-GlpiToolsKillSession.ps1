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
    Wojtek 12/2018
#>

function Set-GlpiToolsKillSession {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        [string]$SessionToken
    )
    
    begin {
        . .\Get-GlpiToolsConfig.ps1

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
            uri     = "$($PathToGlpi)/killSession/" 
        }
        Invoke-RestMethod @params | Out-Null
    }
    
    end {
    }
}