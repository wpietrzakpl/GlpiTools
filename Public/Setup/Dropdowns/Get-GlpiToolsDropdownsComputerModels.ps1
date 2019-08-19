<#
.SYNOPSIS
    Function is getting Computer Models informations from GLPI
.DESCRIPTION
    Function is based on ComputerModelsID which you can find in GLPI website
    Returns object with property's of Computer Models
.PARAMETER All
    This parameter will return all Computer Models from GLPI
.PARAMETER ComputerModelsId
    This parameter can take pipline input, either, you can use this function with -ComputerModelsId keyword.
    Provide to this param Computer Models ID from GLPI Computer Models Bookmark
.PARAMETER Raw
    Parameter which you can use with ComputerModelsId Parameter.
    ComputerModelsId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ComputerModelsName
    This parameter can take pipline input, either, you can use this function with -ComputerModelsName keyword.
    Provide to this param Computer Models Name from GLPI Computer Models Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsComputerModels -All
    Example will return all Computer Models from Glpi
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsDropdownsComputerModels
    Function gets ComputerModelsId from GLPI from Pipline, and return Computer Models object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsDropdownsComputerModels
    Function gets ComputerModelsId from GLPI from Pipline (u can pass many ID's like that), and return Computer Models object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsComputerModels -ComputerModelsId 326
    Function gets ComputerModelsId from GLPI which is provided through -ComputerModelsId after Function type, and return Computer Models object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsComputerModels -ComputerModelsId 326, 321
    Function gets ComputerModelsId from GLPI which is provided through -ComputerModelsId keyword after Function type (u can provide many ID's like that), and return Computer Models object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsComputerModels -ComputerModelsName Lenovo
    Example will return glpi computer model, but what is the most important, computer model will be shown exactly as you see in glpi dropdown computer models.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Computer Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Computer Models from GLPI
.NOTES
    PSP 03/2019
#>

function Get-GlpiToolsDropdownsComputerModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ComputerModelsId")]
        [alias('CMID')]
        [string[]]$ComputerModelsId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ComputerModelsId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ComputerModelsName")]
        [alias('CMN')]
        [string]$ComputerModelsName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ComputerModelsArray = [System.Collections.ArrayList]::new()
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
                    uri     = "$($PathToGlpi)/ComputerModel/?range=0-9999999999999"
                }
                
                $GlpiComputerModelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiComputerModel in $GlpiComputerModelsAll) {
                    $ComputerModelHash = [ordered]@{ }
                    $ComputerModelProperties = $GlpiComputerModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComputerModelProp in $ComputerModelProperties) {
                        $ComputerModelHash.Add($ComputerModelProp.Name, $ComputerModelProp.Value)
                    }
                    $object = [pscustomobject]$ComputerModelHash
                    $ComputerModelsArray.Add($object)
                }
                $ComputerModelsArray
                $ComputerModelsArray = [System.Collections.ArrayList]::new()
            }
            ComputerModelsId { 
                foreach ( $CMId in $ComputerModelsId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/ComputerModel/$($CMId)"
                    }

                    Try {
                        $GlpiComputerModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ComputerModelHash = [ordered]@{ }
                            $ComputerModelProperties = $GlpiComputerModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerModelProp in $ComputerModelProperties) {
                                $ComputerModelHash.Add($ComputerModelProp.Name, $ComputerModelProp.Value)
                            }
                            $object = [pscustomobject]$ComputerModelHash
                            $ComputerModelsArray.Add($object)
                        } else {
                            $ComputerModelHash = [ordered]@{ }
                            $ComputerModelProperties = $GlpiComputerModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerModelProp in $ComputerModelProperties) {

                                switch ($ComputerModelProp.Name) {
                                    is_half_rack {
                                        if ($ComputerModelProp.Value -eq 0) { 
                                            $ComputerModelPropNewValue = 'No' 
                                        } else {
                                            $ComputerModelPropNewValue = 'Yes'
                                        } 
                                    }
                                    Default { $ComputerModelPropNewValue = $ComputerModelProp.Value }
                                }

                                $ComputerModelHash.Add($ComputerModelProp.Name, $ComputerModelPropNewValue)
                            }
                            $object = [pscustomobject]$ComputerModelHash
                            $ComputerModelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "ComputerModel ID = $CMId is not found"
                        
                    }
                    $ComputerModelsArray
                    $ComputerModelsArray = [System.Collections.ArrayList]::new()
                }
            }
            ComputerModelsName { 
                Search-GlpiToolsItems -SearchFor Computermodel -SearchType contains -SearchValue $ComputerModelsName 
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}