<#
.SYNOPSIS
    Function is getting Phone Models informations from GLPI
.DESCRIPTION
    Function is based on PhoneModelId which you can find in GLPI website
    Returns object with property's of Phone Models
.PARAMETER All
    This parameter will return all Phone Models from GLPI
.PARAMETER PhoneModelId
    This parameter can take pipline input, either, you can use this function with -PhoneModelId keyword.
    Provide to this param PhoneModelId from GLPI Phone Models Bookmark
.PARAMETER Raw
    Parameter which you can use with PhoneModelId Parameter.
    PhoneModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PhoneModelName
    This parameter can take pipline input, either, you can use this function with -PhoneModelId keyword.
    Provide to this param Phone Models Name from GLPI Phone Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhoneModels -All
    Example will return all Phone Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPhoneModels
    Function gets PhoneModelId from GLPI from Pipline, and return Phone Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPhoneModels
    Function gets PhoneModelId from GLPI from Pipline (u can pass many ID's like that), and return Phone Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhoneModels -PhoneModelId 326
    Function gets PhoneModelId from GLPI which is provided through -PhoneModelId after Function type, and return Phone Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPhoneModels -PhoneModelId 326, 321
    Function gets Phone Models Id from GLPI which is provided through -PhoneModelId keyword after Function type (u can provide many ID's like that), and return Phone Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhoneModels -PhoneModelName Fusion
    Example will return glpi Phone Models, but what is the most important, Phone Models will be shown exactly as you see in glpi dropdown Phone Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Phone Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Phone Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPhoneModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PhoneModelId")]
        [alias('PMID')]
        [string[]]$PhoneModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PhoneModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PhonelModelName")]
        [alias('PMN')]
        [string]$PhoneModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PhoneModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/phonemodel/?range=0-9999999999999"
                }
                
                $PhoneModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PhoneModel in $PhoneModelsAll) {
                    $PhoneModelHash = [ordered]@{ }
                    $PhoneModelProperties = $PhoneModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PhoneModelProp in $PhoneModelProperties) {
                        $PhoneModelHash.Add($PhoneModelProp.Name, $PhoneModelProp.Value)
                    }
                    $object = [pscustomobject]$PhoneModelHash
                    $PhoneModelsArray.Add($object)
                }
                $PhoneModelsArray
                $PhoneModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PhoneModelId { 
                foreach ( $PMId in $PhoneModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/phonemodel/$($PMId)"
                    }

                    Try {
                        $PhoneModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PhoneModelHash = [ordered]@{ }
                            $PhoneModelProperties = $PhoneModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhoneModelProp in $PhoneModelProperties) {
                                $PhoneModelHash.Add($PhoneModelProp.Name, $PhoneModelProp.Value)
                            }
                            $object = [pscustomobject]$PhoneModelHash
                            $PhoneModelsArray.Add($object)
                        } else {
                            $PhoneModelHash = [ordered]@{ }
                            $PhoneModelProperties = $PhoneModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhoneModelProp in $PhoneModelProperties) {

                                $PhoneModelPropNewValue = Get-GlpiToolsParameters -Parameter $PhoneModelProp.Name -Value $PhoneModelProp.Value

                                $PhoneModelHash.Add($PhoneModelProp.Name, $PhoneModelPropNewValue)
                            }
                            $object = [pscustomobject]$PhoneModelHash
                            $PhoneModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Phone Model ID = $PMId is not found"
                        
                    }
                    $PhoneModelsArray
                    $PhoneModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PhoneModelName { 
                Search-GlpiToolsItems -SearchFor phonemodel -SearchType contains -SearchValue $PhoneModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}