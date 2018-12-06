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
        $GlpiConfig = @()
        $Config = Get-Configuration -Key GlpiConfPath
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
            
            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'AppToken' -MemberType NoteProperty -Value $AppTokenDecrypt
            $object | Add-Member -Name 'UserToken' -MemberType NoteProperty -Value $UserTokenDecrypt
            $object | Add-Member -Name 'PathToGlpi' -MemberType NoteProperty -Value $PathToGlpiDecrypt
            $GlpiConfig += $object 
            
            $GlpiConfig
        }
        else {
            Write-Warning -Message "I cannot find Config File, check if you used Set-GlpiToolsConfig to generate Config"
        }

    }
    
    end {
    }
}