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

function Set-GlpiInitSession {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        # one place to get config path
        $SessionToken = @()
        $ConfigFile = "Configuration.json"
        $ConfigPath = "$env:LOCALAPPDATA\GlpiConfig\"
        $Config = Join-Path -Path $ConfigPath -ChildPath $ConfigFile

        # create function for this 
        if (Test-Path -Path $Config) {
            $ConfigData = Get-Content $Config | ConvertFrom-Json

            $AppTokenSS = ConvertTo-SecureString $ConfigData.AppToken
            $UserTokenSS = ConvertTo-SecureString $ConfigData.UserToken
            $PathToGlpiSS = ConvertTo-SecureString $ConfigData.PathToGlpi

            $AppTokenDecrypt = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AppTokenSS))
            $UserTokenDecrypt = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($UserTokenSS))
            $PathToGlpiDecrypt = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($PathToGlpiSS))
        } else {
            Write-Verbose -Message "I cannot find Config File, check if you used Set-GlpiConfig to generate Config"
            exit 1
        }
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "user_token $($UserTokenDecrypt)"
                'App-Token'     = $AppTokenDecrypt 
            }
            method  = 'get'
            uri     = "$($PathToGlpiDecrypt)/initSession/" 
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