<#
.SYNOPSIS
    Function is getting Device Motherboard Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceMotherboardModelId which you can find in GLPI website
    Returns object with property's of Device Motherboard Models
.PARAMETER All
    This parameter will return all Device Motherboard Models from GLPI
.PARAMETER DeviceMotherboardModelId
    This parameter can take pipline input, either, you can use this function with -DeviceMotherboardModelId keyword.
    Provide to this param DeviceMotherboardModelId from GLPI Device Motherboard Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceMotherboardModelId Parameter.
    DeviceMotherboardModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceMotherboardModelName
    This parameter can take pipline input, either, you can use this function with -DeviceMotherboardModelId keyword.
    Provide to this param Device Motherboard Models Name from GLPI Device Motherboard Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceMotherboardModels -All
    Example will return all Device Motherboard Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceMotherboardModels
    Function gets DeviceMotherboardModelId from GLPI from Pipline, and return Device Motherboard Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceMotherboardModels
    Function gets DeviceMotherboardModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Motherboard Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceMotherboardModels -DeviceMotherboardModelId 326
    Function gets DeviceMotherboardModelId from GLPI which is provided through -DeviceMotherboardModelId after Function type, and return Device Motherboard Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceMotherboardModels -DeviceMotherboardModelId 326, 321
    Function gets Device Motherboard Models Id from GLPI which is provided through -DeviceMotherboardModelId keyword after Function type (u can provide many ID's like that), and return Device Motherboard Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceMotherboardModels -DeviceMotherboardModelName Fusion
    Example will return glpi Device Motherboard Models, but what is the most important, Device Motherboard Models will be shown exactly as you see in glpi dropdown Device Motherboard Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Motherboard Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Motherboard Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceMotherboardModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceMotherboardModelId")]
        [alias('DMMID')]
        [string[]]$DeviceMotherboardModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceMotherboardModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceMotherboardModelName")]
        [alias('DMMN')]
        [string]$DeviceMotherboardModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceMotherboardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceMotherBoardModel/?range=0-9999999999999"
                }
                
                $DeviceMotherboardModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceMotherboardModel in $DeviceMotherboardModelsAll) {
                    $DeviceMotherboardModelHash = [ordered]@{ }
                    $DeviceMotherboardModelProperties = $DeviceMotherboardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceMotherboardModelProp in $DeviceMotherboardModelProperties) {
                        $DeviceMotherboardModelHash.Add($DeviceMotherboardModelProp.Name, $DeviceMotherboardModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceMotherboardModelHash
                    $DeviceMotherboardModelsArray.Add($object)
                }
                $DeviceMotherboardModelsArray
                $DeviceMotherboardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceMotherboardModelId { 
                foreach ( $DMMId in $DeviceMotherboardModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceMotherBoardModel/$($DMMId)"
                    }

                    Try {
                        $DeviceMotherboardModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceMotherboardModelHash = [ordered]@{ }
                            $DeviceMotherboardModelProperties = $DeviceMotherboardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceMotherboardModelProp in $DeviceMotherboardModelProperties) {
                                $DeviceMotherboardModelHash.Add($DeviceMotherboardModelProp.Name, $DeviceMotherboardModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceMotherboardModelHash
                            $DeviceMotherboardModelsArray.Add($object)
                        } else {
                            $DeviceMotherboardModelHash = [ordered]@{ }
                            $DeviceMotherboardModelProperties = $DeviceMotherboardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceMotherboardModelProp in $DeviceMotherboardModelProperties) {

                                $DeviceMotherboardModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceMotherboardModelProp.Name -Value $DeviceMotherboardModelProp.Value

                                $DeviceMotherboardModelHash.Add($DeviceMotherboardModelProp.Name, $DeviceMotherboardModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceMotherboardModelHash
                            $DeviceMotherboardModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Motherboard Model ID = $DMMId is not found"
                        
                    }
                    $DeviceMotherboardModelsArray
                    $DeviceMotherboardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceMotherboardModelName { 
                Search-GlpiToolsItems -SearchFor DeviceMotherBoardModel -SearchType contains -SearchValue $DeviceMotherboardModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}