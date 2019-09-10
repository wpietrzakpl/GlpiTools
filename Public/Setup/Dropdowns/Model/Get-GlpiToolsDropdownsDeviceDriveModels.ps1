<#
.SYNOPSIS
    Function is getting Device Drive Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceDriveModelId which you can find in GLPI website
    Returns object with property's of Device Drive Models
.PARAMETER All
    This parameter will return all Device Drive Models from GLPI
.PARAMETER DeviceDriveModelId
    This parameter can take pipline input, either, you can use this function with -DeviceDriveModelId keyword.
    Provide to this param DeviceDriveModelId from GLPI Device Drive Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceDriveModelId Parameter.
    DeviceDriveModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceDriveModelName
    This parameter can take pipline input, either, you can use this function with -DeviceDriveModelId keyword.
    Provide to this param Device Drive Models Name from GLPI Device Drive Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceDriveModels -All
    Example will return all Device Drive Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceDriveModels
    Function gets DeviceDriveModelId from GLPI from Pipline, and return Device Drive Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceDriveModels
    Function gets DeviceDriveModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Drive Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceDriveModels -DeviceDriveModelId 326
    Function gets DeviceDriveModelId from GLPI which is provided through -DeviceDriveModelId after Function type, and return Device Drive Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceDriveModels -DeviceDriveModelId 326, 321
    Function gets Device Drive Models Id from GLPI which is provided through -DeviceDriveModelId keyword after Function type (u can provide many ID's like that), and return Device Drive Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceDriveModels -DeviceDriveModelName Fusion
    Example will return glpi Device Drive Models, but what is the most important, Device Drive Models will be shown exactly as you see in glpi dropdown Device Drive Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Drive Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Drive Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceDriveModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceDriveModelId")]
        [alias('DDMID')]
        [string[]]$DeviceDriveModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceDriveModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceDriveModelName")]
        [alias('DDMN')]
        [string]$DeviceDriveModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceDriveModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/devicedrivemodel/?range=0-9999999999999"
                }
                
                $DeviceDriveModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceDriveModel in $DeviceDriveModelsAll) {
                    $DeviceDriveModelHash = [ordered]@{ }
                    $DeviceDriveModelProperties = $DeviceDriveModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceDriveModelProp in $DeviceDriveModelProperties) {
                        $DeviceDriveModelHash.Add($DeviceDriveModelProp.Name, $DeviceDriveModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceDriveModelHash
                    $DeviceDriveModelsArray.Add($object)
                }
                $DeviceDriveModelsArray
                $DeviceDriveModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceDriveModelId { 
                foreach ( $DDMId in $DeviceDriveModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/devicedrivemodel/$($DDMId)"
                    }

                    Try {
                        $DeviceDriveModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceDriveModelHash = [ordered]@{ }
                            $DeviceDriveModelProperties = $DeviceDriveModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceDriveModelProp in $DeviceDriveModelProperties) {
                                $DeviceDriveModelHash.Add($DeviceDriveModelProp.Name, $DeviceDriveModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceDriveModelHash
                            $DeviceDriveModelsArray.Add($object)
                        } else {
                            $DeviceDriveModelHash = [ordered]@{ }
                            $DeviceDriveModelProperties = $DeviceDriveModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceDriveModelProp in $DeviceDriveModelProperties) {

                                $DeviceDriveModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceDriveModelProp.Name -Value $DeviceDriveModelProp.Value

                                $DeviceDriveModelHash.Add($DeviceDriveModelProp.Name, $DeviceDriveModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceDriveModelHash
                            $DeviceDriveModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Drive Model ID = $DDMId is not found"
                        
                    }
                    $DeviceDriveModelsArray
                    $DeviceDriveModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceDriveModelName { 
                Search-GlpiToolsItems -SearchFor DeviceDriveModel -SearchType contains -SearchValue $DeviceDriveModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}