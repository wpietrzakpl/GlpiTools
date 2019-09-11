<#
.SYNOPSIS
    Function is getting Device Processor Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceProcessorModelId which you can find in GLPI website
    Returns object with property's of Device Processor Models
.PARAMETER All
    This parameter will return all Device Processor Models from GLPI
.PARAMETER DeviceProcessorModelId
    This parameter can take pipline input, either, you can use this function with -DeviceProcessorModelId keyword.
    Provide to this param DeviceProcessorModelId from GLPI Device Processor Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceProcessorModelId Parameter.
    DeviceProcessorModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceProcessorModelName
    This parameter can take pipline input, either, you can use this function with -DeviceProcessorModelId keyword.
    Provide to this param Device Processor Models Name from GLPI Device Processor Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceProcessorModels -All
    Example will return all Device Processor Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceProcessorModels
    Function gets DeviceProcessorModelId from GLPI from Pipline, and return Device Processor Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceProcessorModels
    Function gets DeviceProcessorModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Processor Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceProcessorModels -DeviceProcessorModelId 326
    Function gets DeviceProcessorModelId from GLPI which is provided through -DeviceProcessorModelId after Function type, and return Device Processor Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceProcessorModels -DeviceProcessorModelId 326, 321
    Function gets Device Processor Models Id from GLPI which is provided through -DeviceProcessorModelId keyword after Function type (u can provide many ID's like that), and return Device Processor Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceProcessorModels -DeviceProcessorModelName Fusion
    Example will return glpi Device Processor Models, but what is the most important, Device Processor Models will be shown exactly as you see in glpi dropdown Device Processor Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Processor Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Processor Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceProcessorModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceProcessorModelId")]
        [alias('DPMID')]
        [string[]]$DeviceProcessorModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceProcessorModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceProcessorModelName")]
        [alias('DPMN')]
        [string]$DeviceProcessorModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceProcessorModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceProcessorModel/?range=0-9999999999999"
                }
                
                $DeviceProcessorModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceProcessorModel in $DeviceProcessorModelsAll) {
                    $DeviceProcessorModelHash = [ordered]@{ }
                    $DeviceProcessorModelProperties = $DeviceProcessorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceProcessorModelProp in $DeviceProcessorModelProperties) {
                        $DeviceProcessorModelHash.Add($DeviceProcessorModelProp.Name, $DeviceProcessorModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceProcessorModelHash
                    $DeviceProcessorModelsArray.Add($object)
                }
                $DeviceProcessorModelsArray
                $DeviceProcessorModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceProcessorModelId { 
                foreach ( $DPMId in $DeviceProcessorModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceProcessorModel/$($DPMId)"
                    }

                    Try {
                        $DeviceProcessorModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceProcessorModelHash = [ordered]@{ }
                            $DeviceProcessorModelProperties = $DeviceProcessorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceProcessorModelProp in $DeviceProcessorModelProperties) {
                                $DeviceProcessorModelHash.Add($DeviceProcessorModelProp.Name, $DeviceProcessorModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceProcessorModelHash
                            $DeviceProcessorModelsArray.Add($object)
                        } else {
                            $DeviceProcessorModelHash = [ordered]@{ }
                            $DeviceProcessorModelProperties = $DeviceProcessorModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceProcessorModelProp in $DeviceProcessorModelProperties) {

                                $DeviceProcessorModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceProcessorModelProp.Name -Value $DeviceProcessorModelProp.Value

                                $DeviceProcessorModelHash.Add($DeviceProcessorModelProp.Name, $DeviceProcessorModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceProcessorModelHash
                            $DeviceProcessorModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Processor Model ID = $DPMId is not found"
                        
                    }
                    $DeviceProcessorModelsArray
                    $DeviceProcessorModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceProcessorModelName { 
                Search-GlpiToolsItems -SearchFor DeviceProcessorModel -SearchType contains -SearchValue $DeviceProcessorModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}