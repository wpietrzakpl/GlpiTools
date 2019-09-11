<#
.SYNOPSIS
    Function is getting Enclosure Models informations from GLPI
.DESCRIPTION
    Function is based on EnclosureModelId which you can find in GLPI website
    Returns object with property's of Enclosure Models
.PARAMETER All
    This parameter will return all Enclosure Models from GLPI
.PARAMETER EnclosureModelId
    This parameter can take pipline input, either, you can use this function with -EnclosureModelId keyword.
    Provide to this param EnclosureModelId from GLPI Enclosure Models Bookmark
.PARAMETER Raw
    Parameter which you can use with EnclosureModelId Parameter.
    EnclosureModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER EnclosureModelName
    This parameter can take pipline input, either, you can use this function with -EnclosureModelId keyword.
    Provide to this param Enclosure Models Name from GLPI Enclosure Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsEnclosureModels -All
    Example will return all Enclosure Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsEnclosureModels
    Function gets EnclosureModelId from GLPI from Pipline, and return Enclosure Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsEnclosureModels
    Function gets EnclosureModelId from GLPI from Pipline (u can pass many ID's like that), and return Enclosure Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsEnclosureModels -EnclosureModelId 326
    Function gets EnclosureModelId from GLPI which is provided through -EnclosureModelId after Function type, and return Enclosure Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsEnclosureModels -EnclosureModelId 326, 321
    Function gets Enclosure Models Id from GLPI which is provided through -EnclosureModelId keyword after Function type (u can provide many ID's like that), and return Enclosure Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsEnclosureModels -EnclosureModelName Fusion
    Example will return glpi Enclosure Models, but what is the most important, Enclosure Models will be shown exactly as you see in glpi dropdown Enclosure Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Enclosure Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Enclosure Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsEnclosureModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "EnclosureModelId")]
        [alias('EMID')]
        [string[]]$EnclosureModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "EnclosureModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "EnclosureModelName")]
        [alias('EMN')]
        [string]$EnclosureModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $EnclosureModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/enclosuremodel/?range=0-9999999999999"
                }
                
                $EnclosureModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($EnclosureModel in $EnclosureModelsAll) {
                    $EnclosureModelHash = [ordered]@{ }
                    $EnclosureModelProperties = $EnclosureModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($EnclosureModelProp in $EnclosureModelProperties) {
                        $EnclosureModelHash.Add($EnclosureModelProp.Name, $EnclosureModelProp.Value)
                    }
                    $object = [pscustomobject]$EnclosureModelHash
                    $EnclosureModelsArray.Add($object)
                }
                $EnclosureModelsArray
                $EnclosureModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            EnclosureModelId { 
                foreach ( $EMId in $EnclosureModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/enclosuremodel/$($EMId)"
                    }

                    Try {
                        $EnclosureModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $EnclosureModelHash = [ordered]@{ }
                            $EnclosureModelProperties = $EnclosureModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EnclosureModelProp in $EnclosureModelProperties) {
                                $EnclosureModelHash.Add($EnclosureModelProp.Name, $EnclosureModelProp.Value)
                            }
                            $object = [pscustomobject]$EnclosureModelHash
                            $EnclosureModelsArray.Add($object)
                        } else {
                            $EnclosureModelHash = [ordered]@{ }
                            $EnclosureModelProperties = $EnclosureModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EnclosureModelProp in $EnclosureModelProperties) {

                                $EnclosureModelPropNewValue = Get-GlpiToolsParameters -Parameter $EnclosureModelProp.Name -Value $EnclosureModelProp.Value

                                $EnclosureModelHash.Add($EnclosureModelProp.Name, $EnclosureModelPropNewValue)
                            }
                            $object = [pscustomobject]$EnclosureModelHash
                            $EnclosureModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Enclosure Model ID = $EMId is not found"
                        
                    }
                    $EnclosureModelsArray
                    $EnclosureModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            EnclosureModelName { 
                Search-GlpiToolsItems -SearchFor enclosuremodel -SearchType contains -SearchValue $EnclosureModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}