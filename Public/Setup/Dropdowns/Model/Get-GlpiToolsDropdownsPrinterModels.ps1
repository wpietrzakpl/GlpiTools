<#
.SYNOPSIS
    Function is getting Printer Models informations from GLPI
.DESCRIPTION
    Function is based on PrinterModelId which you can find in GLPI website
    Returns object with property's of Printer Models
.PARAMETER All
    This parameter will return all Printer Models from GLPI
.PARAMETER PrinterModelId
    This parameter can take pipline input, either, you can use this function with -PrinterModelId keyword.
    Provide to this param PrinterModelId from GLPI Printer Models Bookmark
.PARAMETER Raw
    Parameter which you can use with PrinterModelId Parameter.
    PrinterModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PrinterModelName
    This parameter can take pipline input, either, you can use this function with -PrinterModelId keyword.
    Provide to this param Printer Models Name from GLPI Printer Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPrinterModels -All
    Example will return all Printer Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPrinterModels
    Function gets PrinterModelId from GLPI from Pipline, and return Printer Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPrinterModels
    Function gets PrinterModelId from GLPI from Pipline (u can pass many ID's like that), and return Printer Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPrinterModels -PrinterModelId 326
    Function gets PrinterModelId from GLPI which is provided through -PrinterModelId after Function type, and return Printer Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPrinterModels -PrinterModelId 326, 321
    Function gets Printer Models Id from GLPI which is provided through -PrinterModelId keyword after Function type (u can provide many ID's like that), and return Printer Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPrinterModels -PrinterModelName Fusion
    Example will return glpi Printer Models, but what is the most important, Printer Models will be shown exactly as you see in glpi dropdown Printer Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Printer Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Printer Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPrinterModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PrinterModelId")]
        [alias('PMID')]
        [string[]]$PrinterModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PrinterModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PrinterModelName")]
        [alias('PMN')]
        [string]$PrinterModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PrinterModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/printermodel/?range=0-9999999999999"
                }
                
                $PrinterModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PrinterModel in $PrinterModelsAll) {
                    $PrinterModelHash = [ordered]@{ }
                    $PrinterModelProperties = $PrinterModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PrinterModelProp in $PrinterModelProperties) {
                        $PrinterModelHash.Add($PrinterModelProp.Name, $PrinterModelProp.Value)
                    }
                    $object = [pscustomobject]$PrinterModelHash
                    $PrinterModelsArray.Add($object)
                }
                $PrinterModelsArray
                $PrinterModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PrinterModelId { 
                foreach ( $PMId in $PrinterModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/printermodel/$($PMId)"
                    }

                    Try {
                        $PrinterModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PrinterModelHash = [ordered]@{ }
                            $PrinterModelProperties = $PrinterModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PrinterModelProp in $PrinterModelProperties) {
                                $PrinterModelHash.Add($PrinterModelProp.Name, $PrinterModelProp.Value)
                            }
                            $object = [pscustomobject]$PrinterModelHash
                            $PrinterModelsArray.Add($object)
                        } else {
                            $PrinterModelHash = [ordered]@{ }
                            $PrinterModelProperties = $PrinterModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PrinterModelProp in $PrinterModelProperties) {

                                $PrinterModelPropNewValue = Get-GlpiToolsParameters -Parameter $PrinterModelProp.Name -Value $PrinterModelProp.Value

                                $PrinterModelHash.Add($PrinterModelProp.Name, $PrinterModelPropNewValue)
                            }
                            $object = [pscustomobject]$PrinterModelHash
                            $PrinterModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Printer Model ID = $PMId is not found"
                        
                    }
                    $PrinterModelsArray
                    $PrinterModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PrinterModelName { 
                Search-GlpiToolsItems -SearchFor printermodel -SearchType contains -SearchValue $PrinterModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}