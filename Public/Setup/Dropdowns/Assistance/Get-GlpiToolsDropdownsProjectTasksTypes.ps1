<#
.SYNOPSIS
    Function is getting Project Tasks Types informations from GLPI
.DESCRIPTION
    Function is based on ProjectTaskTypeId which you can find in GLPI website
    Returns object with property's of Project Tasks Types
.PARAMETER All
    This parameter will return all Project Tasks Types from GLPI
.PARAMETER ProjectTaskTypeId
    This parameter can take pipline input, either, you can use this function with -ProjectTaskTypeId keyword.
    Provide to this param ProjectTaskTypeId from GLPI Project Tasks Types Bookmark
.PARAMETER Raw
    Parameter which you can use with ProjectTaskTypeId Parameter.
    ProjectTaskTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProjectTaskTypeName
    This parameter can take pipline input, either, you can use this function with -ProjectTaskTypeId keyword.
    Provide to this param Project Tasks Types Name from GLPI Project Tasks Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTasksTypes -All
    Example will return all Project Tasks Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsProjectTasksTypes
    Function gets ProjectTaskTypeId from GLPI from Pipline, and return Project Tasks Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsProjectTasksTypes
    Function gets ProjectTaskTypeId from GLPI from Pipline (u can pass many ID's like that), and return Project Tasks Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTasksTypes -ProjectTaskTypeId 326
    Function gets ProjectTaskTypeId from GLPI which is provided through -ProjectTaskTypeId after Function type, and return Project Tasks Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsProjectTasksTypes -ProjectTaskTypeId 326, 321
    Function gets Project Tasks Types Id from GLPI which is provided through -ProjectTaskTypeId keyword after Function type (u can provide many ID's like that), and return Project Tasks Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTasksTypes -ProjectTaskTypeName Fusion
    Example will return glpi Project Tasks Types, but what is the most important, Project Tasks Types will be shown exactly as you see in glpi dropdown Project Tasks Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Project Tasks Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Project Tasks Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsProjectTasksTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProjectTaskTypeId")]
        [alias('PTTID')]
        [string[]]$ProjectTaskTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectTaskTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ProjectTaskTypeName")]
        [alias('PTTN')]
        [string]$ProjectTaskTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ProjectTasksTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/projecttasktype/?range=0-9999999999999"
                }
                
                $ProjectTasksTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ProjectTaskType in $ProjectTasksTypesAll) {
                    $ProjectTaskTypeHash = [ordered]@{ }
                    $ProjectTaskTypeProperties = $ProjectTaskType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ProjectTaskTypeProp in $ProjectTaskTypeProperties) {
                        $ProjectTaskTypeHash.Add($ProjectTaskTypeProp.Name, $ProjectTaskTypeProp.Value)
                    }
                    $object = [pscustomobject]$ProjectTaskTypeHash
                    $ProjectTasksTypesArray.Add($object)
                }
                $ProjectTasksTypesArray
                $ProjectTasksTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ProjectTaskTypeId { 
                foreach ( $PTTId in $ProjectTaskTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/projecttasktype/$($PTTId)"
                    }

                    Try {
                        $ProjectTaskType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ProjectTaskTypeHash = [ordered]@{ }
                            $ProjectTaskTypeProperties = $ProjectTaskType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectTaskTypeProp in $ProjectTaskTypeProperties) {
                                $ProjectTaskTypeHash.Add($ProjectTaskTypeProp.Name, $ProjectTaskTypeProp.Value)
                            }
                            $object = [pscustomobject]$ProjectTaskTypeHash
                            $ProjectTasksTypesArray.Add($object)
                        } else {
                            $ProjectTaskTypeHash = [ordered]@{ }
                            $ProjectTaskTypeProperties = $ProjectTaskType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectTaskTypeProp in $ProjectTaskTypeProperties) {

                                $ProjectTaskTypePropNewValue = Get-GlpiToolsParameters -Parameter $ProjectTaskTypeProp.Name -Value $ProjectTaskTypeProp.Value

                                $ProjectTaskTypeHash.Add($ProjectTaskTypeProp.Name, $ProjectTaskTypePropNewValue)
                            }
                            $object = [pscustomobject]$ProjectTaskTypeHash
                            $ProjectTasksTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Project Task Type ID = $PTTId is not found"
                        
                    }
                    $ProjectTasksTypesArray
                    $ProjectTasksTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ProjectTaskTypeName { 
                Search-GlpiToolsItems -SearchFor projecttasktype -SearchType contains -SearchValue $ProjectTaskTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}