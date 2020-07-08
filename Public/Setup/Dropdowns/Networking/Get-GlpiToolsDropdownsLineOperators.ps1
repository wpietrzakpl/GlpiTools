<#
.SYNOPSIS
    Function is getting Line Operators informations from GLPI
.DESCRIPTION
    Function is based on LineOperatorId which you can find in GLPI website
    Returns object with property's of Line Operators
.PARAMETER All
    This parameter will return all Line Operators from GLPI
.PARAMETER LineOperatorId
    This parameter can take pipeline input, either, you can use this function with -LineOperatorId keyword.
    Provide to this param LineOperatorId from GLPI Line Operators Bookmark
.PARAMETER Raw
    Parameter which you can use with LineOperatorId Parameter.
    LineOperatorId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER LineOperatorName
    This parameter can take pipeline input, either, you can use this function with -LineOperatorId keyword.
    Provide to this param Line Operators Name from GLPI Line Operators Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLineOperators -All
    Example will return all Line Operators from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsLineOperators
    Function gets LineOperatorId from GLPI from pipeline, and return Line Operators object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsLineOperators
    Function gets LineOperatorId from GLPI from pipeline (u can pass many ID's like that), and return Line Operators object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLineOperators -LineOperatorId 326
    Function gets LineOperatorId from GLPI which is provided through -LineOperatorId after Function type, and return Line Operators object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsLineOperators -LineOperatorId 326, 321
    Function gets Line Operators Id from GLPI which is provided through -LineOperatorId keyword after Function type (u can provide many ID's like that), and return Line Operators object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLineOperators -LineOperatorName Fusion
    Example will return glpi Line Operators, but what is the most important, Line Operators will be shown exactly as you see in glpi dropdown Line Operators.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Line Operators ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Line Operators from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsLineOperators {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "LineOperatorId")]
        [alias('LOID')]
        [string[]]$LineOperatorId,
        [parameter(Mandatory = $false,
            ParameterSetName = "LineOperatorId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "LineOperatorName")]
        [alias('LON')]
        [string]$LineOperatorName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $LineOperatorsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/lineoperator/?range=0-9999999999999"
                }
                
                $LineOperatorsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($LineOperator in $LineOperatorsAll) {
                    $LineOperatorHash = [ordered]@{ }
                    $LineOperatorProperties = $LineOperator.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($LineOperatorProp in $LineOperatorProperties) {
                        $LineOperatorHash.Add($LineOperatorProp.Name, $LineOperatorProp.Value)
                    }
                    $object = [pscustomobject]$LineOperatorHash
                    $LineOperatorsArray.Add($object)
                }
                $LineOperatorsArray
                $LineOperatorsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            LineOperatorId { 
                foreach ( $LOId in $LineOperatorId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/lineoperator/$($LOId)"
                    }

                    Try {
                        $LineOperator = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $LineOperatorHash = [ordered]@{ }
                            $LineOperatorProperties = $LineOperator.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($LineOperatorProp in $LineOperatorProperties) {
                                $LineOperatorHash.Add($LineOperatorProp.Name, $LineOperatorProp.Value)
                            }
                            $object = [pscustomobject]$LineOperatorHash
                            $LineOperatorsArray.Add($object)
                        } else {
                            $LineOperatorHash = [ordered]@{ }
                            $LineOperatorProperties = $LineOperator.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($LineOperatorProp in $LineOperatorProperties) {

                                $LineOperatorPropNewValue = Get-GlpiToolsParameters -Parameter $LineOperatorProp.Name -Value $LineOperatorProp.Value

                                $LineOperatorHash.Add($LineOperatorProp.Name, $LineOperatorPropNewValue)
                            }
                            $object = [pscustomobject]$LineOperatorHash
                            $LineOperatorsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Line Operator ID = $LOId is not found"
                        
                    }
                    $LineOperatorsArray
                    $LineOperatorsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            LineOperatorName { 
                Search-GlpiToolsItems -SearchFor lineoperator -SearchType contains -SearchValue $LineOperatorName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}