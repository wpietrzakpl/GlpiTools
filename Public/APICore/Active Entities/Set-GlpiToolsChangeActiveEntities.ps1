<#
.SYNOPSIS
    Function change active entity of GLPI.
.DESCRIPTION
    Change active entity to the entities id one. See Get-GlpiToolsEntities function /w -All parameter for possible entities.
.PARAMETER EntitiesId
    This parameter provide to function entity id, on which you want to change.
.PARAMETER IsRecursive
    This parameter will enable display sub entities of the active entity. Parameter is optional
.EXAMPLE
    PS C:\> Get-GlpiToolsEntities -EntityName "put entity name here" | Select-Object -ExpandProperty Id | Set-GlpiToolsChangeActiveEntities
    Example changes active entity to entity which you provided to the pipeline
.EXAMPLE
    PS C:\> Get-GlpiToolsEntities -EntityName "put entity name here" | Select-Object -ExpandProperty Id | Set-GlpiToolsChangeActiveEntities -IsRecursive
    Example changes active entity to entity which you provided to the pipeline, and enable display sub entities of active entity.
.EXAMPLE
    PS C:\> Set-GlpiToolsChangeActiveEntities -EntitiesId "id"
    Example changes active entity to entity which you provided to the -EntitiesId parameter.
.EXAMPLE
    PS C:\> Set-GlpiToolsChangeActiveEntities -EntitiesId "id" -IsRecursive
    Example changes active entity to entity which you provided to the -EntitiesId parameter, and enable display sub entities of active entity.
.INPUTS
    Entities Id which you can find in GLPI, or using Get-GlpiToolsEntities parameter.
.OUTPUTS
    Output (if any)
.NOTES
    PSP 03/2019
#>

function Set-GlpiToolsChangeActiveEntities {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [alias('EID')]
        [int]$EntitiesId,
        [parameter(Mandatory = $false)]
        [alias('IR')]
        [switch]$IsRecursive
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

        if ($IsRecursive) {
            $IsRecursiveState = 'true'
        } else {
            $IsRecursiveState = 'false'
        }

        $PostActiveEntities =
        [pscustomobject]@{
            entities_id     = $EntitiesId
            is_recursive    = $IsRecursiveState
        } 

        $GlpiUpload = $PostActiveEntities | ConvertTo-Json
    
        $Upload = '{ "input" : ' + $GlpiUpload + '}' 
        
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'post'
            uri     = "$($PathToGlpi)/changeActiveEntities/"
            body    = ([System.Text.Encoding]::UTF8.GetBytes($Upload))
        }
        Invoke-RestMethod @params
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}
