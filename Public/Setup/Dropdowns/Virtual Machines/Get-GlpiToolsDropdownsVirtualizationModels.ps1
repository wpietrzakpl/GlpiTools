<#
.SYNOPSIS
    Function is getting Virtualization Models informations from GLPI
.DESCRIPTION
    Function is based on VirtualizationModelId which you can find in GLPI website
    Returns object with property's of Virtualization Models
.PARAMETER All
    This parameter will return all Virtualization Models from GLPI
.PARAMETER VirtualizationModelId
    This parameter can take pipeline input, either, you can use this function with -VirtualizationModelId keyword.
    Provide to this param VirtualizationModelId from GLPI Virtualization Models Bookmark
.PARAMETER Raw
    Parameter which you can use with VirtualizationModelId Parameter.
    VirtualizationModelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER VirtualizationModelName
    This parameter can take pipeline input, either, you can use this function with -VirtualizationModelId keyword.
    Provide to this param Virtualization Models Name from GLPI Virtualization Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVirtualizationModels -All
    Example will return all Virtualization Models from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsVirtualizationModels
    Function gets VirtualizationModelId from GLPI from pipeline, and return Virtualization Models object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsVirtualizationModels
    Function gets VirtualizationModelId from GLPI from pipeline (u can pass many ID's like that), and return Virtualization Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVirtualizationModels -VirtualizationModelId 326
    Function gets VirtualizationModelId from GLPI which is provided through -VirtualizationModelId after Function type, and return Virtualization Models object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsVirtualizationModels -VirtualizationModelId 326, 321
    Function gets Virtualization Models Id from GLPI which is provided through -VirtualizationModelId keyword after Function type (u can provide many ID's like that), and return Virtualization Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVirtualizationModels -VirtualizationModelName Fusion
    Example will return glpi Virtualization Models, but what is the most important, Virtualization Models will be shown exactly as you see in glpi dropdown Virtualization Models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Virtualization Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Virtualization Models from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsVirtualizationModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "VirtualizationModelId")]
        [alias('VMID')]
        [string[]]$VirtualizationModelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "VirtualizationModelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "VirtualizationModelName")]
        [alias('VMN')]
        [string]$VirtualizationModelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $VirtualizationModelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/virtualmachinesystem/?range=0-9999999999999"
                }
                
                $VirtualizationModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($VirtualizationModel in $VirtualizationModelsAll) {
                    $VirtualizationModelHash = [ordered]@{ }
                    $VirtualizationModelProperties = $VirtualizationModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($VirtualizationModelProp in $VirtualizationModelProperties) {
                        $VirtualizationModelHash.Add($VirtualizationModelProp.Name, $VirtualizationModelProp.Value)
                    }
                    $object = [pscustomobject]$VirtualizationModelHash
                    $VirtualizationModelsArray.Add($object)
                }
                $VirtualizationModelsArray
                $VirtualizationModelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            VirtualizationModelId { 
                foreach ( $VMId in $VirtualizationModelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/virtualmachinesystem/$($VMId)"
                    }

                    Try {
                        $VirtualizationModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $VirtualizationModelHash = [ordered]@{ }
                            $VirtualizationModelProperties = $VirtualizationModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($VirtualizationModelProp in $VirtualizationModelProperties) {
                                $VirtualizationModelHash.Add($VirtualizationModelProp.Name, $VirtualizationModelProp.Value)
                            }
                            $object = [pscustomobject]$VirtualizationModelHash
                            $VirtualizationModelsArray.Add($object)
                        } else {
                            $VirtualizationModelHash = [ordered]@{ }
                            $VirtualizationModelProperties = $VirtualizationModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($VirtualizationModelProp in $VirtualizationModelProperties) {

                                $VirtualizationModelPropNewValue = Get-GlpiToolsParameters -Parameter $VirtualizationModelProp.Name -Value $VirtualizationModelProp.Value

                                $VirtualizationModelHash.Add($VirtualizationModelProp.Name, $VirtualizationModelPropNewValue)
                            }
                            $object = [pscustomobject]$VirtualizationModelHash
                            $VirtualizationModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Virtualization Model ID = $VMId is not found"
                        
                    }
                    $VirtualizationModelsArray
                    $VirtualizationModelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            VirtualizationModelName { 
                Search-GlpiToolsItems -SearchFor virtualmachinesystem -SearchType contains -SearchValue $VirtualizationModelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}