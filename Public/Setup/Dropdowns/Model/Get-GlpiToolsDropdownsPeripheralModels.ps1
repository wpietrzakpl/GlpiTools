<#
.SYNOPSIS
    Function is getting Peripheral Models informations from GLPI
.DESCRIPTION
    Function is based on PeripheralModelId which you can find in GLPI website
    Returns object with property's of Peripheral Models
.PARAMETER All
    This parameter will return all Peripheral Models from GLPI
.PARAMETER PeripheralModelId
    This parameter can take pipline input, either, you can use this function with -PeripheralModelId keyword.
    Provide to this param PeripheralModelId from GLPI Peripheral Models Bookmark
.PARAMETER Raw
    Parameter which you can use with PeripheralModelId Parameter.
    PeripheralModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PeripheralModelName
    This parameter can take pipline input, either, you can use this function with -PeripheralModelId keyword.
    Provide to this param Peripheral Models Name from GLPI Peripheral Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPeripheralModels -All
    Example will return all Peripheral Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPeripheralModels
    Function gets PeripheralModelId from GLPI from Pipline, and return Peripheral Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPeripheralModels
    Function gets PeripheralModelId from GLPI from Pipline (u can pass many ID's like that), and return Peripheral Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPeripheralModels -PeripheralModelId 326
    Function gets PeripheralModelId from GLPI which is provided through -PeripheralModelId after Function type, and return Peripheral Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPeripheralModels -PeripheralModelId 326, 321
    Function gets Peripheral Models Id from GLPI which is provided through -PeripheralModelId keyword after Function type (u can provide many ID's like that), and return Peripheral Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPeripheralModels -PeripheralModelName Fusion
    Example will return glpi Peripheral Models, but what is the most important, Peripheral Models will be shown exactly as you see in glpi dropdown Peripheral Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Peripheral Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Peripheral Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPeripheralModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PeripheralModelId")]
        [alias('PMID')]
        [string[]]$PeripheralModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PeripheralModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PeripheralModelName")]
        [alias('PMN')]
        [string]$PeripheralModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PeripheralModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/peripheralmodel/?range=0-9999999999999"
                }
                
                $PeripheralModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PeripheralModel in $PeripheralModelsAll) {
                    $PeripheralModelHash = [ordered]@{ }
                    $PeripheralModelProperties = $PeripheralModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PeripheralModelProp in $PeripheralModelProperties) {
                        $PeripheralModelHash.Add($PeripheralModelProp.Name, $PeripheralModelProp.Value)
                    }
                    $object = [pscustomobject]$PeripheralModelHash
                    $PeripheralModelsArray.Add($object)
                }
                $PeripheralModelsArray
                $PeripheralModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PeripheralModelId { 
                foreach ( $PMId in $PeripheralModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/peripheralmodel/$($PMId)"
                    }

                    Try {
                        $PeripheralModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PeripheralModelHash = [ordered]@{ }
                            $PeripheralModelProperties = $PeripheralModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PeripheralModelProp in $PeripheralModelProperties) {
                                $PeripheralModelHash.Add($PeripheralModelProp.Name, $PeripheralModelProp.Value)
                            }
                            $object = [pscustomobject]$PeripheralModelHash
                            $PeripheralModelsArray.Add($object)
                        } else {
                            $PeripheralModelHash = [ordered]@{ }
                            $PeripheralModelProperties = $PeripheralModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PeripheralModelProp in $PeripheralModelProperties) {

                                $PeripheralModelPropNewValue = Get-GlpiToolsParameters -Parameter $PeripheralModelProp.Name -Value $PeripheralModelProp.Value

                                $PeripheralModelHash.Add($PeripheralModelProp.Name, $PeripheralModelPropNewValue)
                            }
                            $object = [pscustomobject]$PeripheralModelHash
                            $PeripheralModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Peripheral Model ID = $PMId is not found"
                        
                    }
                    $PeripheralModelsArray
                    $PeripheralModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PeripheralModelName { 
                Search-GlpiToolsItems -SearchFor peripheralmodel -SearchType contains -SearchValue $PeripheralModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}