<#
.SYNOPSIS
    Function is getting Request Sources informations from GLPI
.DESCRIPTION
    Function is based on RequestSourceId which you can find in GLPI website
    Returns object with property's of Request Sources
.PARAMETER All
    This parameter will return all Request Sources from GLPI
.PARAMETER RequestSourceId
    This parameter can take pipline input, either, you can use this function with -RequestSourceId keyword.
    Provide to this param RequestSourceId from GLPI Request Sources Bookmark
.PARAMETER Raw
    Parameter which you can use with RequestSourceId Parameter.
    RequestSourceId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER RequestSourceName
    This parameter can take pipline input, either, you can use this function with -RequestSourceId keyword.
    Provide to this param Request Sources Name from GLPI Request Sources Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRequestSources -All
    Example will return all Request Sources from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsRequestSources
    Function gets RequestSourceId from GLPI from Pipline, and return Request Sources object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsRequestSources
    Function gets RequestSourceId from GLPI from Pipline (u can pass many ID's like that), and return Request Sources object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRequestSources -RequestSourceId 326
    Function gets RequestSourceId from GLPI which is provided through -RequestSourceId after Function type, and return Request Sources object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsRequestSources -RequestSourceId 326, 321
    Function gets Request Sources Id from GLPI which is provided through -RequestSourceId keyword after Function type (u can provide many ID's like that), and return Request Sources object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRequestSources -RequestSourceName Fusion
    Example will return glpi Request Sources, but what is the most important, Request Sources will be shown exactly as you see in glpi dropdown Request Sources.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Request Sources ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Request Sources from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsRequestSources {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "RequestSourceId")]
        [alias('RSID')]
        [string[]]$RequestSourceId,
        [parameter(Mandatory = $false,
            ParameterSetName = "RequestSourceId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "RequestSourceName")]
        [alias('RSN')]
        [string]$RequestSourceName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $RequestSourcesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/requesttype/?range=0-9999999999999"
                }
                
                $RequestSourcesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($RequestSource in $RequestSourcesAll) {
                    $RequestSourceHash = [ordered]@{ }
                    $RequestSourceProperties = $RequestSource.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($RequestSourceProp in $RequestSourceProperties) {
                        $RequestSourceHash.Add($RequestSourceProp.Name, $RequestSourceProp.Value)
                    }
                    $object = [pscustomobject]$RequestSourceHash
                    $RequestSourcesArray.Add($object)
                }
                $RequestSourcesArray
                $RequestSourcesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            RequestSourceId { 
                foreach ( $RSId in $RequestSourceId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/requesttype/$($RSId)"
                    }

                    Try {
                        $RequestSource = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $RequestSourceHash = [ordered]@{ }
                            $RequestSourceProperties = $RequestSource.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RequestSourceProp in $RequestSourceProperties) {
                                $RequestSourceHash.Add($RequestSourceProp.Name, $RequestSourceProp.Value)
                            }
                            $object = [pscustomobject]$RequestSourceHash
                            $RequestSourcesArray.Add($object)
                        } else {
                            $RequestSourceHash = [ordered]@{ }
                            $RequestSourceProperties = $RequestSource.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RequestSourceProp in $RequestSourceProperties) {

                                $RequestSourcePropNewValue = Get-GlpiToolsParameters -Parameter $RequestSourceProp.Name -Value $RequestSourceProp.Value

                                $RequestSourceHash.Add($RequestSourceProp.Name, $RequestSourcePropNewValue)
                            }
                            $object = [pscustomobject]$RequestSourceHash
                            $RequestSourcesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Request Source ID = $RSId is not found"
                        
                    }
                    $RequestSourcesArray
                    $RequestSourcesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            RequestSourceName { 
                Search-GlpiToolsItems -SearchFor requesttype -SearchType contains -SearchValue $RequestSourceName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}