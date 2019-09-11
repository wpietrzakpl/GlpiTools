<#
.SYNOPSIS
    Function is getting Device Hard Drive Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceHardDriveModelId which you can find in GLPI website
    Returns object with property's of Device Hard Drive Models
.PARAMETER All
    This parameter will return all Device Hard Drive Models from GLPI
.PARAMETER DeviceHardDriveModelId
    This parameter can take pipline input, either, you can use this function with -DeviceHardDriveModelId keyword.
    Provide to this param DeviceHardDriveModelId from GLPI Device Hard Drive Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceHardDriveModelId Parameter.
    DeviceHardDriveModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceHardDriveModelName
    This parameter can take pipline input, either, you can use this function with -DeviceHardDriveModelId keyword.
    Provide to this param Device Hard Drive Models Name from GLPI Device Hard Drive Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceHardDriveModels -All
    Example will return all Device Hard Drive Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceHardDriveModels
    Function gets DeviceHardDriveModelId from GLPI from Pipline, and return Device Hard Drive Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceHardDriveModels
    Function gets DeviceHardDriveModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Hard Drive Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceHardDriveModels -DeviceHardDriveModelId 326
    Function gets DeviceHardDriveModelId from GLPI which is provided through -DeviceHardDriveModelId after Function type, and return Device Hard Drive Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceHardDriveModels -DeviceHardDriveModelId 326, 321
    Function gets Device Hard Drive Models Id from GLPI which is provided through -DeviceHardDriveModelId keyword after Function type (u can provide many ID's like that), and return Device Hard Drive Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceHardDriveModels -DeviceHardDriveModelName Fusion
    Example will return glpi Device Hard Drive Models, but what is the most important, Device Hard Drive Models will be shown exactly as you see in glpi dropdown Device Hard Drive Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Hard Drive Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Hard Drive Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceHardDriveModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceHardDriveModelId")]
        [alias('DHDMID')]
        [string[]]$DeviceHardDriveModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceHardDriveModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceHardDriveModelName")]
        [alias('DHDMN')]
        [string]$DeviceHardDriveModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceHardDriveModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceHardDriveModel/?range=0-9999999999999"
                }
                
                $DeviceHardDriveModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceHardDriveModel in $DeviceHardDriveModelsAll) {
                    $DeviceHardDriveModelHash = [ordered]@{ }
                    $DeviceHardDriveModelProperties = $DeviceHardDriveModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceHardDriveModelProp in $DeviceHardDriveModelProperties) {
                        $DeviceHardDriveModelHash.Add($DeviceHardDriveModelProp.Name, $DeviceHardDriveModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceHardDriveModelHash
                    $DeviceHardDriveModelsArray.Add($object)
                }
                $DeviceHardDriveModelsArray
                $DeviceHardDriveModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceHardDriveModelId { 
                foreach ( $DHDMId in $DeviceHardDriveModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceHardDriveModel/$($DHDMId)"
                    }

                    Try {
                        $DeviceHardDriveModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceHardDriveModelHash = [ordered]@{ }
                            $DeviceHardDriveModelProperties = $DeviceHardDriveModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceHardDriveModelProp in $DeviceHardDriveModelProperties) {
                                $DeviceHardDriveModelHash.Add($DeviceHardDriveModelProp.Name, $DeviceHardDriveModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceHardDriveModelHash
                            $DeviceHardDriveModelsArray.Add($object)
                        } else {
                            $DeviceHardDriveModelHash = [ordered]@{ }
                            $DeviceHardDriveModelProperties = $DeviceHardDriveModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceHardDriveModelProp in $DeviceHardDriveModelProperties) {

                                $DeviceHardDriveModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceHardDriveModelProp.Name -Value $DeviceHardDriveModelProp.Value

                                $DeviceHardDriveModelHash.Add($DeviceHardDriveModelProp.Name, $DeviceHardDriveModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceHardDriveModelHash
                            $DeviceHardDriveModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Hard Drive Model ID = $DHDMId is not found"
                        
                    }
                    $DeviceHardDriveModelsArray
                    $DeviceHardDriveModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceHardDriveModelName { 
                Search-GlpiToolsItems -SearchFor DeviceHardDriveModel -SearchType contains -SearchValue $DeviceHardDriveModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}