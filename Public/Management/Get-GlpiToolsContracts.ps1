<#
.SYNOPSIS
    Function is getting Contract informations from GLPI
.DESCRIPTION
    Function is based on ContractId which you can find in GLPI website
    Returns object with property's of Contract
.PARAMETER All
    This parameter will return all Contract from GLPI
.PARAMETER ContractId
    This parameter can take pipline input, either, you can use this function with -ContractId keyword.
    Provide to this param ContractId from GLPI Contract Bookmark
.PARAMETER Raw
    Parameter which you can use with ContractId Parameter.
    ContractId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ContractName
    This parameter can take pipline input, either, you can use this function with -ContractId keyword.
    Provide to this param Contract Name from GLPI Contract Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsContracts -All
    Example will return all Contract from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsContracts
    Function gets ContractId from GLPI from Pipline, and return Contract object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsContracts
    Function gets ContractId from GLPI from Pipline (u can pass many ID's like that), and return Contract object
.EXAMPLE
    PS C:\> Get-GlpiToolsContracts -ContractId 326
    Function gets ContractId from GLPI which is provided through -ContractId after Function type, and return Contract object
.EXAMPLE 
    PS C:\> Get-GlpiToolsContracts -ContractId 326, 321
    Function gets Contract Id from GLPI which is provided through -ContractId keyword after Function type (u can provide many ID's like that), and return Contract object
.EXAMPLE
    PS C:\> Get-GlpiToolsContracts -ContractName Fusion
    Example will return glpi Contract, but what is the most important, Contract will be shown exactly as you see in glpi dropdown Contract.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Contract ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Contract from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsContracts {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ContractId")]
        [alias('CID')]
        [string[]]$ContractId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ContractId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ContractName")]
        [alias('CN')]
        [string]$ContractName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ContractsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Contract/?range=0-9999999999999"
                }
                
                $ContractsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Contract in $ContractsAll) {
                    $ContractHash = [ordered]@{ }
                    $ContractProperties = $Contract.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ContractProp in $ContractProperties) {
                        $ContractHash.Add($ContractProp.Name, $ContractProp.Value)
                    }
                    $object = [pscustomobject]$ContractHash
                    $ContractsArray.Add($object)
                }
                $ContractsArray
                $ContractsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ContractId { 
                foreach ( $CId in $ContractId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Contract/$($CId)"
                    }

                    Try {
                        $Contract = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ContractHash = [ordered]@{ }
                            $ContractProperties = $Contract.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContractProp in $ContractProperties) {
                                $ContractHash.Add($ContractProp.Name, $ContractProp.Value)
                            }
                            $object = [pscustomobject]$ContractHash
                            $ContractsArray.Add($object)
                        } else {
                            $ContractHash = [ordered]@{ }
                            $ContractProperties = $Contract.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContractProp in $ContractProperties) {

                                $ContractPropNewValue = Get-GlpiToolsParameters -Parameter $ContractProp.Name -Value $ContractProp.Value

                                $ContractHash.Add($ContractProp.Name, $ContractPropNewValue)
                            }
                            $object = [pscustomobject]$ContractHash
                            $ContractsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Contract ID = $CId is not found"
                        
                    }
                    $ContractsArray
                    $ContractsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ContractName { 
                Search-GlpiToolsItems -SearchFor Contract -SearchType contains -SearchValue $ContractName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}