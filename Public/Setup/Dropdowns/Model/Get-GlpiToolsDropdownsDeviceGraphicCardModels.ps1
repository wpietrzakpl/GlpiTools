<#
.SYNOPSIS
    Function is getting Device Graphic Card Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceGraphicCardModelId which you can find in GLPI website
    Returns object with property's of Device Graphic Card Models
.PARAMETER All
    This parameter will return all Device Graphic Card Models from GLPI
.PARAMETER DeviceGraphicCardModelId
    This parameter can take pipline input, either, you can use this function with -DeviceGraphicCardModelId keyword.
    Provide to this param DeviceGraphicCardModelId from GLPI Device Graphic Card Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceGraphicCardModelId Parameter.
    DeviceGraphicCardModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceGraphicCardModelName
    This parameter can take pipline input, either, you can use this function with -DeviceGraphicCardModelId keyword.
    Provide to this param Device Graphic Card Models Name from GLPI Device Graphic Card Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceGraphicCardModels -All
    Example will return all Device Graphic Card Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceGraphicCardModels
    Function gets DeviceGraphicCardModelId from GLPI from Pipline, and return Device Graphic Card Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceGraphicCardModels
    Function gets DeviceGraphicCardModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Graphic Card Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceGraphicCardModels -DeviceGraphicCardModelId 326
    Function gets DeviceGraphicCardModelId from GLPI which is provided through -DeviceGraphicCardModelId after Function type, and return Device Graphic Card Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceGraphicCardModels -DeviceGraphicCardModelId 326, 321
    Function gets Device Graphic Card Models Id from GLPI which is provided through -DeviceGraphicCardModelId keyword after Function type (u can provide many ID's like that), and return Device Graphic Card Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceGraphicCardModels -DeviceGraphicCardModelName Fusion
    Example will return glpi Device Graphic Card Models, but what is the most important, Device Graphic Card Models will be shown exactly as you see in glpi dropdown Device Graphic Card Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Graphic Card Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Graphic Card Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceGraphicCardModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceGraphicCardModelId")]
        [alias('DGCMID')]
        [string[]]$DeviceGraphicCardModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceGraphicCardModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceGraphicCardModelName")]
        [alias('DGCMN')]
        [string]$DeviceGraphicCardModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceGraphicCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/devicegraphiccardmodel/?range=0-9999999999999"
                }
                
                $DeviceGraphicCardModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceGraphicCardModel in $DeviceGraphicCardModelsAll) {
                    $DeviceGraphicCardModelHash = [ordered]@{ }
                    $DeviceGraphicCardModelProperties = $DeviceGraphicCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceGraphicCardModelProp in $DeviceGraphicCardModelProperties) {
                        $DeviceGraphicCardModelHash.Add($DeviceGraphicCardModelProp.Name, $DeviceGraphicCardModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceGraphicCardModelHash
                    $DeviceGraphicCardModelsArray.Add($object)
                }
                $DeviceGraphicCardModelsArray
                $DeviceGraphicCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceGraphicCardModelId { 
                foreach ( $DGCMId in $DeviceGraphicCardModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/devicegraphiccardmodel/$($DGCMId)"
                    }

                    Try {
                        $DeviceGraphicCardModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceGraphicCardModelHash = [ordered]@{ }
                            $DeviceGraphicCardModelProperties = $DeviceGraphicCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceGraphicCardModelProp in $DeviceGraphicCardModelProperties) {
                                $DeviceGraphicCardModelHash.Add($DeviceGraphicCardModelProp.Name, $DeviceGraphicCardModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceGraphicCardModelHash
                            $DeviceGraphicCardModelsArray.Add($object)
                        } else {
                            $DeviceGraphicCardModelHash = [ordered]@{ }
                            $DeviceGraphicCardModelProperties = $DeviceGraphicCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceGraphicCardModelProp in $DeviceGraphicCardModelProperties) {

                                $DeviceGraphicCardModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceGraphicCardModelProp.Name -Value $DeviceGraphicCardModelProp.Value

                                $DeviceGraphicCardModelHash.Add($DeviceGraphicCardModelProp.Name, $DeviceGraphicCardModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceGraphicCardModelHash
                            $DeviceGraphicCardModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Graphic Card Model ID = $DGCMId is not found"
                        
                    }
                    $DeviceGraphicCardModelsArray
                    $DeviceGraphicCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceGraphicCardModelName { 
                Search-GlpiToolsItems -SearchFor DeviceGraphicCardModel -SearchType contains -SearchValue $DeviceGraphicCardModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}