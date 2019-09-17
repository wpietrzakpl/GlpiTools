<#
.SYNOPSIS
    Function is getting Contract Types informations from GLPI
.DESCRIPTION
    Function is based on ContractTypeId which you can find in GLPI website
    Returns object with property's of Contract Types
.PARAMETER All
    This parameter will return all Contract Types from GLPI
.PARAMETER ContractTypeId
    This parameter can take pipline input, either, you can use this function with -ContractTypeId keyword.
    Provide to this param ContractTypeId from GLPI Contract Types Bookmark
.PARAMETER Raw
    Parameter which you can use with ContractTypeId Parameter.
    ContractTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ContractTypeName
    This parameter can take pipline input, either, you can use this function with -ContractTypeId keyword.
    Provide to this param Contract Types Name from GLPI Contract Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsContractTypes -All
    Example will return all Contract Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsContractTypes
    Function gets ContractTypeId from GLPI from Pipline, and return Contract Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsContractTypes
    Function gets ContractTypeId from GLPI from Pipline (u can pass many ID's like that), and return Contract Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsContractTypes -ContractTypeId 326
    Function gets ContractTypeId from GLPI which is provided through -ContractTypeId after Function type, and return Contract Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsContractTypes -ContractTypeId 326, 321
    Function gets Contract Types Id from GLPI which is provided through -ContractTypeId keyword after Function type (u can provide many ID's like that), and return Contract Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsContractTypes -ContractTypeName Fusion
    Example will return glpi Contract Types, but what is the most important, Contract Types will be shown exactly as you see in glpi dropdown Contract Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Contract Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Contract Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsContractTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ContractTypeId")]
        [alias('CTID')]
        [string[]]$ContractTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ContractTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ContractTypeName")]
        [alias('CTN')]
        [string]$ContractTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ContractTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/contracttype/?range=0-9999999999999"
                }
                
                $ContractTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ContractType in $ContractTypesAll) {
                    $ContractTypeHash = [ordered]@{ }
                    $ContractTypeProperties = $ContractType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ContractTypeProp in $ContractTypeProperties) {
                        $ContractTypeHash.Add($ContractTypeProp.Name, $ContractTypeProp.Value)
                    }
                    $object = [pscustomobject]$ContractTypeHash
                    $ContractTypesArray.Add($object)
                }
                $ContractTypesArray
                $ContractTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ContractTypeId { 
                foreach ( $CTId in $ContractTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/contracttype/$($CTId)"
                    }

                    Try {
                        $ContractType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ContractTypeHash = [ordered]@{ }
                            $ContractTypeProperties = $ContractType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContractTypeProp in $ContractTypeProperties) {
                                $ContractTypeHash.Add($ContractTypeProp.Name, $ContractTypeProp.Value)
                            }
                            $object = [pscustomobject]$ContractTypeHash
                            $ContractTypesArray.Add($object)
                        } else {
                            $ContractTypeHash = [ordered]@{ }
                            $ContractTypeProperties = $ContractType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContractTypeProp in $ContractTypeProperties) {

                                $ContractTypePropNewValue = Get-GlpiToolsParameters -Parameter $ContractTypeProp.Name -Value $ContractTypeProp.Value

                                $ContractTypeHash.Add($ContractTypeProp.Name, $ContractTypePropNewValue)
                            }
                            $object = [pscustomobject]$ContractTypeHash
                            $ContractTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Contract Type ID = $CTId is not found"
                        
                    }
                    $ContractTypesArray
                    $ContractTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ContractTypeName { 
                Search-GlpiToolsItems -SearchFor contracttype -SearchType contains -SearchValue $ContractTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}