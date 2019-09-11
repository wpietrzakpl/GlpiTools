<#
.SYNOPSIS
    Function is getting Pdu Models informations from GLPI
.DESCRIPTION
    Function is based on PduModelId which you can find in GLPI website
    Returns object with property's of Pdu Models
.PARAMETER All
    This parameter will return all Pdu Models from GLPI
.PARAMETER PduModelId
    This parameter can take pipline input, either, you can use this function with -PduModelId keyword.
    Provide to this param PduModelId from GLPI Pdu Models Bookmark
.PARAMETER Raw
    Parameter which you can use with PduModelId Parameter.
    PduModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PduModelName
    This parameter can take pipline input, either, you can use this function with -PduModelId keyword.
    Provide to this param Pdu Models Name from GLPI Pdu Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPduModels -All
    Example will return all Pdu Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPduModels
    Function gets PduModelId from GLPI from Pipline, and return Pdu Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPduModels
    Function gets PduModelId from GLPI from Pipline (u can pass many ID's like that), and return Pdu Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPduModels -PduModelId 326
    Function gets PduModelId from GLPI which is provided through -PduModelId after Function type, and return Pdu Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPduModels -PduModelId 326, 321
    Function gets Pdu Models Id from GLPI which is provided through -PduModelId keyword after Function type (u can provide many ID's like that), and return Pdu Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPduModels -PduModelName Fusion
    Example will return glpi Pdu Models, but what is the most important, Pdu Models will be shown exactly as you see in glpi dropdown Pdu Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Pdu Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Pdu Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPduModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PduModelId")]
        [alias('PMID')]
        [string[]]$PduModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PduModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PduModelName")]
        [alias('PMN')]
        [string]$PduModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PduModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/pdumodel/?range=0-9999999999999"
                }
                
                $PduModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PduModel in $PduModelsAll) {
                    $PduModelHash = [ordered]@{ }
                    $PduModelProperties = $PduModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PduModelProp in $PduModelProperties) {
                        $PduModelHash.Add($PduModelProp.Name, $PduModelProp.Value)
                    }
                    $object = [pscustomobject]$PduModelHash
                    $PduModelsArray.Add($object)
                }
                $PduModelsArray
                $PduModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PduModelId { 
                foreach ( $PMId in $PduModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/pdumodel/$($PMId)"
                    }

                    Try {
                        $PduModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PduModelHash = [ordered]@{ }
                            $PduModelProperties = $PduModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PduModelProp in $PduModelProperties) {
                                $PduModelHash.Add($PduModelProp.Name, $PduModelProp.Value)
                            }
                            $object = [pscustomobject]$PduModelHash
                            $PduModelsArray.Add($object)
                        } else {
                            $PduModelHash = [ordered]@{ }
                            $PduModelProperties = $PduModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PduModelProp in $PduModelProperties) {

                                $PduModelPropNewValue = Get-GlpiToolsParameters -Parameter $PduModelProp.Name -Value $PduModelProp.Value

                                $PduModelHash.Add($PduModelProp.Name, $PduModelPropNewValue)
                            }
                            $object = [pscustomobject]$PduModelHash
                            $PduModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Pdu Model ID = $PMId is not found"
                        
                    }
                    $PduModelsArray
                    $PduModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PduModelName { 
                Search-GlpiToolsItems -SearchFor pdumodel -SearchType contains -SearchValue $PduModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}