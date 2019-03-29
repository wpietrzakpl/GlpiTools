<#
.SYNOPSIS
    This function is to use for reset password for specific user.
.DESCRIPTION
    This function allows to reset password for specific user. 
    This function works under the following conditions: * GLPI has notifications enabled * the email address of the user belongs to a user account.
.PARAMETER Email
    Provide here user email.
.PARAMETER Password
    Provide here new password for user.
.PARAMETER PasswordForgetToken
    Provide here old user user_token, for the new one.
.EXAMPLE
    PS C:\> Set-GlpiToolsPasswordReset -Email "user@domain.com" -Password "NewPassword" -PasswordForgetToken "b0a4cfe81448299ebed57442f4f21929c80ebee5"
    This example will send an email to user which provided email is belongs to, and reset his password for defined value. Example will renew user_token.
.INPUTS
    Email, Password, User_Token
.OUTPUTS
    Message which says that email will be send, or throw error with explaination.
.NOTES
    PSP 03/2019
#>

function Set-GlpiToolsPasswordReset {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$Email,
        [parameter(Mandatory = $true)]
        [string]$Password,
        [parameter(Mandatory = $false)]
        [string]$PasswordForgetToken
    )
    
    begin {
        
        $PathToGlpi = $Script:PathToGlpi
        
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        
    }
    
    process {
        $PutPasswordReset = @{
            email = $Email
            password = $Password
            password_forget_token = $PasswordForgetToken
        } 
        
        $PasswordReset = $PutPasswordReset | ConvertTo-Json
        
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
            }
            method  = 'put'
            uri     = "$($PathToGlpi)/lostPassword/"
            body    = ([System.Text.Encoding]::UTF8.GetBytes($PasswordReset))
        }
        
        Invoke-RestMethod @params 
        
    }
    
    end {
        
    }
}