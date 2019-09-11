<#
.SYNOPSIS
    Function is getting Device Memory Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceMemoryModelId which you can find in GLPI website
    Returns object with property's of Device Memory Models
.PARAMETER All
    This parameter will return all Device Memory Models from GLPI
.PARAMETER DeviceMemoryModelId
    This parameter can take pipline input, either, you can use this function with -DeviceMemoryModelId keyword.
    Provide to this param DeviceMemoryModelId from GLPI Device Memory Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceMemoryModelId Parameter.
    DeviceMemoryModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceMemoryModelName
    This parameter can take pipline input, either, you can use this function with -DeviceMemoryModelId keyword.
    Provide to this param Device Memory Models Name from GLPI Device Memory Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceMemoryModels -All
    Example will return all Device Memory Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceMemoryModels
    Function gets DeviceMemoryModelId from GLPI from Pipline, and return Device Memory Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceMemoryModels
    Function gets DeviceMemoryModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Memory Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceMemoryModels -DeviceMemoryModelId 326
    Function gets DeviceMemoryModelId from GLPI which is provided through -DeviceMemoryModelId after Function type, and return Device Memory Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceMemoryModels -DeviceMemoryModelId 326, 321
    Function gets Device Memory Models Id from GLPI which is provided through -DeviceMemoryModelId keyword after Function type (u can provide many ID's like that), and return Device Memory Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceMemoryModels -DeviceMemoryModelName Fusion
    Example will return glpi Device Memory Models, but what is the most important, Device Memory Models will be shown exactly as you see in glpi dropdown Device Memory Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Memory Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Memory Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceMemoryModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceMemoryModelId")]
        [alias('DMMID')]
        [string[]]$DeviceMemoryModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceMemoryModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceMemoryModelName")]
        [alias('DMMN')]
        [string]$DeviceMemoryModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceMemoryModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceMemoryModel/?range=0-9999999999999"
                }
                
                $DeviceMemoryModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceMemoryModel in $DeviceMemoryModelsAll) {
                    $DeviceMemoryModelHash = [ordered]@{ }
                    $DeviceMemoryModelProperties = $DeviceMemoryModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceMemoryModelProp in $DeviceMemoryModelProperties) {
                        $DeviceMemoryModelHash.Add($DeviceMemoryModelProp.Name, $DeviceMemoryModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceMemoryModelHash
                    $DeviceMemoryModelsArray.Add($object)
                }
                $DeviceMemoryModelsArray
                $DeviceMemoryModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceMemoryModelId { 
                foreach ( $DMMId in $DeviceMemoryModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceMemoryModel/$($DMMId)"
                    }

                    Try {
                        $DeviceMemoryModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceMemoryModelHash = [ordered]@{ }
                            $DeviceMemoryModelProperties = $DeviceMemoryModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceMemoryModelProp in $DeviceMemoryModelProperties) {
                                $DeviceMemoryModelHash.Add($DeviceMemoryModelProp.Name, $DeviceMemoryModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceMemoryModelHash
                            $DeviceMemoryModelsArray.Add($object)
                        } else {
                            $DeviceMemoryModelHash = [ordered]@{ }
                            $DeviceMemoryModelProperties = $DeviceMemoryModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceMemoryModelProp in $DeviceMemoryModelProperties) {

                                $DeviceMemoryModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceMemoryModelProp.Name -Value $DeviceMemoryModelProp.Value

                                $DeviceMemoryModelHash.Add($DeviceMemoryModelProp.Name, $DeviceMemoryModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceMemoryModelHash
                            $DeviceMemoryModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Memory Model ID = $DMMId is not found"
                        
                    }
                    $DeviceMemoryModelsArray
                    $DeviceMemoryModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceMemoryModelName { 
                Search-GlpiToolsItems -SearchFor DeviceMemoryModel -SearchType contains -SearchValue $DeviceMemoryModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}