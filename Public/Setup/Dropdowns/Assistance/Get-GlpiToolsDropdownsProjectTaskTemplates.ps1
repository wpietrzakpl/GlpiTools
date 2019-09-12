<#
.SYNOPSIS
    Function is getting Project Task Templates informations from GLPI
.DESCRIPTION
    Function is based on ProjectTaskTemplateId which you can find in GLPI website
    Returns object with property's of Project Task Templates
.PARAMETER All
    This parameter will return all Project Task Templates from GLPI
.PARAMETER ProjectTaskTemplateId
    This parameter can take pipline input, either, you can use this function with -ProjectTaskTemplateId keyword.
    Provide to this param ProjectTaskTemplateId from GLPI Project Task Templates Bookmark
.PARAMETER Raw
    Parameter which you can use with ProjectTaskTemplateId Parameter.
    ProjectTaskTemplateId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProjectTaskTemplateName
    This parameter can take pipline input, either, you can use this function with -ProjectTaskTemplateId keyword.
    Provide to this param Project Task Templates Name from GLPI Project Task Templates Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTaskTemplates -All
    Example will return all Project Task Templates from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsProjectTaskTemplates
    Function gets ProjectTaskTemplateId from GLPI from Pipline, and return Project Task Templates object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsProjectTaskTemplates
    Function gets ProjectTaskTemplateId from GLPI from Pipline (u can pass many ID's like that), and return Project Task Templates object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTaskTemplates -ProjectTaskTemplateId 326
    Function gets ProjectTaskTemplateId from GLPI which is provided through -ProjectTaskTemplateId after Function type, and return Project Task Templates object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsProjectTaskTemplates -ProjectTaskTemplateId 326, 321
    Function gets Project Task Templates Id from GLPI which is provided through -ProjectTaskTemplateId keyword after Function type (u can provide many ID's like that), and return Project Task Templates object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTaskTemplates -ProjectTaskTemplateName Fusion
    Example will return glpi Project Task Templates, but what is the most important, Project Task Templates will be shown exactly as you see in glpi dropdown Project Task Templates.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Project Task Templates ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Project Task Templates from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsProjectTaskTemplates {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProjectTaskTemplateId")]
        [alias('PTTID')]
        [string[]]$ProjectTaskTemplateId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectTaskTemplateId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ProjectTaskTemplateName")]
        [alias('PTTN')]
        [string]$ProjectTaskTemplateName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ProjectTaskTemplatesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/projecttasktemplate/?range=0-9999999999999"
                }
                
                $ProjectTaskTemplatesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ProjectTaskTemplate in $ProjectTaskTemplatesAll) {
                    $ProjectTaskTemplateHash = [ordered]@{ }
                    $ProjectTaskTemplateProperties = $ProjectTaskTemplate.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ProjectTaskTemplateProp in $ProjectTaskTemplateProperties) {
                        $ProjectTaskTemplateHash.Add($ProjectTaskTemplateProp.Name, $ProjectTaskTemplateProp.Value)
                    }
                    $object = [pscustomobject]$ProjectTaskTemplateHash
                    $ProjectTaskTemplatesArray.Add($object)
                }
                $ProjectTaskTemplatesArray
                $ProjectTaskTemplatesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ProjectTaskTemplateId { 
                foreach ( $PTTId in $ProjectTaskTemplateId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/projecttasktemplate/$($PTTId)"
                    }

                    Try {
                        $ProjectTaskTemplate = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ProjectTaskTemplateHash = [ordered]@{ }
                            $ProjectTaskTemplateProperties = $ProjectTaskTemplate.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectTaskTemplateProp in $ProjectTaskTemplateProperties) {
                                $ProjectTaskTemplateHash.Add($ProjectTaskTemplateProp.Name, $ProjectTaskTemplateProp.Value)
                            }
                            $object = [pscustomobject]$ProjectTaskTemplateHash
                            $ProjectTaskTemplatesArray.Add($object)
                        } else {
                            $ProjectTaskTemplateHash = [ordered]@{ }
                            $ProjectTaskTemplateProperties = $ProjectTaskTemplate.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectTaskTemplateProp in $ProjectTaskTemplateProperties) {

                                $ProjectTaskTemplatePropNewValue = Get-GlpiToolsParameters -Parameter $ProjectTaskTemplateProp.Name -Value $ProjectTaskTemplateProp.Value

                                $ProjectTaskTemplateHash.Add($ProjectTaskTemplateProp.Name, $ProjectTaskTemplatePropNewValue)
                            }
                            $object = [pscustomobject]$ProjectTaskTemplateHash
                            $ProjectTaskTemplatesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Project Task Template ID = $PTTId is not found"
                        
                    }
                    $ProjectTaskTemplatesArray
                    $ProjectTaskTemplatesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ProjectTaskTemplateName { 
                Search-GlpiToolsItems -SearchFor projecttasktemplate -SearchType contains -SearchValue $ProjectTaskTemplateName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}