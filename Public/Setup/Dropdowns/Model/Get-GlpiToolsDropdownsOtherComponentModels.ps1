<#
.SYNOPSIS
    Function is getting Other Component Models informations from GLPI
.DESCRIPTION
    Function is based on OtherComponentModelId which you can find in GLPI website
    Returns object with property's of Other Component Models
.PARAMETER All
    This parameter will return all Other Component Models from GLPI
.PARAMETER OtherComponentModelId
    This parameter can take pipline input, either, you can use this function with -OtherComponentModelId keyword.
    Provide to this param OtherComponentModelId from GLPI Other Component Models Bookmark
.PARAMETER Raw
    Parameter which you can use with OtherComponentModelId Parameter.
    OtherComponentModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OtherComponentModelName
    This parameter can take pipline input, either, you can use this function with -OtherComponentModelId keyword.
    Provide to this param Other Component Models Name from GLPI Other Component Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOtherComponentModels -All
    Example will return all Other Component Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOtherComponentModels
    Function gets OtherComponentModelId from GLPI from Pipline, and return Other Component Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOtherComponentModels
    Function gets OtherComponentModelId from GLPI from Pipline (u can pass many ID's like that), and return Other Component Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOtherComponentModels -OtherComponentModelId 326
    Function gets OtherComponentModelId from GLPI which is provided through -OtherComponentModelId after Function type, and return Other Component Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOtherComponentModels -OtherComponentModelId 326, 321
    Function gets Other Component Models Id from GLPI which is provided through -OtherComponentModelId keyword after Function type (u can provide many ID's like that), and return Other Component Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOtherComponentModels -OtherComponentModelName Fusion
    Example will return glpi Other Component Models, but what is the most important, Other Component Models will be shown exactly as you see in glpi dropdown Other Component Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Other Component Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Other Component Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsOtherComponentModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OtherComponentModelId")]
        [alias('OCMID')]
        [string[]]$OtherComponentModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OtherComponentModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OtherComponentModelName")]
        [alias('OCMN')]
        [string]$OtherComponentModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OtherComponentModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DevicePciModel/?range=0-9999999999999"
                }
                
                $OtherComponentModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OtherComponentModel in $OtherComponentModelsAll) {
                    $OtherComponentModelHash = [ordered]@{ }
                    $OtherComponentModelProperties = $OtherComponentModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OtherComponentModelProp in $OtherComponentModelProperties) {
                        $OtherComponentModelHash.Add($OtherComponentModelProp.Name, $OtherComponentModelProp.Value)
                    }
                    $object = [pscustomobject]$OtherComponentModelHash
                    $OtherComponentModelsArray.Add($object)
                }
                $OtherComponentModelsArray
                $OtherComponentModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OtherComponentModelId { 
                foreach ( $OCMId in $OtherComponentModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DevicePciModel/$($OCMId)"
                    }

                    Try {
                        $OtherComponentModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OtherComponentModelHash = [ordered]@{ }
                            $OtherComponentModelProperties = $OtherComponentModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OtherComponentModelProp in $OtherComponentModelProperties) {
                                $OtherComponentModelHash.Add($OtherComponentModelProp.Name, $OtherComponentModelProp.Value)
                            }
                            $object = [pscustomobject]$OtherComponentModelHash
                            $OtherComponentModelsArray.Add($object)
                        } else {
                            $OtherComponentModelHash = [ordered]@{ }
                            $OtherComponentModelProperties = $OtherComponentModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OtherComponentModelProp in $OtherComponentModelProperties) {

                                $OtherComponentModelPropNewValue = Get-GlpiToolsParameters -Parameter $OtherComponentModelProp.Name -Value $OtherComponentModelProp.Value

                                $OtherComponentModelHash.Add($OtherComponentModelProp.Name, $OtherComponentModelPropNewValue)
                            }
                            $object = [pscustomobject]$OtherComponentModelHash
                            $OtherComponentModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Other Component Model ID = $OCMId is not found"
                        
                    }
                    $OtherComponentModelsArray
                    $OtherComponentModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OtherComponentModelName { 
                Search-GlpiToolsItems -SearchFor DevicePciModel -SearchType contains -SearchValue $OtherComponentModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}