<#
.SYNOPSIS
    Function is getting Device Control Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceControlModelId which you can find in GLPI website
    Returns object with property's of Device Control Models
.PARAMETER All
    This parameter will return all Device Control Models from GLPI
.PARAMETER DeviceControlModelId
    This parameter can take pipline input, either, you can use this function with -DeviceControlModelId keyword.
    Provide to this param DeviceControlModelId from GLPI Device Control Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceControlModelId Parameter.
    DeviceControlModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceControlModelName
    This parameter can take pipline input, either, you can use this function with -DeviceControlModelId keyword.
    Provide to this param Device Control Models Name from GLPI Device Control Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceControlModels -All
    Example will return all Device Control Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceControlModels
    Function gets DeviceControlModelId from GLPI from Pipline, and return Device Control Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceControlModels
    Function gets DeviceControlModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Control Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceControlModels -DeviceControlModelId 326
    Function gets DeviceControlModelId from GLPI which is provided through -DeviceControlModelId after Function type, and return Device Control Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceControlModels -DeviceControlModelId 326, 321
    Function gets Device Control Models Id from GLPI which is provided through -DeviceControlModelId keyword after Function type (u can provide many ID's like that), and return Device Control Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceControlModels -DeviceControlModelName Fusion
    Example will return glpi Device Control Models, but what is the most important, Device Control Models will be shown exactly as you see in glpi dropdown Device Control Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Control Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Control Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceControlModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceControlModelId")]
        [alias('DCMID')]
        [string[]]$DeviceControlModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceControlModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceControlModelName")]
        [alias('DCMN')]
        [string]$DeviceControlModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceControlModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/devicecontrolmodel/?range=0-9999999999999"
                }
                
                $DeviceControlModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceControlModel in $DeviceControlModelsAll) {
                    $DeviceControlModelHash = [ordered]@{ }
                    $DeviceControlModelProperties = $DeviceControlModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceControlModelProp in $DeviceControlModelProperties) {
                        $DeviceControlModelHash.Add($DeviceControlModelProp.Name, $DeviceControlModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceControlModelHash
                    $DeviceControlModelsArray.Add($object)
                }
                $DeviceControlModelsArray
                $DeviceControlModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceControlModelId { 
                foreach ( $DCMId in $DeviceControlModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/devicecontrolmodel/$($DCMId)"
                    }

                    Try {
                        $DeviceControlModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceControlModelHash = [ordered]@{ }
                            $DeviceControlModelProperties = $DeviceControlModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceControlModelProp in $DeviceControlModelProperties) {
                                $DeviceControlModelHash.Add($DeviceControlModelProp.Name, $DeviceControlModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceControlModelHash
                            $DeviceControlModelsArray.Add($object)
                        } else {
                            $DeviceControlModelHash = [ordered]@{ }
                            $DeviceControlModelProperties = $DeviceControlModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceControlModelProp in $DeviceControlModelProperties) {

                                $DeviceControlModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceControlModelProp.Name -Value $DeviceControlModelProp.Value

                                $DeviceControlModelHash.Add($DeviceControlModelProp.Name, $DeviceControlModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceControlModelHash
                            $DeviceControlModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Control Model ID = $DCMId is not found"
                        
                    }
                    $DeviceControlModelsArray
                    $DeviceControlModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceControlModelName { 
                Search-GlpiToolsItems -SearchFor DeviceControlModel -SearchType contains -SearchValue $DeviceControlModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}