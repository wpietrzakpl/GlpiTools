<#
.SYNOPSIS
    This function is to use for send reset request password for specific user.
.DESCRIPTION
    This function allows to send reset request password for specific user. 
    This function works under the following conditions: * GLPI has notifications enabled * the email address of the user belongs to a user account.
.PARAMETER Email
    Provide here user email.
.EXAMPLE
    PS C:\> Set-GlpiToolsPasswordReset -Email "user@domain.com"
    This example will send an email to user which provided email is belongs to. Email will have reset link inside the mail. 
.INPUTS
    Email
.OUTPUTS
    Message which says that email will be send, or throw error with explaination.
.NOTES
    PSP 03/2019
#>

function Set-GlpiToolsResetPasswordRequest {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$Email
    )
    
    begin {

        $PathToGlpi = $Script:PathToGlpi

        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

    }
    
    process {
        $PutPasswordResetReq = @{
            email = $Email
        } 
        
        $PasswordResetReq = $PutPasswordResetReq | ConvertTo-Json
        
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
            }
            method  = 'put'
            uri     = "$($PathToGlpi)/lostPassword/"
            body    = ([System.Text.Encoding]::UTF8.GetBytes($PasswordResetReq))
        }
        Invoke-RestMethod @params
    }
    
    end {
        
    }
}