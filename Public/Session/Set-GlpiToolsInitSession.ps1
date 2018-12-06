<#
.SYNOPSIS
    Function which init API session.
.DESCRIPTION
    Function gets nesessery information from Config file, then initialize session, and return object with session_token property.
.EXAMPLE
    PS C:\Users\Wojtek> Set-GlpiToolsInitSession
    Run command like that and you will initiate session with API GLPI
.INPUTS
    None, inside script Function uses Get-GlpiToolsConfig to get data from Config. 
.OUTPUTS
    SessionToken parameter
.NOTES
    PSP 12/2018
#>

function Set-GlpiToolsInitSession {
    [CmdletBinding()]
    param (
        
    )
    
    begin {

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