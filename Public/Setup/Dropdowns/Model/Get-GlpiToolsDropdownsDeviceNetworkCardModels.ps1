<#
.SYNOPSIS
    Function is getting Device Network Card Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceNetworkCardModelId which you can find in GLPI website
    Returns object with property's of Device Network Card Models
.PARAMETER All
    This parameter will return all Device Network Card Models from GLPI
.PARAMETER DeviceNetworkCardModelId
    This parameter can take pipline input, either, you can use this function with -DeviceNetworkCardModelId keyword.
    Provide to this param DeviceNetworkCardModelId from GLPI Device Network Card Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceNetworkCardModelId Parameter.
    DeviceNetworkCardModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceNetworkCardModelName
    This parameter can take pipline input, either, you can use this function with -DeviceNetworkCardModelId keyword.
    Provide to this param Device Network Card Models Name from GLPI Device Network Card Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceNetworkCardModels -All
    Example will return all Device Network Card Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceNetworkCardModels
    Function gets DeviceNetworkCardModelId from GLPI from Pipline, and return Device Network Card Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceNetworkCardModels
    Function gets DeviceNetworkCardModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Network Card Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceNetworkCardModels -DeviceNetworkCardModelId 326
    Function gets DeviceNetworkCardModelId from GLPI which is provided through -DeviceNetworkCardModelId after Function type, and return Device Network Card Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceNetworkCardModels -DeviceNetworkCardModelId 326, 321
    Function gets Device Network Card Models Id from GLPI which is provided through -DeviceNetworkCardModelId keyword after Function type (u can provide many ID's like that), and return Device Network Card Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceNetworkCardModels -DeviceNetworkCardModelName Fusion
    Example will return glpi Device Network Card Models, but what is the most important, Device Network Card Models will be shown exactly as you see in glpi dropdown Device Network Card Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Network Card Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Network Card Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceNetworkCardModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceNetworkCardModelId")]
        [alias('DNCMID')]
        [string[]]$DeviceNetworkCardModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceNetworkCardModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceNetworkCardModelName")]
        [alias('DNCMN')]
        [string]$DeviceNetworkCardModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceNetworkCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceNetworkCardModel/?range=0-9999999999999"
                }
                
                $DeviceNetworkCardModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceNetworkCardModel in $DeviceNetworkCardModelsAll) {
                    $DeviceNetworkCardModelHash = [ordered]@{ }
                    $DeviceNetworkCardModelProperties = $DeviceNetworkCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceNetworkCardModelProp in $DeviceNetworkCardModelProperties) {
                        $DeviceNetworkCardModelHash.Add($DeviceNetworkCardModelProp.Name, $DeviceNetworkCardModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceNetworkCardModelHash
                    $DeviceNetworkCardModelsArray.Add($object)
                }
                $DeviceNetworkCardModelsArray
                $DeviceNetworkCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceNetworkCardModelId { 
                foreach ( $DNCMId in $DeviceNetworkCardModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceNetworkCardModel/$($DNCMId)"
                    }

                    Try {
                        $DeviceNetworkCardModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceNetworkCardModelHash = [ordered]@{ }
                            $DeviceNetworkCardModelProperties = $DeviceNetworkCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceNetworkCardModelProp in $DeviceNetworkCardModelProperties) {
                                $DeviceNetworkCardModelHash.Add($DeviceNetworkCardModelProp.Name, $DeviceNetworkCardModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceNetworkCardModelHash
                            $DeviceNetworkCardModelsArray.Add($object)
                        } else {
                            $DeviceNetworkCardModelHash = [ordered]@{ }
                            $DeviceNetworkCardModelProperties = $DeviceNetworkCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceNetworkCardModelProp in $DeviceNetworkCardModelProperties) {

                                $DeviceNetworkCardModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceNetworkCardModelProp.Name -Value $DeviceNetworkCardModelProp.Value

                                $DeviceNetworkCardModelHash.Add($DeviceNetworkCardModelProp.Name, $DeviceNetworkCardModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceNetworkCardModelHash
                            $DeviceNetworkCardModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Network Card Model ID = $DNCMId is not found"
                        
                    }
                    $DeviceNetworkCardModelsArray
                    $DeviceNetworkCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceNetworkCardModelName { 
                Search-GlpiToolsItems -SearchFor DeviceNetworkCardModel -SearchType contains -SearchValue $DeviceNetworkCardModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}