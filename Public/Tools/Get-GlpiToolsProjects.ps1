<#
.SYNOPSIS
    Function is getting Projects informations from GLPI
.DESCRIPTION
    Function is based on ProjectId which you can find in GLPI website
    Returns object with property's of Projects
.PARAMETER All
    This parameter will return all Projects from GLPI
.PARAMETER ProjectId
    This parameter can take pipline input, either, you can use this function with -ProjectId keyword.
    Provide to this param ProjectId from GLPI Projects Bookmark
.PARAMETER Raw
    Parameter which you can use with ProjectId Parameter.
    ProjectId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProjectName
    This parameter can take pipline input, either, you can use this function with -ProjectId keyword.
    Provide to this param Projects Name from GLPI Projects Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsProjects -All
    Example will return all Projects from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsProjects
    Function gets ProjectId from GLPI from Pipline, and return Projects object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsProjects
    Function gets ProjectId from GLPI from Pipline (u can pass many ID's like that), and return Projects object
.EXAMPLE
    PS C:\> Get-GlpiToolsProjects -ProjectId 326
    Function gets ProjectId from GLPI which is provided through -ProjectId after Function type, and return Projects object
.EXAMPLE 
    PS C:\> Get-GlpiToolsProjects -ProjectId 326, 321
    Function gets Projects Id from GLPI which is provided through -ProjectId keyword after Function type (u can provide many ID's like that), and return Projects object
.EXAMPLE
    PS C:\> Get-GlpiToolsProjects -ProjectName Fusion
    Example will return glpi Projects, but what is the most important, Projects will be shown exactly as you see in glpi dropdown Projects.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Projects ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Projects from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsProjects {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProjectId")]
        [alias('PID')]
        [string[]]$ProjectId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ProjectName")]
        [alias('PN')]
        [string]$ProjectName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ProjectsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/project/?range=0-9999999999999"
                }
                
                $ProjectsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Project in $ProjectsAll) {
                    $ProjectHash = [ordered]@{ }
                    $ProjectProperties = $Project.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ProjectProp in $ProjectProperties) {
                        $ProjectHash.Add($ProjectProp.Name, $ProjectProp.Value)
                    }
                    $object = [pscustomobject]$ProjectHash
                    $ProjectsArray.Add($object)
                }
                $ProjectsArray
                $ProjectsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ProjectId { 
                foreach ( $PId in $ProjectId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/project/$($PId)"
                    }

                    Try {
                        $Project = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ProjectHash = [ordered]@{ }
                            $ProjectProperties = $Project.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectProp in $ProjectProperties) {
                                $ProjectHash.Add($ProjectProp.Name, $ProjectProp.Value)
                            }
                            $object = [pscustomobject]$ProjectHash
                            $ProjectsArray.Add($object)
                        } else {
                            $ProjectHash = [ordered]@{ }
                            $ProjectProperties = $Project.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectProp in $ProjectProperties) {

                                $ProjectPropNewValue = Get-GlpiToolsParameters -Parameter $ProjectProp.Name -Value $ProjectProp.Value

                                $ProjectHash.Add($ProjectProp.Name, $ProjectPropNewValue)
                            }
                            $object = [pscustomobject]$ProjectHash
                            $ProjectsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Project ID = $PId is not found"
                        
                    }
                    $ProjectsArray
                    $ProjectsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ProjectName { 
                Search-GlpiToolsItems -SearchFor project -SearchType contains -SearchValue $ProjectName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}