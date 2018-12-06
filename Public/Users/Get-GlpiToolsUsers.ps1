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
    General notes
#>

function Get-GlpiToolsUsers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]$User
    )
    begin {
        . .\Set-GlpiToolsInitSession.ps1
        . .\Set-GlpiToolsKillSession.ps1
        . .\Get-GlpiToolsConfig.ps1

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