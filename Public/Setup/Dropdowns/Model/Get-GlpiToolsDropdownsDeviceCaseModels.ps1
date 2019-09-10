<#
.SYNOPSIS
    Function is getting Device Case Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceCaseModelId which you can find in GLPI website
    Returns object with property's of Device Case Models
.PARAMETER All
    This parameter will return all Device Case Models from GLPI
.PARAMETER DeviceCaseModelId
    This parameter can take pipline input, either, you can use this function with -DeviceCaseModelId keyword.
    Provide to this param DeviceCaseModelId from GLPI Device Case Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceCaseModelId Parameter.
    DeviceCaseModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceCaseModelName
    This parameter can take pipline input, either, you can use this function with -DeviceCaseModelId keyword.
    Provide to this param Device Case Models Name from GLPI Device Case Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceCaseModels -All
    Example will return all Device Case Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceCaseModels
    Function gets DeviceCaseModelId from GLPI from Pipline, and return Device Case Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceCaseModels
    Function gets DeviceCaseModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Case Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceCaseModels -DeviceCaseModelId 326
    Function gets DeviceCaseModelId from GLPI which is provided through -DeviceCaseModelId after Function type, and return Device Case Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceCaseModels -DeviceCaseModelId 326, 321
    Function gets Device Case Models Id from GLPI which is provided through -DeviceCaseModelId keyword after Function type (u can provide many ID's like that), and return Device Case Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceCaseModels -DeviceCaseModelName Fusion
    Example will return glpi Device Case Models, but what is the most important, Device Case Models will be shown exactly as you see in glpi dropdown Device Case Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Case Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Case Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceCaseModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceCaseModelId")]
        [alias('DCMID')]
        [string[]]$DeviceCaseModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceCaseModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceCaseModelName")]
        [alias('DCMN')]
        [string]$DeviceCaseModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceCaseModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/devicecasemodel/?range=0-9999999999999"
                }
                
                $DeviceCaseModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceCaseModel in $DeviceCaseModelsAll) {
                    $DeviceCaseModelHash = [ordered]@{ }
                    $DeviceCaseModelProperties = $DeviceCaseModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceCaseModelProp in $DeviceCaseModelProperties) {
                        $DeviceCaseModelHash.Add($DeviceCaseModelProp.Name, $DeviceCaseModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceCaseModelHash
                    $DeviceCaseModelsArray.Add($object)
                }
                $DeviceCaseModelsArray
                $DeviceCaseModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceCaseModelId { 
                foreach ( $DCMId in $DeviceCaseModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/devicecasemodel/$($DCMId)"
                    }

                    Try {
                        $DeviceCaseModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceCaseModelHash = [ordered]@{ }
                            $DeviceCaseModelProperties = $DeviceCaseModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceCaseModelProp in $DeviceCaseModelProperties) {
                                $DeviceCaseModelHash.Add($DeviceCaseModelProp.Name, $DeviceCaseModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceCaseModelHash
                            $DeviceCaseModelsArray.Add($object)
                        } else {
                            $DeviceCaseModelHash = [ordered]@{ }
                            $DeviceCaseModelProperties = $DeviceCaseModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceCaseModelProp in $DeviceCaseModelProperties) {

                                $DeviceCaseModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceCaseModelProp.Name -Value $DeviceCaseModelProp.Value

                                $DeviceCaseModelHash.Add($DeviceCaseModelProp.Name, $DeviceCaseModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceCaseModelHash
                            $DeviceCaseModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Case Model ID = $DCMId is not found"
                        
                    }
                    $DeviceCaseModelsArray
                    $DeviceCaseModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceCaseModelName { 
                Search-GlpiToolsItems -SearchFor DeviceCaseModel -SearchType contains -SearchValue $DeviceCaseModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}