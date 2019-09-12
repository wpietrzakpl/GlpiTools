<#
.SYNOPSIS
    Function is getting Project Types informations from GLPI
.DESCRIPTION
    Function is based on ProjectTypeId which you can find in GLPI website
    Returns object with property's of Project Types
.PARAMETER All
    This parameter will return all Project Types from GLPI
.PARAMETER ProjectTypeId
    This parameter can take pipline input, either, you can use this function with -ProjectTypeId keyword.
    Provide to this param ProjectTypeId from GLPI Project Types Bookmark
.PARAMETER Raw
    Parameter which you can use with ProjectTypeId Parameter.
    ProjectTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProjectTypeName
    This parameter can take pipline input, either, you can use this function with -ProjectTypeId keyword.
    Provide to this param Project Types Name from GLPI Project Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTypes -All
    Example will return all Project Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsProjectTypes
    Function gets ProjectTypeId from GLPI from Pipline, and return Project Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsProjectTypes
    Function gets ProjectTypeId from GLPI from Pipline (u can pass many ID's like that), and return Project Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTypes -ProjectTypeId 326
    Function gets ProjectTypeId from GLPI which is provided through -ProjectTypeId after Function type, and return Project Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsProjectTypes -ProjectTypeId 326, 321
    Function gets Project Types Id from GLPI which is provided through -ProjectTypeId keyword after Function type (u can provide many ID's like that), and return Project Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectTypes -ProjectTypeName Fusion
    Example will return glpi Project Types, but what is the most important, Project Types will be shown exactly as you see in glpi dropdown Project Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Project Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Project Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsProjectTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProjectTypeId")]
        [alias('PTID')]
        [string[]]$ProjectTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ProjectTypeName")]
        [alias('PTN')]
        [string]$ProjectTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ProjectTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/projecttype/?range=0-9999999999999"
                }
                
                $ProjectTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ProjectType in $ProjectTypesAll) {
                    $ProjectTypeHash = [ordered]@{ }
                    $ProjectTypeProperties = $ProjectType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ProjectTypeProp in $ProjectTypeProperties) {
                        $ProjectTypeHash.Add($ProjectTypeProp.Name, $ProjectTypeProp.Value)
                    }
                    $object = [pscustomobject]$ProjectTypeHash
                    $ProjectTypesArray.Add($object)
                }
                $ProjectTypesArray
                $ProjectTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ProjectTypeId { 
                foreach ( $PTId in $ProjectTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/projecttype/$($PTId)"
                    }

                    Try {
                        $ProjectType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ProjectTypeHash = [ordered]@{ }
                            $ProjectTypeProperties = $ProjectType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectTypeProp in $ProjectTypeProperties) {
                                $ProjectTypeHash.Add($ProjectTypeProp.Name, $ProjectTypeProp.Value)
                            }
                            $object = [pscustomobject]$ProjectTypeHash
                            $ProjectTypesArray.Add($object)
                        } else {
                            $ProjectTypeHash = [ordered]@{ }
                            $ProjectTypeProperties = $ProjectType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectTypeProp in $ProjectTypeProperties) {

                                $ProjectTypePropNewValue = Get-GlpiToolsParameters -Parameter $ProjectTypeProp.Name -Value $ProjectTypeProp.Value

                                $ProjectTypeHash.Add($ProjectTypeProp.Name, $ProjectTypePropNewValue)
                            }
                            $object = [pscustomobject]$ProjectTypeHash
                            $ProjectTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Project Type ID = $PTId is not found"
                        
                    }
                    $ProjectTypesArray
                    $ProjectTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ProjectTypeName { 
                Search-GlpiToolsItems -SearchFor projecttype -SearchType contains -SearchValue $ProjectTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}