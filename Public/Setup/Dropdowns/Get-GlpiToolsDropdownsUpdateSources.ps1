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
    Provide to this param Update Sources Name from GLPI Update Sources Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUpdateSources -All
    Example will return all Update Sources from Update Sources. 
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsUpdateSources
    Function gets UpdateSourcesID from GLPI from Pipline, and return Update Sources object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsUpdateSources
    Function gets UpdateSourcesID from GLPI from Pipline (u can pass many ID's like that), and return Update Sources object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUpdateSources -UpdateSourcesId 326
    Function gets UpdateSourcesID from GLPI which is provided through -UpdateSourcesId after Function type, and return Update Sources object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsUpdateSources -UpdateSourcesId 326, 321
    Function gets UpdateSourcesID from GLPI which is provided through -UpdateSourcesId keyword after Function type (u can provide many ID's like that), and return Update Sources object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUpdateSources -UpdateSourcesName glpi
    Example will return glpi Update Sources, but what is the most important, Update Sources will be shown exactly as you see in glpi Update Sources tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
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
        [string]$UpdateSourcesName
    )
    
    begin {

        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $UpdateSourcesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/autoupdatesystem/?range=0-9999999999999"
                }
                
                $GlpiUpdateSourcesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiUpdateSources in $GlpiUpdateSourcesAll) {
                    $UpdateSourcesHash = [ordered]@{ }
                    $UpdateSourcesProperties = $GlpiUpdateSources.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($UpdateSourcesProp in $UpdateSourcesProperties) {
                        $UpdateSourcesHash.Add($UpdateSourcesProp.Name, $UpdateSourcesProp.Value)
                    }
                    $object = [pscustomobject]$UpdateSourcesHash
                    $UpdateSourcesArray.Add($object)
                }
                $UpdateSourcesArray
                $UpdateSourcesArray = [System.Collections.Generic.List[PSObject]]::New()
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

                    Try {
                        $GlpiUpdateSources = Invoke-RestMethod @params -ErrorAction Stop

                        
                        $UpdateSourcesHash = [ordered]@{ }
                        $UpdateSourcesProperties = $GlpiUpdateSources.PSObject.Properties | Select-Object -Property Name, Value 
                                
                        foreach ($UpdateSourcesProp in $UpdateSourcesProperties) {
                            $UpdateSourcesHash.Add($UpdateSourcesProp.Name, $UpdateSourcesProp.Value)
                        }
                        $object = [pscustomobject]$UpdateSourcesHash
                        $UpdateSourcesArray.Add($object)
                
                    } Catch {

                        Write-Verbose -Message "UpdateSources ID = $USId is not found"
                        
                    }
                    $UpdateSourcesArray
                    $UpdateSourcesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            UpdateSourcesName { 
                Search-GlpiToolsItems -SearchFor Autoupdatesystem -SearchType contains -SearchValue $UpdateSourcesName
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}