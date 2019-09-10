<#
.SYNOPSIS
    Function is getting Network Equipment Models informations from GLPI
.DESCRIPTION
    Function is based on NetworkEquipmentModelId which you can find in GLPI website
    Returns object with property's of Network Equipment Models
.PARAMETER All
    This parameter will return all Network Equipment Models from GLPI
.PARAMETER NetworkEquipmentModelId
    This parameter can take pipline input, either, you can use this function with -NetworkEquipmentModelId keyword.
    Provide to this param NetworkEquipmentModelId from GLPI Network Equipment Models Bookmark
.PARAMETER Raw
    Parameter which you can use with NetworkEquipmentModelId Parameter.
    NetworkEquipmentModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER NetworkEquipmentModelName
    This parameter can take pipline input, either, you can use this function with -NetworkEquipmentModelId keyword.
    Provide to this param Network Equipment Models Name from GLPI Network Equipment Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkEquipmentModels -All
    Example will return all Network Equipment Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsNetworkEquipmentModels
    Function gets NetworkEquipmentModelId from GLPI from Pipline, and return Network Equipment Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsNetworkEquipmentModels
    Function gets NetworkEquipmentModelId from GLPI from Pipline (u can pass many ID's like that), and return Network Equipment Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkEquipmentModels -NetworkEquipmentModelId 326
    Function gets NetworkEquipmentModelId from GLPI which is provided through -NetworkEquipmentModelId after Function type, and return Network Equipment Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsNetworkEquipmentModels -NetworkEquipmentModelId 326, 321
    Function gets Network Equipment Models Id from GLPI which is provided through -NetworkEquipmentModelId keyword after Function type (u can provide many ID's like that), and return Network Equipment Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkEquipmentModels -NetworkEquipmentModelName Fusion
    Example will return glpi Network Equipment Models, but what is the most important, Network Equipment Models will be shown exactly as you see in glpi dropdown Network Equipment Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Network Equipment Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Network Equipment Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsNetworkEquipmentModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "NetworkEquipmentModelId")]
        [alias('NEMID')]
        [string[]]$NetworkEquipmentModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkEquipmentModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "NetworkEquipmentModelName")]
        [alias('NEMN')]
        [string]$NetworkEquipmentModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $NetworkEquipmentModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/networkequipmentmodel/?range=0-9999999999999"
                }
                
                $NetworkEquipmentModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($NetworkEquipmentModel in $NetworkEquipmentModelsAll) {
                    $NetworkEquipmentModelHash = [ordered]@{ }
                    $NetworkEquipmentModelProperties = $NetworkEquipmentModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($NetworkEquipmentModelProp in $NetworkEquipmentModelProperties) {
                        $NetworkEquipmentModelHash.Add($NetworkEquipmentModelProp.Name, $NetworkEquipmentModelProp.Value)
                    }
                    $object = [pscustomobject]$NetworkEquipmentModelHash
                    $NetworkEquipmentModelsArray.Add($object)
                }
                $NetworkEquipmentModelsArray
                $NetworkEquipmentModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            NetworkEquipmentModelId { 
                foreach ( $NEMId in $NetworkEquipmentModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/networkequipmentmodel/$($NEMId)"
                    }

                    Try {
                        $NetworkEquipmentModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $NetworkEquipmentModelHash = [ordered]@{ }
                            $NetworkEquipmentModelProperties = $NetworkEquipmentModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkEquipmentModelProp in $NetworkEquipmentModelProperties) {
                                $NetworkEquipmentModelHash.Add($NetworkEquipmentModelProp.Name, $NetworkEquipmentModelProp.Value)
                            }
                            $object = [pscustomobject]$NetworkEquipmentModelHash
                            $NetworkEquipmentModelsArray.Add($object)
                        } else {
                            $NetworkEquipmentModelHash = [ordered]@{ }
                            $NetworkEquipmentModelProperties = $NetworkEquipmentModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkEquipmentModelProp in $NetworkEquipmentModelProperties) {

                                $NetworkEquipmentModelPropNewValue = Get-GlpiToolsParameters -Parameter $NetworkEquipmentModelProp.Name -Value $NetworkEquipmentModelProp.Value

                                $NetworkEquipmentModelHash.Add($NetworkEquipmentModelProp.Name, $NetworkEquipmentModelPropNewValue)
                            }
                            $object = [pscustomobject]$NetworkEquipmentModelHash
                            $NetworkEquipmentModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Network Equipment Model ID = $NEMId is not found"
                        
                    }
                    $NetworkEquipmentModelsArray
                    $NetworkEquipmentModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            NetworkEquipmentModelName { 
                Search-GlpiToolsItems -SearchFor Networkequipmentmodel -SearchType contains -SearchValue $NetworkEquipmentModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}