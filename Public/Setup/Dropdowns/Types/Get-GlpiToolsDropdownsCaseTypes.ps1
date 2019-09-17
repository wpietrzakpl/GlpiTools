<#
.SYNOPSIS
    Function is getting Case Types informations from GLPI
.DESCRIPTION
    Function is based on CaseTypeId which you can find in GLPI website
    Returns object with property's of Case Types
.PARAMETER All
    This parameter will return all Case Types from GLPI
.PARAMETER CaseTypeId
    This parameter can take pipline input, either, you can use this function with -CaseTypeId keyword.
    Provide to this param CaseTypeId from GLPI Case Types Bookmark
.PARAMETER Raw
    Parameter which you can use with CaseTypeId Parameter.
    CaseTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER CaseTypeName
    This parameter can take pipline input, either, you can use this function with -CaseTypeId keyword.
    Provide to this param Case Types Name from GLPI Case Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCaseTypes -All
    Example will return all Case Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsCaseTypes
    Function gets CaseTypeId from GLPI from Pipline, and return Case Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsCaseTypes
    Function gets CaseTypeId from GLPI from Pipline (u can pass many ID's like that), and return Case Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCaseTypes -CaseTypeId 326
    Function gets CaseTypeId from GLPI which is provided through -CaseTypeId after Function type, and return Case Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsCaseTypes -CaseTypeId 326, 321
    Function gets Case Types Id from GLPI which is provided through -CaseTypeId keyword after Function type (u can provide many ID's like that), and return Case Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCaseTypes -CaseTypeName Fusion
    Example will return glpi Case Types, but what is the most important, Case Types will be shown exactly as you see in glpi dropdown Case Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Case Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Case Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsCaseTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "CaseTypeId")]
        [alias('CTID')]
        [string[]]$CaseTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "CaseTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "CaseTypeName")]
        [alias('CTN')]
        [string]$CaseTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $CaseTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceCaseType/?range=0-9999999999999"
                }
                
                $CaseTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($CaseType in $CaseTypesAll) {
                    $CaseTypeHash = [ordered]@{ }
                    $CaseTypeProperties = $CaseType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($CaseTypeProp in $CaseTypeProperties) {
                        $CaseTypeHash.Add($CaseTypeProp.Name, $CaseTypeProp.Value)
                    }
                    $object = [pscustomobject]$CaseTypeHash
                    $CaseTypesArray.Add($object)
                }
                $CaseTypesArray
                $CaseTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            CaseTypeId { 
                foreach ( $CTId in $CaseTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceCaseType/$($CTId)"
                    }

                    Try {
                        $CaseType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $CaseTypeHash = [ordered]@{ }
                            $CaseTypeProperties = $CaseType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CaseTypeProp in $CaseTypeProperties) {
                                $CaseTypeHash.Add($CaseTypeProp.Name, $CaseTypeProp.Value)
                            }
                            $object = [pscustomobject]$CaseTypeHash
                            $CaseTypesArray.Add($object)
                        } else {
                            $CaseTypeHash = [ordered]@{ }
                            $CaseTypeProperties = $CaseType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CaseTypeProp in $CaseTypeProperties) {

                                $CaseTypePropNewValue = Get-GlpiToolsParameters -Parameter $CaseTypeProp.Name -Value $CaseTypeProp.Value

                                $CaseTypeHash.Add($CaseTypeProp.Name, $CaseTypePropNewValue)
                            }
                            $object = [pscustomobject]$CaseTypeHash
                            $CaseTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Case Type ID = $CTId is not found"
                        
                    }
                    $CaseTypesArray
                    $CaseTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            CaseTypeName { 
                Search-GlpiToolsItems -SearchFor DeviceCaseType -SearchType contains -SearchValue $CaseTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}