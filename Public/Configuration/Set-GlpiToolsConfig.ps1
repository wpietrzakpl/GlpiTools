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

function Set-GlpiToolsConfig {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$AppToken,
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$UserToken,
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$PathToGlpi
    )
    
    begin {
        #TODO
        ## Help!
        ## Code to verify OS 
        # Linux Section 
        ## Code
        # Windows Section
        # Add to module dependecies Install-Module -Name Get-Configuration
        $ConfigFile = "Configuration.json"
        $ConfigPath = "$env:LOCALAPPDATA\GlpiToolsConfig\"
        $Config = Join-Path -Path $ConfigPath -ChildPath $ConfigFile
        

        Set-Configuration -Key GlpiConfPath -Value $Config

        if (!(Test-Path $ConfigPath)) {
            New-Item -Path $ConfigPath -ItemType Directory | Out-Null
        }
        else {
            try {
                Remove-Item -Path $Config -ErrorAction Stop    
            }
            catch {
                
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