<#
.SYNOPSIS
    Function is getting Update Sources informations from GLPI
.DESCRIPTION
    Function is based on UpdateSourcesID which you can find in GLPI website
    Returns object with property's of Update Sources
.PARAMETER All
    This parameter will return all Update Sources from GLPI
.PARAMETER UpdateSourcesId
    This parameter can take pipline input, either, you can use this function with -UpdateSourcesId keyword.
    Provide to this param Update Sources ID from GLPI Update Sources Bookmark
.PARAMETER UpdateSourcesName
    This parameter can take pipline input, either, you can use this function with -UpdateSourcesName keyword.
    Provide to this param Update Sources Name from GLPI Update Sources Bookmark
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsDropdownsUpdateSources
    Function gets UpdateSourcesId from GLPI from Pipline, and return Update Sources object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsDropdownsUpdateSources
    Function gets UpdateSourcesId from GLPI from Pipline (u can pass many ID's like that), and return Update Sources object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsUpdateSources -UpdateSourcesId 326
    Function gets UpdateSourcesId from GLPI which is provided through -UpdateSourcesId after Function type, and return Update Sources object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsUpdateSources -UpdateSourcesId 326, 321
    Function gets UpdateSourcesId from GLPI which is provided through -UpdateSourcesId keyword after Function type (u can provide many ID's like that), and return Update Sources object
.INPUTS
    Update Sources ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Update Sources from GLPI
.NOTES
    PSP 03/2019
#>

function Get-GlpiToolsDropdownsUpdateSources {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "UpdateSourcesId")]
        [alias('USID')]
        [string[]]$UpdateSourcesId,
        [parameter(Mandatory = $true,
            ParameterSetName = "UpdateSourcesName")]
        [alias('USN')]
        [string[]]$UpdateSourcesName
    )
    
    begin {

        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $UpdateSourcesArray = @()
    }
    
    process {
        switch ($ChoosenParam) {
            All { 
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'get'
                    uri     = "$($PathToGlpi)/autoupdatesystem/?range=0-99999999999"
                }
                
                $GlpiUpdateSourcesAll = Invoke-RestMethod @params

                foreach ($GlpiUpdateSource in $GlpiUpdateSourcesAll) {
                    $UpdateSourceHash = [ordered]@{
                        'Id'                = $GlpiUpdateSource.id
                        'Name'              = $GlpiUpdateSource.name
                        'Comment'           = $GlpiUpdateSource.comment
                    }
                    $object = New-Object -TypeName PSCustomObject -Property $UpdateSourceHash
                    $UpdateSourcesArray += $object
                }
                $UpdateSourcesArray
                $UpdateSourcesArray = @()
            }
            UpdateSourcesId { 
                foreach ( $USId in $UpdateSourcesId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/autoupdatesystem/$($USId)"
                    }
                
                    try {
                        $GlpiUpdateSource = Invoke-RestMethod @params -ErrorAction Stop
                        $UpdateSourceHash = [ordered]@{
                            'Id'                = $GlpiUpdateSource.id
                            'Name'              = $GlpiUpdateSource.name
                            'Comment'           = $GlpiUpdateSource.comment
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $UpdateSourceHash
                        $UpdateSourcesArray += $object
                    }
                    catch {
                        $UpdateSourceHash = [ordered]@{
                            'Id'                = $USId
                            'Name'              = ' '
                            'Comment'           = ' '
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $UpdateSourceHash
                        $UpdateSourcesArray += $object  
                    }
                }
                $UpdateSourcesArray
                $UpdateSourcesArray = @()
            }
            UpdateSourcesName { 
                # here search function 
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}