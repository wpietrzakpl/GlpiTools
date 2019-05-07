<#
.SYNOPSIS
    Set GLPI Configuration File.
.DESCRIPTION
    This function preparing config file for GLPI API.
.PARAMETER AppToken
    Application Token, you can find Token in API Settings at your GLPI website.
.PARAMETER UserToken
    User Token, you can find inside user account settings.
.PARAMETER PathToGlpi
    Path To GLPI, you can find the path in API Settings at your GLPI website.
.EXAMPLE
    PS C:\Users\Wojtek> Set-GlpiToolsConfig -AppToken 'dsahu2uh2uh32gt43tf434t' -UserToken 'sdasg3123hg3t1ftf21t3' -PathToGlpi 'http://pathtoglpi/glpi'
    This example show how to set GLPI config file
.INPUTS
    None, you cannot pipe objects to Set-GlpiToolsConfig
.OUTPUTS
    None
.NOTES
    PSP 12/2018
#>

function Set-GlpiToolsConfig {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$AppToken,
        [parameter(Mandatory = $true)]
        [string]$UserToken,
        [parameter(Mandatory = $true)]
        [string]$PathToGlpi
    )
    
    begin {

        if ($IsLinux) {
            $ConfigFile = "Configuration.json"
            $ConfigPath = "$env:HOME/.config/GlpiToolsConfig\"
            $Config = Join-Path -Path $ConfigPath -ChildPath $ConfigFile
        } else {
            $ConfigFile = "Configuration.json"
            $ConfigPath = "$env:LOCALAPPDATA\GlpiToolsConfig\"
            $Config = Join-Path -Path $ConfigPath -ChildPath $ConfigFile
        }

        if (!(Test-Path $ConfigPath)) {
            New-Item -Path $ConfigPath -ItemType Directory | Out-Null
        } else {
            try {
                Remove-Item -Path $Config -ErrorAction Stop    
            } catch {
                
            }
        }
    }

    process {
        $AppTokenSS = ConvertTo-SecureString -String $AppToken -AsPlainText -Force 
        $UserTokenSS = ConvertTo-SecureString -String $UserToken -AsPlainText -Force 
        $PathToGlpiSS = ConvertTo-SecureString -String $PathToGlpi -AsPlainText -Force 
        
        $AppTokenEncrypt = ConvertFrom-SecureString -SecureString $AppTokenSS 
        $UserTokenEncrypt = ConvertFrom-SecureString -SecureString $UserTokenSS 
        $PathToGlpiEncrypt = ConvertFrom-SecureString -SecureString $PathToGlpiSS 
    }
    
    end {
        $ConfigHash = [ordered]@{
            'AppToken'   = $AppTokenEncrypt
            'UserToken'  = $UserTokenEncrypt
            'PathToGlpi' = $PathToGlpiEncrypt
        }
        $ConfigHash | ConvertTo-Json | Out-File -FilePath $Config
    }
}