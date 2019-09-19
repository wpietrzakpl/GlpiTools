<#
.SYNOPSIS
    Function is getting Phones Power Supply Types informations from GLPI
.DESCRIPTION
    Function is based on PhonePowerSupplyTypeId which you can find in GLPI website
    Returns object with property's of Phones Power Supply Types
.PARAMETER All
    This parameter will return all Phones Power Supply Types from GLPI
.PARAMETER PhonePowerSupplyTypeId
    This parameter can take pipline input, either, you can use this function with -PhonePowerSupplyTypeId keyword.
    Provide to this param PhonePowerSupplyTypeId from GLPI Phones Power Supply Types Bookmark
.PARAMETER Raw
    Parameter which you can use with PhonePowerSupplyTypeId Parameter.
    PhonePowerSupplyTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PhonePowerSupplyTypeName
    This parameter can take pipline input, either, you can use this function with -PhonePowerSupplyTypeId keyword.
    Provide to this param Phones Power Supply Types Name from GLPI Phones Power Supply Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhonesPowerSupplyTypes -All
    Example will return all Phones Power Supply Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPhonesPowerSupplyTypes
    Function gets PhonePowerSupplyTypeId from GLPI from Pipline, and return Phones Power Supply Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPhonesPowerSupplyTypes
    Function gets PhonePowerSupplyTypeId from GLPI from Pipline (u can pass many ID's like that), and return Phones Power Supply Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhonesPowerSupplyTypes -PhonePowerSupplyTypeId 326
    Function gets PhonePowerSupplyTypeId from GLPI which is provided through -PhonePowerSupplyTypeId after Function type, and return Phones Power Supply Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPhonesPowerSupplyTypes -PhonePowerSupplyTypeId 326, 321
    Function gets Phones Power Supply Types Id from GLPI which is provided through -PhonePowerSupplyTypeId keyword after Function type (u can provide many ID's like that), and return Phones Power Supply Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhonesPowerSupplyTypes -PhonePowerSupplyTypeName Fusion
    Example will return glpi Phones Power Supply Types, but what is the most important, Phones Power Supply Types will be shown exactly as you see in glpi dropdown Phones Power Supply Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Phones Power Supply Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Phones Power Supply Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPhonesPowerSupplyTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PhonePowerSupplyTypeId")]
        [alias('PPSTID')]
        [string[]]$PhonePowerSupplyTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PhonePowerSupplyTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PhonePowerSupplyTypeName")]
        [alias('PPSTN')]
        [string]$PhonePowerSupplyTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PhonesPowerSupplyTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/phonepowersupply/?range=0-9999999999999"
                }
                
                $PhonesPowerSupplyTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PhonePowerSupplyType in $PhonesPowerSupplyTypesAll) {
                    $PhonePowerSupplyTypeHash = [ordered]@{ }
                    $PhonePowerSupplyTypeProperties = $PhonePowerSupplyType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PhonePowerSupplyTypeProp in $PhonePowerSupplyTypeProperties) {
                        $PhonePowerSupplyTypeHash.Add($PhonePowerSupplyTypeProp.Name, $PhonePowerSupplyTypeProp.Value)
                    }
                    $object = [pscustomobject]$PhonePowerSupplyTypeHash
                    $PhonesPowerSupplyTypesArray.Add($object)
                }
                $PhonesPowerSupplyTypesArray
                $PhonesPowerSupplyTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PhonePowerSupplyTypeId { 
                foreach ( $PPSTId in $PhonePowerSupplyTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/phonepowersupply/$($PPSTId)"
                    }

                    Try {
                        $PhonePowerSupplyType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PhonePowerSupplyTypeHash = [ordered]@{ }
                            $PhonePowerSupplyTypeProperties = $PhonePowerSupplyType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhonePowerSupplyTypeProp in $PhonePowerSupplyTypeProperties) {
                                $PhonePowerSupplyTypeHash.Add($PhonePowerSupplyTypeProp.Name, $PhonePowerSupplyTypeProp.Value)
                            }
                            $object = [pscustomobject]$PhonePowerSupplyTypeHash
                            $PhonesPowerSupplyTypesArray.Add($object)
                        } else {
                            $PhonePowerSupplyTypeHash = [ordered]@{ }
                            $PhonePowerSupplyTypeProperties = $PhonePowerSupplyType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhonePowerSupplyTypeProp in $PhonePowerSupplyTypeProperties) {

                                $PhonePowerSupplyTypePropNewValue = Get-GlpiToolsParameters -Parameter $PhonePowerSupplyTypeProp.Name -Value $PhonePowerSupplyTypeProp.Value

                                $PhonePowerSupplyTypeHash.Add($PhonePowerSupplyTypeProp.Name, $PhonePowerSupplyTypePropNewValue)
                            }
                            $object = [pscustomobject]$PhonePowerSupplyTypeHash
                            $PhonesPowerSupplyTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Phone Power Supply Type ID = $PPSTId is not found"
                        
                    }
                    $PhonesPowerSupplyTypesArray
                    $PhonesPowerSupplyTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PhonePowerSupplyTypeName { 
                Search-GlpiToolsItems -SearchFor phonepowersupply -SearchType contains -SearchValue $PhonePowerSupplyTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}