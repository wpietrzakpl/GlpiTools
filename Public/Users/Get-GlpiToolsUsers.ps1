<#
.SYNOPSIS
    Function based on GLPI User ID, returns Name and Surname of desired user.
.DESCRIPTION
    Function based on GLPI User ID, returns Name and Surname of desired user.
.PARAMETER User
    This parameter can take pipline input, either, you can use this function with -User keyword.
    Provide to this param User ID from GLPI Users Bookmark.
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsUsers
    Function gets UserID from GLPI from Pipline, and return Name and Surname
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsUsers
    Function gets UserID from GLPI from Pipline (u can pass many ID's like that), and return Name and Surname
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsUsers -User 326
    Function gets UserID from GLPI which is provided through -User after Function type, and return Name and Surname
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsUsers -User 326, 321
    Function gets UserID from GLPI which is provided through -User keyword after Function type (u can provide many ID's like that), and return Name and Surname
.INPUTS
    User ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with two property's
.NOTES
    PSP 12/2018
#>

function Get-GlpiToolsUsers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]$User
    )
    begin {

        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
    }
    process {
        $glpiObject = @()
        foreach ($gUser in $User) {
            $params = @{
                headers = @{
                    'Content-Type'  = 'application/json'
                    'App-Token'     = $AppToken
                    'Session-Token' = $SessionToken
                }
                method  = 'get'
                uri     = "$($PathToGlpi)/User/$($gUser)"
            }
            try {
                $glpiUser = Invoke-RestMethod @params -ErrorAction Stop

                $firstname = $glpiUser | Select-Object -ExpandProperty firstname
                $lastname = $glpiUser | Select-Object -ExpandProperty realname

                $object = New-Object -TypeName PSCustomObject
                $object | Add-Member -Name 'User' -MemberType NoteProperty -Value ($firstname + " " + $lastname)
                $glpiObject += $object
            }
            catch {
                $object = New-Object -TypeName PSCustomObject
                $object | Add-Member -Name 'User' -MemberType NoteProperty -Value $gUser
                $glpiObject += $object
            }
        }
        $glpiObject
    }
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}