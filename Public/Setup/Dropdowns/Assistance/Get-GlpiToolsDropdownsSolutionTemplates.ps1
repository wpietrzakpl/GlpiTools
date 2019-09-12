<#
.SYNOPSIS
    Function is getting Solution Templates informations from GLPI
.DESCRIPTION
    Function is based on SolutionTemplateId which you can find in GLPI website
    Returns object with property's of Solution Templates
.PARAMETER All
    This parameter will return all Solution Templates from GLPI
.PARAMETER SolutionTemplateId
    This parameter can take pipline input, either, you can use this function with -SolutionTemplateId keyword.
    Provide to this param SolutionTemplateId from GLPI Solution Templates Bookmark
.PARAMETER Raw
    Parameter which you can use with SolutionTemplateId Parameter.
    SolutionTemplateId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER SolutionTemplateName
    This parameter can take pipline input, either, you can use this function with -SolutionTemplateId keyword.
    Provide to this param Solution Templates Name from GLPI Solution Templates Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSolutionTemplates -All
    Example will return all Solution Templates from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsSolutionTemplates
    Function gets SolutionTemplateId from GLPI from Pipline, and return Solution Templates object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsSolutionTemplates
    Function gets SolutionTemplateId from GLPI from Pipline (u can pass many ID's like that), and return Solution Templates object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSolutionTemplates -SolutionTemplateId 326
    Function gets SolutionTemplateId from GLPI which is provided through -SolutionTemplateId after Function type, and return Solution Templates object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsSolutionTemplates -SolutionTemplateId 326, 321
    Function gets Solution Templates Id from GLPI which is provided through -SolutionTemplateId keyword after Function type (u can provide many ID's like that), and return Solution Templates object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSolutionTemplates -SolutionTemplateName Fusion
    Example will return glpi Solution Templates, but what is the most important, Solution Templates will be shown exactly as you see in glpi dropdown Solution Templates.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Solution Templates ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Solution Templates from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsSolutionTemplates {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SolutionTemplateId")]
        [alias('STID')]
        [string[]]$SolutionTemplateId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SolutionTemplateId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "SolutionTemplateName")]
        [alias('STN')]
        [string]$SolutionTemplateName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SolutionTemplatesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/solutiontemplate/?range=0-9999999999999"
                }
                
                $SolutionTemplatesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($SolutionTemplate in $SolutionTemplatesAll) {
                    $SolutionTemplateHash = [ordered]@{ }
                    $SolutionTemplateProperties = $SolutionTemplate.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SolutionTemplateProp in $SolutionTemplateProperties) {
                        $SolutionTemplateHash.Add($SolutionTemplateProp.Name, $SolutionTemplateProp.Value)
                    }
                    $object = [pscustomobject]$SolutionTemplateHash
                    $SolutionTemplatesArray.Add($object)
                }
                $SolutionTemplatesArray
                $SolutionTemplatesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            SolutionTemplateId { 
                foreach ( $STId in $SolutionTemplateId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/solutiontemplate/$($STId)"
                    }

                    Try {
                        $SolutionTemplate = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SolutionTemplateHash = [ordered]@{ }
                            $SolutionTemplateProperties = $SolutionTemplate.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SolutionTemplateProp in $SolutionTemplateProperties) {
                                $SolutionTemplateHash.Add($SolutionTemplateProp.Name, $SolutionTemplateProp.Value)
                            }
                            $object = [pscustomobject]$SolutionTemplateHash
                            $SolutionTemplatesArray.Add($object)
                        } else {
                            $SolutionTemplateHash = [ordered]@{ }
                            $SolutionTemplateProperties = $SolutionTemplate.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SolutionTemplateProp in $SolutionTemplateProperties) {

                                $SolutionTemplatePropNewValue = Get-GlpiToolsParameters -Parameter $SolutionTemplateProp.Name -Value $SolutionTemplateProp.Value

                                $SolutionTemplateHash.Add($SolutionTemplateProp.Name, $SolutionTemplatePropNewValue)
                            }
                            $object = [pscustomobject]$SolutionTemplateHash
                            $SolutionTemplatesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Solution Template ID = $STId is not found"
                        
                    }
                    $SolutionTemplatesArray
                    $SolutionTemplatesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            SolutionTemplateName { 
                Search-GlpiToolsItems -SearchFor solutiontemplate -SearchType contains -SearchValue $SolutionTemplateName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}