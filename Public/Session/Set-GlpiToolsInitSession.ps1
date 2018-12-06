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

function Set-GlpiToolsInitSession {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        . .\Get-GlpiToolsConfig.ps1

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $UserToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty UserToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "user_token $($UserToken)"
                'App-Token'     = $AppToken 
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/initSession/" 
        }
        $InitSession = Invoke-RestMethod @params
        
        $object = New-Object -TypeName PSCustomObject
        $object | Add-Member -Name 'SessionToken' -MemberType NoteProperty -Value $InitSession.session_token
        $SessionToken += $object
    }
    
    end {
        $SessionToken
    }
}