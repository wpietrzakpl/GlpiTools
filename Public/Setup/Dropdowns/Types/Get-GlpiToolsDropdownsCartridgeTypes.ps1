<#
.SYNOPSIS
    Function is getting Cartridge Types informations from GLPI
.DESCRIPTION
    Function is based on CartridgeTypeId which you can find in GLPI website
    Returns object with property's of Cartridge Types
.PARAMETER All
    This parameter will return all Cartridge Types from GLPI
.PARAMETER CartridgeTypeId
    This parameter can take pipline input, either, you can use this function with -CartridgeTypeId keyword.
    Provide to this param CartridgeTypeId from GLPI Cartridge Types Bookmark
.PARAMETER Raw
    Parameter which you can use with CartridgeTypeId Parameter.
    CartridgeTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER CartridgeTypeName
    This parameter can take pipline input, either, you can use this function with -CartridgeTypeId keyword.
    Provide to this param Cartridge Types Name from GLPI Cartridge Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCartridgeTypes -All
    Example will return all Cartridge Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsCartridgeTypes
    Function gets CartridgeTypeId from GLPI from Pipline, and return Cartridge Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsCartridgeTypes
    Function gets CartridgeTypeId from GLPI from Pipline (u can pass many ID's like that), and return Cartridge Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCartridgeTypes -CartridgeTypeId 326
    Function gets CartridgeTypeId from GLPI which is provided through -CartridgeTypeId after Function type, and return Cartridge Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsCartridgeTypes -CartridgeTypeId 326, 321
    Function gets Cartridge Types Id from GLPI which is provided through -CartridgeTypeId keyword after Function type (u can provide many ID's like that), and return Cartridge Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCartridgeTypes -CartridgeTypeName Fusion
    Example will return glpi Cartridge Types, but what is the most important, Cartridge Types will be shown exactly as you see in glpi dropdown Cartridge Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Cartridge Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Cartridge Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsCartridgeTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "CartridgeTypeId")]
        [alias('CTID')]
        [string[]]$CartridgeTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "CartridgeTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "CartridgeTypeName")]
        [alias('CTN')]
        [string]$CartridgeTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $CartridgeTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/cartridgeitemtype/?range=0-9999999999999"
                }
                
                $CartridgeTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($CartridgeType in $CartridgeTypesAll) {
                    $CartridgeTypeHash = [ordered]@{ }
                    $CartridgeTypeProperties = $CartridgeType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($CartridgeTypeProp in $CartridgeTypeProperties) {
                        $CartridgeTypeHash.Add($CartridgeTypeProp.Name, $CartridgeTypeProp.Value)
                    }
                    $object = [pscustomobject]$CartridgeTypeHash
                    $CartridgeTypesArray.Add($object)
                }
                $CartridgeTypesArray
                $CartridgeTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            CartridgeTypeId { 
                foreach ( $CTId in $CartridgeTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/cartridgeitemtype/$($CTId)"
                    }

                    Try {
                        $CartridgeType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $CartridgeTypeHash = [ordered]@{ }
                            $CartridgeTypeProperties = $CartridgeType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CartridgeTypeProp in $CartridgeTypeProperties) {
                                $CartridgeTypeHash.Add($CartridgeTypeProp.Name, $CartridgeTypeProp.Value)
                            }
                            $object = [pscustomobject]$CartridgeTypeHash
                            $CartridgeTypesArray.Add($object)
                        } else {
                            $CartridgeTypeHash = [ordered]@{ }
                            $CartridgeTypeProperties = $CartridgeType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CartridgeTypeProp in $CartridgeTypeProperties) {

                                $CartridgeTypePropNewValue = Get-GlpiToolsParameters -Parameter $CartridgeTypeProp.Name -Value $CartridgeTypeProp.Value

                                $CartridgeTypeHash.Add($CartridgeTypeProp.Name, $CartridgeTypePropNewValue)
                            }
                            $object = [pscustomobject]$CartridgeTypeHash
                            $CartridgeTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Cartridge Type ID = $CTId is not found"
                        
                    }
                    $CartridgeTypesArray
                    $CartridgeTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            CartridgeTypeName { 
                Search-GlpiToolsItems -SearchFor cartridgeitemtype -SearchType contains -SearchValue $CartridgeTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}