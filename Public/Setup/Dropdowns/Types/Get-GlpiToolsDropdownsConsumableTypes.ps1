<#
.SYNOPSIS
    Function is getting Consumable Types informations from GLPI
.DESCRIPTION
    Function is based on ConsumableTypeId which you can find in GLPI website
    Returns object with property's of Consumable Types
.PARAMETER All
    This parameter will return all Consumable Types from GLPI
.PARAMETER ConsumableTypeId
    This parameter can take pipline input, either, you can use this function with -ConsumableTypeId keyword.
    Provide to this param ConsumableTypeId from GLPI Consumable Types Bookmark
.PARAMETER Raw
    Parameter which you can use with ConsumableTypeId Parameter.
    ConsumableTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ConsumableTypeName
    This parameter can take pipline input, either, you can use this function with -ConsumableTypeId keyword.
    Provide to this param Consumable Types Name from GLPI Consumable Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsConsumableTypes -All
    Example will return all Consumable Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsConsumableTypes
    Function gets ConsumableTypeId from GLPI from Pipline, and return Consumable Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsConsumableTypes
    Function gets ConsumableTypeId from GLPI from Pipline (u can pass many ID's like that), and return Consumable Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsConsumableTypes -ConsumableTypeId 326
    Function gets ConsumableTypeId from GLPI which is provided through -ConsumableTypeId after Function type, and return Consumable Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsConsumableTypes -ConsumableTypeId 326, 321
    Function gets Consumable Types Id from GLPI which is provided through -ConsumableTypeId keyword after Function type (u can provide many ID's like that), and return Consumable Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsConsumableTypes -ConsumableTypeName Fusion
    Example will return glpi Consumable Types, but what is the most important, Consumable Types will be shown exactly as you see in glpi dropdown Consumable Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Consumable Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Consumable Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsConsumableTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ConsumableTypeId")]
        [alias('CTID')]
        [string[]]$ConsumableTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ConsumableTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ConsumableTypeName")]
        [alias('CTN')]
        [string]$ConsumableTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ConsumableTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/consumableitemtype/?range=0-9999999999999"
                }
                
                $ConsumableTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ConsumableType in $ConsumableTypesAll) {
                    $ConsumableTypeHash = [ordered]@{ }
                    $ConsumableTypeProperties = $ConsumableType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ConsumableTypeProp in $ConsumableTypeProperties) {
                        $ConsumableTypeHash.Add($ConsumableTypeProp.Name, $ConsumableTypeProp.Value)
                    }
                    $object = [pscustomobject]$ConsumableTypeHash
                    $ConsumableTypesArray.Add($object)
                }
                $ConsumableTypesArray
                $ConsumableTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ConsumableTypeId { 
                foreach ( $CTId in $ConsumableTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/consumableitemtype/$($CTId)"
                    }

                    Try {
                        $ConsumableType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ConsumableTypeHash = [ordered]@{ }
                            $ConsumableTypeProperties = $ConsumableType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ConsumableTypeProp in $ConsumableTypeProperties) {
                                $ConsumableTypeHash.Add($ConsumableTypeProp.Name, $ConsumableTypeProp.Value)
                            }
                            $object = [pscustomobject]$ConsumableTypeHash
                            $ConsumableTypesArray.Add($object)
                        } else {
                            $ConsumableTypeHash = [ordered]@{ }
                            $ConsumableTypeProperties = $ConsumableType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ConsumableTypeProp in $ConsumableTypeProperties) {

                                $ConsumableTypePropNewValue = Get-GlpiToolsParameters -Parameter $ConsumableTypeProp.Name -Value $ConsumableTypeProp.Value

                                $ConsumableTypeHash.Add($ConsumableTypeProp.Name, $ConsumableTypePropNewValue)
                            }
                            $object = [pscustomobject]$ConsumableTypeHash
                            $ConsumableTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Consumable Type ID = $CTId is not found"
                        
                    }
                    $ConsumableTypesArray
                    $ConsumableTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ConsumableTypeName { 
                Search-GlpiToolsItems -SearchFor consumableitemtype -SearchType contains -SearchValue $ConsumableTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}