<#
.SYNOPSIS
    Function is getting Device Sensor Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceSensorModelId which you can find in GLPI website
    Returns object with property's of Device Sensor Models
.PARAMETER All
    This parameter will return all Device Sensor Models from GLPI
.PARAMETER DeviceSensorModelId
    This parameter can take pipline input, either, you can use this function with -DeviceSensorModelId keyword.
    Provide to this param DeviceSensorModelId from GLPI Device Sensor Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceSensorModelId Parameter.
    DeviceSensorModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceSensorModelName
    This parameter can take pipline input, either, you can use this function with -DeviceSensorModelId keyword.
    Provide to this param Device Sensor Models Name from GLPI Device Sensor Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceSensorModels -All
    Example will return all Device Sensor Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceSensorModels
    Function gets DeviceSensorModelId from GLPI from Pipline, and return Device Sensor Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceSensorModels
    Function gets DeviceSensorModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Sensor Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceSensorModels -DeviceSensorModelId 326
    Function gets DeviceSensorModelId from GLPI which is provided through -DeviceSensorModelId after Function type, and return Device Sensor Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceSensorModels -DeviceSensorModelId 326, 321
    Function gets Device Sensor Models Id from GLPI which is provided through -DeviceSensorModelId keyword after Function type (u can provide many ID's like that), and return Device Sensor Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceSensorModels -DeviceSensorModelName Fusion
    Example will return glpi Device Sensor Models, but what is the most important, Device Sensor Models will be shown exactly as you see in glpi dropdown Device Sensor Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Sensor Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Sensor Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceSensorModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceSensorModelId")]
        [alias('DSMID')]
        [string[]]$DeviceSensorModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceSensorModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceSensorModelName")]
        [alias('DSMN')]
        [string]$DeviceSensorModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceSensorModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceSensorModel/?range=0-9999999999999"
                }
                
                $DeviceSensorModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceSensorModel in $DeviceSensorModelsAll) {
                    $DeviceSensorModelHash = [ordered]@{ }
                    $DeviceSensorModelProperties = $DeviceSensorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceSensorModelProp in $DeviceSensorModelProperties) {
                        $DeviceSensorModelHash.Add($DeviceSensorModelProp.Name, $DeviceSensorModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceSensorModelHash
                    $DeviceSensorModelsArray.Add($object)
                }
                $DeviceSensorModelsArray
                $DeviceSensorModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceSensorModelId { 
                foreach ( $DSMId in $DeviceSensorModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceSensorModel/$($DSMId)"
                    }

                    Try {
                        $DeviceSensorModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceSensorModelHash = [ordered]@{ }
                            $DeviceSensorModelProperties = $DeviceSensorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceSensorModelProp in $DeviceSensorModelProperties) {
                                $DeviceSensorModelHash.Add($DeviceSensorModelProp.Name, $DeviceSensorModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceSensorModelHash
                            $DeviceSensorModelsArray.Add($object)
                        } else {
                            $DeviceSensorModelHash = [ordered]@{ }
                            $DeviceSensorModelProperties = $DeviceSensorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceSensorModelProp in $DeviceSensorModelProperties) {

                                $DeviceSensorModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceSensorModelProp.Name -Value $DeviceSensorModelProp.Value

                                $DeviceSensorModelHash.Add($DeviceSensorModelProp.Name, $DeviceSensorModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceSensorModelHash
                            $DeviceSensorModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Sensor Model ID = $DSMId is not found"
                        
                    }
                    $DeviceSensorModelsArray
                    $DeviceSensorModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceSensorModelName { 
                Search-GlpiToolsItems -SearchFor DeviceSensorModel -SearchType contains -SearchValue $DeviceSensorModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}