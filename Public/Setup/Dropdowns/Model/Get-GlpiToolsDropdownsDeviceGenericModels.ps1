<#
.SYNOPSIS
    Function is getting Device Generic Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceGenericModelId which you can find in GLPI website
    Returns object with property's of Device Generic Models
.PARAMETER All
    This parameter will return all Device Generic Models from GLPI
.PARAMETER DeviceGenericModelId
    This parameter can take pipline input, either, you can use this function with -DeviceGenericModelId keyword.
    Provide to this param DeviceGenericModelId from GLPI Device Generic Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceGenericModelId Parameter.
    DeviceGenericModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceGenericModelName
    This parameter can take pipline input, either, you can use this function with -DeviceGenericModelId keyword.
    Provide to this param Device Generic Models Name from GLPI Device Generic Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceGenericModels -All
    Example will return all Device Generic Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceGenericModels
    Function gets DeviceGenericModelId from GLPI from Pipline, and return Device Generic Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceGenericModels
    Function gets DeviceGenericModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Generic Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceGenericModels -DeviceGenericModelId 326
    Function gets DeviceGenericModelId from GLPI which is provided through -DeviceGenericModelId after Function type, and return Device Generic Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceGenericModels -DeviceGenericModelId 326, 321
    Function gets Device Generic Models Id from GLPI which is provided through -DeviceGenericModelId keyword after Function type (u can provide many ID's like that), and return Device Generic Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceGenericModels -DeviceGenericModelName Fusion
    Example will return glpi Device Generic Models, but what is the most important, Device Generic Models will be shown exactly as you see in glpi dropdown Device Generic Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Generic Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Generic Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceGenericModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceGenericModelId")]
        [alias('DGMID')]
        [string[]]$DeviceGenericModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceGenericModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceGenericModelName")]
        [alias('DGMN')]
        [string]$DeviceGenericModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceGenericModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/devicegenericmodel/?range=0-9999999999999"
                }
                
                $DeviceGenericModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceGenericModel in $DeviceGenericModelsAll) {
                    $DeviceGenericModelHash = [ordered]@{ }
                    $DeviceGenericModelProperties = $DeviceGenericModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceGenericModelProp in $DeviceGenericModelProperties) {
                        $DeviceGenericModelHash.Add($DeviceGenericModelProp.Name, $DeviceGenericModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceGenericModelHash
                    $DeviceGenericModelsArray.Add($object)
                }
                $DeviceGenericModelsArray
                $DeviceGenericModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceGenericModelId { 
                foreach ( $DGMId in $DeviceGenericModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/devicegenericmodel/$($DGMId)"
                    }

                    Try {
                        $DeviceGenericModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceGenericModelHash = [ordered]@{ }
                            $DeviceGenericModelProperties = $DeviceGenericModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceGenericModelProp in $DeviceGenericModelProperties) {
                                $DeviceGenericModelHash.Add($DeviceGenericModelProp.Name, $DeviceGenericModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceGenericModelHash
                            $DeviceGenericModelsArray.Add($object)
                        } else {
                            $DeviceGenericModelHash = [ordered]@{ }
                            $DeviceGenericModelProperties = $DeviceGenericModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceGenericModelProp in $DeviceGenericModelProperties) {

                                $DeviceGenericModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceGenericModelProp.Name -Value $DeviceGenericModelProp.Value

                                $DeviceGenericModelHash.Add($DeviceGenericModelProp.Name, $DeviceGenericModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceGenericModelHash
                            $DeviceGenericModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Generic Model ID = $DGMId is not found"
                        
                    }
                    $DeviceGenericModelsArray
                    $DeviceGenericModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceGenericModelName { 
                Search-GlpiToolsItems -SearchFor DeviceGenericModel -SearchType contains -SearchValue $DeviceGenericModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}