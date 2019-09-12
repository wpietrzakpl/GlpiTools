<#
.SYNOPSIS
    Function is getting Solution Types informations from GLPI
.DESCRIPTION
    Function is based on SolutionTypesId which you can find in GLPI website
    Returns object with property's of Solution Types
.PARAMETER All
    This parameter will return all Solution Types from GLPI
.PARAMETER SolutionTypesId
    This parameter can take pipline input, either, you can use this function with -SolutionTypesId keyword.
    Provide to this param SolutionTypesId from GLPI Solution Types Bookmark
.PARAMETER Raw
    Parameter which you can use with SolutionTypesId Parameter.
    SolutionTypesId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER SolutionTypesName
    This parameter can take pipline input, either, you can use this function with -SolutionTypesId keyword.
    Provide to this param Solution Types Name from GLPI Solution Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSolutionTypes -All
    Example will return all Solution Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsSolutionTypes
    Function gets SolutionTypesId from GLPI from Pipline, and return Solution Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsSolutionTypes
    Function gets SolutionTypesId from GLPI from Pipline (u can pass many ID's like that), and return Solution Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSolutionTypes -SolutionTypesId 326
    Function gets SolutionTypesId from GLPI which is provided through -SolutionTypesId after Function type, and return Solution Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsSolutionTypes -SolutionTypesId 326, 321
    Function gets Solution Types Id from GLPI which is provided through -SolutionTypesId keyword after Function type (u can provide many ID's like that), and return Solution Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSolutionTypes -SolutionTypesName Fusion
    Example will return glpi Solution Types, but what is the most important, Solution Types will be shown exactly as you see in glpi dropdown Solution Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Solution Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Solution Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsSolutionTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SolutionTypesId")]
        [alias('STID')]
        [string[]]$SolutionTypesId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SolutionTypesId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "SolutionTypesName")]
        [alias('STN')]
        [string]$SolutionTypesName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SolutionTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/solutiontype/?range=0-9999999999999"
                }
                
                $SolutionTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($SolutionType in $SolutionTypesAll) {
                    $SolutionTypeHash = [ordered]@{ }
                    $SolutionTypeProperties = $SolutionType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SolutionTypeProp in $SolutionTypeProperties) {
                        $SolutionTypeHash.Add($SolutionTypeProp.Name, $SolutionTypeProp.Value)
                    }
                    $object = [pscustomobject]$SolutionTypeHash
                    $SolutionTypesArray.Add($object)
                }
                $SolutionTypesArray
                $SolutionTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            SolutionTypesId { 
                foreach ( $STId in $SolutionTypesId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/solutiontype/$($STId)"
                    }

                    Try {
                        $SolutionType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SolutionTypeHash = [ordered]@{ }
                            $SolutionTypeProperties = $SolutionType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SolutionTypeProp in $SolutionTypeProperties) {
                                $SolutionTypeHash.Add($SolutionTypeProp.Name, $SolutionTypeProp.Value)
                            }
                            $object = [pscustomobject]$SolutionTypeHash
                            $SolutionTypesArray.Add($object)
                        } else {
                            $SolutionTypeHash = [ordered]@{ }
                            $SolutionTypeProperties = $SolutionType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SolutionTypeProp in $SolutionTypeProperties) {

                                $SolutionTypePropNewValue = Get-GlpiToolsParameters -Parameter $SolutionTypeProp.Name -Value $SolutionTypeProp.Value

                                $SolutionTypeHash.Add($SolutionTypeProp.Name, $SolutionTypePropNewValue)
                            }
                            $object = [pscustomobject]$SolutionTypeHash
                            $SolutionTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Solution Type ID = $STId is not found"
                        
                    }
                    $SolutionTypesArray
                    $SolutionTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            SolutionTypesName { 
                Search-GlpiToolsItems -SearchFor solutiontype -SearchType contains -SearchValue $SolutionTypesName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}