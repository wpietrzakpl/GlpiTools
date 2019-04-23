<#
.SYNOPSIS
    Function Change active profile to the profiles_id one.
.DESCRIPTION
    Function Change active profile to the profiles_id one. See Get-GlpiToolsMyProfiles function for possible profiles.
.PARAMETER ProfilesId
    Parameter which indicate on profile that you will change on. Provide here an id of this profile.
.EXAMPLE
    PS C:\> Set-GlpiToolsChangeActiveProfile -ProfileId 4
    Example will change active profile on profile with id number 4.
.EXAMPLE
    PS C:\> 4 | Set-GlpiToolsChangeActiveProfile
    Example will change active profile on profile with id number 4.
.INPUTS
    Integer value
.OUTPUTS
    None, or Error if you provide id that not exist.
.NOTES
    PSP 04/2019
#>

function Set-GlpiToolsChangeActiveProfile {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProfilesId")]
        [alias('PID')]
        [int]$ProfilesId
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

        $PostChangeEntities = @{
            profiles_id = $ProfilesId
        } 
        
        $GlpiChangeEntity = $PostChangeEntities | ConvertTo-Json
        
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'post'
            uri     = "$($PathToGlpi)/changeActiveProfile/"
            body    = $GlpiChangeEntity
        }
        Invoke-RestMethod @params

    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}