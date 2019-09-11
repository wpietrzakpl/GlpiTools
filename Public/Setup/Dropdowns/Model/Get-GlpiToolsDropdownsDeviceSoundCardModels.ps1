<#
.SYNOPSIS
    Function is getting Device Sound Card Models informations from GLPI
.DESCRIPTION
    Function is based on DeviceSoundCardModelId which you can find in GLPI website
    Returns object with property's of Device Sound Card Models
.PARAMETER All
    This parameter will return all Device Sound Card Models from GLPI
.PARAMETER DeviceSoundCardModelId
    This parameter can take pipline input, either, you can use this function with -DeviceSoundCardModelId keyword.
    Provide to this param DeviceSoundCardModelId from GLPI Device Sound Card Models Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceSoundCardModelId Parameter.
    DeviceSoundCardModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceSoundCardModelName
    This parameter can take pipline input, either, you can use this function with -DeviceSoundCardModelId keyword.
    Provide to this param Device Sound Card Models Name from GLPI Device Sound Card Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceSoundCardModels -All
    Example will return all Device Sound Card Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDeviceSoundCardModels
    Function gets DeviceSoundCardModelId from GLPI from Pipline, and return Device Sound Card Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDeviceSoundCardModels
    Function gets DeviceSoundCardModelId from GLPI from Pipline (u can pass many ID's like that), and return Device Sound Card Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceSoundCardModels -DeviceSoundCardModelId 326
    Function gets DeviceSoundCardModelId from GLPI which is provided through -DeviceSoundCardModelId after Function type, and return Device Sound Card Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDeviceSoundCardModels -DeviceSoundCardModelId 326, 321
    Function gets Device Sound Card Models Id from GLPI which is provided through -DeviceSoundCardModelId keyword after Function type (u can provide many ID's like that), and return Device Sound Card Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDeviceSoundCardModels -DeviceSoundCardModelName Fusion
    Example will return glpi Device Sound Card Models, but what is the most important, Device Sound Card Models will be shown exactly as you see in glpi dropdown Device Sound Card Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Device Sound Card Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Device Sound Card Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDeviceSoundCardModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceSoundCardModelId")]
        [alias('DSCMID')]
        [string[]]$DeviceSoundCardModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceSoundCardModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceSoundCardModelName")]
        [alias('DSCMN')]
        [string]$DeviceSoundCardModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DeviceSoundCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceSoundCardModel/?range=0-9999999999999"
                }
                
                $DeviceSoundCardModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceSoundCardModel in $DeviceSoundCardModelsAll) {
                    $DeviceSoundCardModelHash = [ordered]@{ }
                    $DeviceSoundCardModelProperties = $DeviceSoundCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceSoundCardModelProp in $DeviceSoundCardModelProperties) {
                        $DeviceSoundCardModelHash.Add($DeviceSoundCardModelProp.Name, $DeviceSoundCardModelProp.Value)
                    }
                    $object = [pscustomobject]$DeviceSoundCardModelHash
                    $DeviceSoundCardModelsArray.Add($object)
                }
                $DeviceSoundCardModelsArray
                $DeviceSoundCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceSoundCardModelId { 
                foreach ( $DSCMId in $DeviceSoundCardModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceSoundCardModel/$($DSCMId)"
                    }

                    Try {
                        $DeviceSoundCardModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceSoundCardModelHash = [ordered]@{ }
                            $DeviceSoundCardModelProperties = $DeviceSoundCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceSoundCardModelProp in $DeviceSoundCardModelProperties) {
                                $DeviceSoundCardModelHash.Add($DeviceSoundCardModelProp.Name, $DeviceSoundCardModelProp.Value)
                            }
                            $object = [pscustomobject]$DeviceSoundCardModelHash
                            $DeviceSoundCardModelsArray.Add($object)
                        } else {
                            $DeviceSoundCardModelHash = [ordered]@{ }
                            $DeviceSoundCardModelProperties = $DeviceSoundCardModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceSoundCardModelProp in $DeviceSoundCardModelProperties) {

                                $DeviceSoundCardModelPropNewValue = Get-GlpiToolsParameters -Parameter $DeviceSoundCardModelProp.Name -Value $DeviceSoundCardModelProp.Value

                                $DeviceSoundCardModelHash.Add($DeviceSoundCardModelProp.Name, $DeviceSoundCardModelPropNewValue)
                            }
                            $object = [pscustomobject]$DeviceSoundCardModelHash
                            $DeviceSoundCardModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Sound Card Model ID = $DSCMId is not found"
                        
                    }
                    $DeviceSoundCardModelsArray
                    $DeviceSoundCardModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceSoundCardModelName { 
                Search-GlpiToolsItems -SearchFor DeviceSoundCardModel -SearchType contains -SearchValue $DeviceSoundCardModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}