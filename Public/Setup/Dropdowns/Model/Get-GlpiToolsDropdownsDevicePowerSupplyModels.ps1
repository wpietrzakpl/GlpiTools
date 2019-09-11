<#
.SYNOPSIS
    Function is getting Device Power Supply Models informations from GLPI
.DESCRIPTION
    Function is based on DevicePowerSupplyModelId which you can find in GLPI website
    Returns object with property's of Device Power Supply Models
.PARAMETER All
    This parameter will return all Device Power Supply Models from GLPI
.PARAMETER DevicePowerSupplyModelId
    This parameter can take pipline input, either, you can use this function with -DevicePowerSupplyModelId keyword.
    Provide to this param DevicePowerSupplyModelId from GLPI Device Power Supply Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DevicePowerSupplyModelId Parameter.
    DevicePowerSupplyModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DevicePowerSupplyModelName
    This parameter can take pipline input, either, you can use this function with -DevicePowerSupplyModelId keyword.
    Provide to this param Device Power Supply Models Name from GLPI Device Power Supply Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDevicePowerSupplyModels -All
    Example will return all Device Power Supply Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDevicePowerSupplyModels
    Function gets DevicePowerSupplyModelId from GLPI from Pipline, and return Device Power Supply Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDevicePowerSupplyModels
    Function gets DevicePowerSupplyModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Power Supply Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDevicePowerSupplyModels -DevicePowerSupplyModelId 326
    Function gets DevicePowerSupplyModelId from GLPI which is provided through -DevicePowerSupplyModelId after Function type, and return Device Power Supply Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDevicePowerSupplyModels -DevicePowerSupplyModelId 326, 321
    Function gets Device Power Supply Models Id from GLPI which is provided through -DevicePowerSupplyModelId keyword after Function type (u can provide many ID's like that), and return Device Power Supply Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDevicePowerSupplyModels -DevicePowerSupplyModelName Fusion
    Example will return glpi Device Power Supply Models, but what is the most important, Device Power Supply Models will be shown exactly as you see in glpi dropdown Device Power Supply Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Power Supply Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Power Supply Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDevicePowerSupplyModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DevicePowerSupplyModelId")]
        [alias('DPSMID')]
        [string[]]$DevicePowerSupplyModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DevicePowerSupplyModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DevicePowerSupplyModelName")]
        [alias('DPSMN')]
        [string]$DevicePowerSupplyModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DevicePowerSupplyModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DevicePowerSupplyModel/?range=0-9999999999999"
                }
                
                $DevicePowerSupplyModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DevicePowerSupplyModel in $DevicePowerSupplyModelsAll) {
                    $DevicePowerSupplyModelHash = [ordered]@{ }
                    $DevicePowerSupplyModelProperties = $DevicePowerSupplyModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DevicePowerSupplyModelProp in $DevicePowerSupplyModelProperties) {
                        $DevicePowerSupplyModelHash.Add($DevicePowerSupplyModelProp.Name, $DevicePowerSupplyModelProp.Value)
                    }
                    $object = [pscustomobject]$DevicePowerSupplyModelHash
                    $DevicePowerSupplyModelsArray.Add($object)
                }
                $DevicePowerSupplyModelsArray
                $DevicePowerSupplyModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DevicePowerSupplyModelId { 
                foreach ( $DPSMId in $DevicePowerSupplyModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DevicePowerSupplyModel/$($DPSMId)"
                    }

                    Try {
                        $DevicePowerSupplyModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DevicePowerSupplyModelHash = [ordered]@{ }
                            $DevicePowerSupplyModelProperties = $DevicePowerSupplyModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DevicePowerSupplyModelProp in $DevicePowerSupplyModelProperties) {
                                $DevicePowerSupplyModelHash.Add($DevicePowerSupplyModelProp.Name, $DevicePowerSupplyModelProp.Value)
                            }
                            $object = [pscustomobject]$DevicePowerSupplyModelHash
                            $DevicePowerSupplyModelsArray.Add($object)
                        } else {
                            $DevicePowerSupplyModelHash = [ordered]@{ }
                            $DevicePowerSupplyModelProperties = $DevicePowerSupplyModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DevicePowerSupplyModelProp in $DevicePowerSupplyModelProperties) {

                                $DevicePowerSupplyModelPropNewValue = Get-GlpiToolsParameters -Parameter $DevicePowerSupplyModelProp.Name -Value $DevicePowerSupplyModelProp.Value

                                $DevicePowerSupplyModelHash.Add($DevicePowerSupplyModelProp.Name, $DevicePowerSupplyModelPropNewValue)
                            }
                            $object = [pscustomobject]$DevicePowerSupplyModelHash
                            $DevicePowerSupplyModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Power Supply Model ID = $DPSMId is not found"
                        
                    }
                    $DevicePowerSupplyModelsArray
                    $DevicePowerSupplyModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DevicePowerSupplyModelName { 
                Search-GlpiToolsItems -SearchFor DevicePowerSupplyModel -SearchType contains -SearchValue $DevicePowerSupplyModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}