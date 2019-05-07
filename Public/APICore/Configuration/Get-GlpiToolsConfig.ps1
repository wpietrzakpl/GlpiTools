<#
.SYNOPSIS
    Get GLPI Configuration File.
.DESCRIPTION
    This function getting data inside GLPI config file, to use it with other functions
    and show stored values.
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsConfig
    Running script like that, shows you current config data.
.INPUTS
    None
.OUTPUTS
    Function creates PSCustomObject 
.NOTES
    PSP 12/2018
#>

function Get-GlpiToolsConfig {
    [CmdletBinding()]
    param (
        
    )
    
    begin {

        if ($IsLinux) {
            $GlpiConfig = @()
            $ConfigFile = "Configuration.json"
            $ConfigPath = "$env:HOME/.config/GlpiToolsConfig\"
            $Config = Join-Path -Path $ConfigPath -ChildPath $ConfigFile
        } else {
            $GlpiConfig = @()
            $ConfigFile = "Configuration.json"
            $ConfigPath = "$env:LOCALAPPDATA\GlpiToolsConfig\"
            $Config = Join-Path -Path $ConfigPath -ChildPath $ConfigFile 
        }

    }
    
    process {

        if (Test-Path -Path $Config) {
            $ConfigData = Get-Content $Config | ConvertFrom-Json
        
            $AppTokenSS = ConvertTo-SecureString $ConfigData.AppToken
            $UserTokenSS = ConvertTo-SecureString $ConfigData.UserToken
            $PathToGlpiSS = ConvertTo-SecureString $ConfigData.PathToGlpi
        
            $AppTokenDecrypt = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AppTokenSS))
            $UserTokenDecrypt = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($UserTokenSS))
            $PathToGlpiDecrypt = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($PathToGlpiSS))
            
            $ConfigHash = [ordered]@{
                'AppToken' = $AppTokenDecrypt
                'UserToken' = $UserTokenDecrypt
                'PathToGlpi' = $PathToGlpiDecrypt
            }

            $object = New-Object -TypeName PSCustomObject -Property $ConfigHash
            $GlpiConfig += $object 
            
        }
        else {
            Write-Warning -Message "I cannot find Config File, check if you used Set-GlpiToolsConfig to generate Config"
        }

    }
    
    end {
        $GlpiConfig
    }
}