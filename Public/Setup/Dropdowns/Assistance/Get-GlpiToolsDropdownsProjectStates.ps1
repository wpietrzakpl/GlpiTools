<#
.SYNOPSIS
    Function is getting Project States informations from GLPI
.DESCRIPTION
    Function is based on ProjectStateId which you can find in GLPI website
    Returns object with property's of Project States
.PARAMETER All
    This parameter will return all Project States from GLPI
.PARAMETER ProjectStateId
    This parameter can take pipline input, either, you can use this function with -ProjectStateId keyword.
    Provide to this param ProjectStateId from GLPI Project States Bookmark
.PARAMETER Raw
    Parameter which you can use with ProjectStateId Parameter.
    ProjectStateId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProjectStateName
    This parameter can take pipline input, either, you can use this function with -ProjectStateId keyword.
    Provide to this param Project States Name from GLPI Project States Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectStates -All
    Example will return all Project States from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsProjectStates
    Function gets ProjectStateId from GLPI from Pipline, and return Project States object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsProjectStates
    Function gets ProjectStateId from GLPI from Pipline (u can pass many ID's like that), and return Project States object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectStates -ProjectStateId 326
    Function gets ProjectStateId from GLPI which is provided through -ProjectStateId after Function type, and return Project States object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsProjectStates -ProjectStateId 326, 321
    Function gets Project States Id from GLPI which is provided through -ProjectStateId keyword after Function type (u can provide many ID's like that), and return Project States object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsProjectStates -ProjectStateName Fusion
    Example will return glpi Project States, but what is the most important, Project States will be shown exactly as you see in glpi dropdown Project States.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Project States ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Project States from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsProjectStates {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProjectStateId")]
        [alias('PSID')]
        [string[]]$ProjectStateId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectStateId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ProjectStateName")]
        [alias('PSN')]
        [string]$ProjectStateName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ProjectStatesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/projectstate/?range=0-9999999999999"
                }
                
                $ProjectStatesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ProjectState in $ProjectStatesAll) {
                    $ProjectStateHash = [ordered]@{ }
                    $ProjectStateProperties = $ProjectState.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ProjectStateProp in $ProjectStateProperties) {
                        $ProjectStateHash.Add($ProjectStateProp.Name, $ProjectStateProp.Value)
                    }
                    $object = [pscustomobject]$ProjectStateHash
                    $ProjectStatesArray.Add($object)
                }
                $ProjectStatesArray
                $ProjectStatesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ProjectStateId { 
                foreach ( $PSId in $ProjectStateId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/projectstate/$($PSId)"
                    }

                    Try {
                        $ProjectState = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ProjectStateHash = [ordered]@{ }
                            $ProjectStateProperties = $ProjectState.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectStateProp in $ProjectStateProperties) {
                                $ProjectStateHash.Add($ProjectStateProp.Name, $ProjectStateProp.Value)
                            }
                            $object = [pscustomobject]$ProjectStateHash
                            $ProjectStatesArray.Add($object)
                        } else {
                            $ProjectStateHash = [ordered]@{ }
                            $ProjectStateProperties = $ProjectState.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectStateProp in $ProjectStateProperties) {

                                $ProjectStatePropNewValue = Get-GlpiToolsParameters -Parameter $ProjectStateProp.Name -Value $ProjectStateProp.Value

                                $ProjectStateHash.Add($ProjectStateProp.Name, $ProjectStatePropNewValue)
                            }
                            $object = [pscustomobject]$ProjectStateHash
                            $ProjectStatesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Project State ID = $PSId is not found"
                        
                    }
                    $ProjectStatesArray
                    $ProjectStatesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ProjectStateName { 
                Search-GlpiToolsItems -SearchFor projectstate -SearchType contains -SearchValue $ProjectStateName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}