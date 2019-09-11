<#
.SYNOPSIS
    Function is getting Rack Models informations from GLPI
.DESCRIPTION
    Function is based on RackModelId which you can find in GLPI website
    Returns object with property's of Rack Models
.PARAMETER All
    This parameter will return all Rack Models from GLPI
.PARAMETER RackModelId
    This parameter can take pipline input, either, you can use this function with -RackModelId keyword.
    Provide to this param RackModelId from GLPI Rack Models Bookmark
.PARAMETER Raw
    Parameter which you can use with RackModelId Parameter.
    RackModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER RackModelName
    This parameter can take pipline input, either, you can use this function with -RackModelId keyword.
    Provide to this param Rack Models Name from GLPI Rack Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRackModels -All
    Example will return all Rack Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsRackModels
    Function gets RackModelId from GLPI from Pipline, and return Rack Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsRackModels
    Function gets RackModelId from GLPI from Pipline (u can pass many ID's like that), and return Rack Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRackModels -RackModelId 326
    Function gets RackModelId from GLPI which is provided through -RackModelId after Function type, and return Rack Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsRackModels -RackModelId 326, 321
    Function gets Rack Models Id from GLPI which is provided through -RackModelId keyword after Function type (u can provide many ID's like that), and return Rack Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRackModels -RackModelName Fusion
    Example will return glpi Rack Models, but what is the most important, Rack Models will be shown exactly as you see in glpi dropdown Rack Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Rack Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Rack Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsRackModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "RackModelId")]
        [alias('RMID')]
        [string[]]$RackModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "RackModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "RackModelName")]
        [alias('RMN')]
        [string]$RackModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $RackModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/rackmodel/?range=0-9999999999999"
                }
                
                $RackModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($RackModel in $RackModelsAll) {
                    $RackModelHash = [ordered]@{ }
                    $RackModelProperties = $RackModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($RackModelProp in $RackModelProperties) {
                        $RackModelHash.Add($RackModelProp.Name, $RackModelProp.Value)
                    }
                    $object = [pscustomobject]$RackModelHash
                    $RackModelsArray.Add($object)
                }
                $RackModelsArray
                $RackModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            RackModelId { 
                foreach ( $RMId in $RackModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/rackmodel/$($RMId)"
                    }

                    Try {
                        $RackModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $RackModelHash = [ordered]@{ }
                            $RackModelProperties = $RackModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RackModelProp in $RackModelProperties) {
                                $RackModelHash.Add($RackModelProp.Name, $RackModelProp.Value)
                            }
                            $object = [pscustomobject]$RackModelHash
                            $RackModelsArray.Add($object)
                        } else {
                            $RackModelHash = [ordered]@{ }
                            $RackModelProperties = $RackModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RackModelProp in $RackModelProperties) {

                                $RackModelPropNewValue = Get-GlpiToolsParameters -Parameter $RackModelProp.Name -Value $RackModelProp.Value

                                $RackModelHash.Add($RackModelProp.Name, $RackModelPropNewValue)
                            }
                            $object = [pscustomobject]$RackModelHash
                            $RackModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Rack Model ID = $RMId is not found"
                        
                    }
                    $RackModelsArray
                    $RackModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            RackModelName { 
                Search-GlpiToolsItems -SearchFor rackmodel -SearchType contains -SearchValue $RackModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}