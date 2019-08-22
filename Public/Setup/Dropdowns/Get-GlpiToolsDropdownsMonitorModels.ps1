<#
.SYNOPSIS
    Function is getting MonitorModel informations from GLPI
.DESCRIPTION
    Function is based on MonitorModelId which you can find in GLPI website
    Returns object with property's of MonitorModel
.PARAMETER All
    This parameter will return all MonitorModel from GLPI
.PARAMETER MonitorModelId
    This parameter can take pipline input, either, you can use this function with -MonitorModelId keyword.
    Provide to this param MonitorModel ID from GLPI MonitorModel Bookmark
.PARAMETER Raw
    Parameter which you can use with MonitorModelId Parameter.
    MonitorModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER MonitorModelName
    Example will return glpi Monitor Model, but what is the most important, Monitor model will be shown exacly as you see in glpi Monitor models tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMonitorModels -All
    Example will return all MonitorModel from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsMonitorModels
    Function gets MonitorModelId from GLPI from Pipline, and return MonitorModel object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsMonitorModels
    Function gets MonitorModelId from GLPI from Pipline (u can pass many ID's like that), and return MonitorModel object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMonitorModels -MonitorModelId 326
    Function gets MonitorModelId from GLPI which is provided through -MonitorModelId after Function type, and return MonitorModel object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsMonitorModels -MonitorModelId 326, 321
    Function gets MonitorModelId from GLPI which is provided through -MonitorModelId keyword after Function type (u can provide many ID's like that), and return MonitorModel object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMonitorModels -MonitorModelName Fusion
    Example will return glpi MonitorModel, but what is the most important, MonitorModel will be shown exactly as you see in glpi dropdown MonitorModel.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    MonitorModel ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of MonitorModel from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsMonitorModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "MonitorModelId")]
        [alias('MMID')]
        [string[]]$MonitorModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "MonitorModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "MonitorModelName")]
        [alias('MMN')]
        [string]$MonitorModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $MonitorModelArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/MonitorModel/?range=0-9999999999999"
                }
                
                $GlpiMonitorModelAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($MonitorModel in $GlpiMonitorModelAll) {
                    $MonitorModelHash = [ordered]@{ }
                    $MonitorModelProperties = $MonitorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($MonitorModelProp in $MonitorModelProperties) {
                        $MonitorModelHash.Add($MonitorModelProp.Name, $MonitorModelProp.Value)
                    }
                    $object = [pscustomobject]$MonitorModelHash
                    $MonitorModelArray.Add($object)
                }
                $MonitorModelArray
                $MonitorModelArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            MonitorModelId { 
                foreach ( $MMId in $MonitorModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/MonitorModel/$($MMId)"
                    }

                    Try {
                        $MonitorModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $MonitorModelHash = [ordered]@{ }
                            $MonitorModelProperties = $MonitorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MonitorModelProp in $MonitorModelProperties) {
                                $MonitorModelHash.Add($MonitorModelProp.Name, $MonitorModelProp.Value)
                            }
                            $object = [pscustomobject]$MonitorModelHash
                            $MonitorModelArray.Add($object)
                        } else {
                            $MonitorModelHash = [ordered]@{ }
                            $MonitorModelProperties = $MonitorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MonitorModelProp in $MonitorModelProperties) {

                                $MonitorModelPropNewValue = Get-GlpiToolsParameters -Parameter $MonitorModelProp.Name -Value $MonitorModelProp.Value

                                $MonitorModelHash.Add($MonitorModelProp.Name, $MonitorModelPropNewValue)
                            }
                            $object = [pscustomobject]$MonitorModelHash
                            $MonitorModelArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Monitor Model ID = $MMId is not found"
                        
                    }
                    $MonitorModelArray
                    $MonitorModelArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            MonitorModelName { 
                Search-GlpiToolsItems -SearchFor MonitorModel -SearchType contains -SearchValue $MonitorModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}