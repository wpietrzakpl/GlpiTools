<#
.SYNOPSIS
    Function is getting Simcard Types informations from GLPI
.DESCRIPTION
    Function is based on SimcardTypeId which you can find in GLPI website
    Returns object with property's of Simcard Types
.PARAMETER All
    This parameter will return all Simcard Types from GLPI
.PARAMETER SimcardTypeId
    This parameter can take pipline input, either, you can use this function with -SimcardTypeId keyword.
    Provide to this param SimcardTypeId from GLPI Simcard Types Bookmark
.PARAMETER Raw
    Parameter which you can use with SimcardTypeId Parameter.
    SimcardTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER SimcardTypeName
    This parameter can take pipline input, either, you can use this function with -SimcardTypeId keyword.
    Provide to this param Simcard Types Name from GLPI Simcard Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSimcardTypes -All
    Example will return all Simcard Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsSimcardTypes
    Function gets SimcardTypeId from GLPI from Pipline, and return Simcard Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsSimcardTypes
    Function gets SimcardTypeId from GLPI from Pipline (u can pass many ID's like that), and return Simcard Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSimcardTypes -SimcardTypeId 326
    Function gets SimcardTypeId from GLPI which is provided through -SimcardTypeId after Function type, and return Simcard Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsSimcardTypes -SimcardTypeId 326, 321
    Function gets Simcard Types Id from GLPI which is provided through -SimcardTypeId keyword after Function type (u can provide many ID's like that), and return Simcard Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSimcardTypes -SimcardTypeName Fusion
    Example will return glpi Simcard Types, but what is the most important, Simcard Types will be shown exactly as you see in glpi dropdown Simcard Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Simcard Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Simcard Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsSimcardTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SimcardTypeId")]
        [alias('STID')]
        [string[]]$SimcardTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SimcardTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "SimcardTypeName")]
        [alias('STN')]
        [string]$SimcardTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SimcardTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceSimcardType/?range=0-9999999999999"
                }
                
                $SimcardTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($SimcardType in $SimcardTypesAll) {
                    $SimcardTypeHash = [ordered]@{ }
                    $SimcardTypeProperties = $SimcardType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SimcardTypeProp in $SimcardTypeProperties) {
                        $SimcardTypeHash.Add($SimcardTypeProp.Name, $SimcardTypeProp.Value)
                    }
                    $object = [pscustomobject]$SimcardTypeHash
                    $SimcardTypesArray.Add($object)
                }
                $SimcardTypesArray
                $SimcardTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            SimcardTypeId { 
                foreach ( $STId in $SimcardTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceSimcardType/$($STId)"
                    }

                    Try {
                        $SimcardType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SimcardTypeHash = [ordered]@{ }
                            $SimcardTypeProperties = $SimcardType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SimcardTypeProp in $SimcardTypeProperties) {
                                $SimcardTypeHash.Add($SimcardTypeProp.Name, $SimcardTypeProp.Value)
                            }
                            $object = [pscustomobject]$SimcardTypeHash
                            $SimcardTypesArray.Add($object)
                        } else {
                            $SimcardTypeHash = [ordered]@{ }
                            $SimcardTypeProperties = $SimcardType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SimcardTypeProp in $SimcardTypeProperties) {

                                $SimcardTypePropNewValue = Get-GlpiToolsParameters -Parameter $SimcardTypeProp.Name -Value $SimcardTypeProp.Value

                                $SimcardTypeHash.Add($SimcardTypeProp.Name, $SimcardTypePropNewValue)
                            }
                            $object = [pscustomobject]$SimcardTypeHash
                            $SimcardTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Simcard Type ID = $STId is not found"
                        
                    }
                    $SimcardTypesArray
                    $SimcardTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            SimcardTypeName { 
                Search-GlpiToolsItems -SearchFor DeviceSimcardType -SearchType contains -SearchValue $SimcardTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}