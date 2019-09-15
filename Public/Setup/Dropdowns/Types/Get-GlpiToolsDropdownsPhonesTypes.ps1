<#
.SYNOPSIS
    Function is getting Phones Types informations from GLPI
.DESCRIPTION
    Function is based on PhoneTypeId which you can find in GLPI website
    Returns object with property's of Phones Types
.PARAMETER All
    This parameter will return all Phones Types from GLPI
.PARAMETER PhoneTypeId
    This parameter can take pipline input, either, you can use this function with -PhoneTypeId keyword.
    Provide to this param PhoneTypeId from GLPI Phones Types Bookmark
.PARAMETER Raw
    Parameter which you can use with PhoneTypeId Parameter.
    PhoneTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PhoneTypeName
    This parameter can take pipline input, either, you can use this function with -PhoneTypeId keyword.
    Provide to this param Phones Types Name from GLPI Phones Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhonesTypes -All
    Example will return all Phones Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPhonesTypes
    Function gets PhoneTypeId from GLPI from Pipline, and return Phones Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPhonesTypes
    Function gets PhoneTypeId from GLPI from Pipline (u can pass many ID's like that), and return Phones Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhonesTypes -PhoneTypeId 326
    Function gets PhoneTypeId from GLPI which is provided through -PhoneTypeId after Function type, and return Phones Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPhonesTypes -PhoneTypeId 326, 321
    Function gets Phones Types Id from GLPI which is provided through -PhoneTypeId keyword after Function type (u can provide many ID's like that), and return Phones Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPhonesTypes -PhoneTypeName Fusion
    Example will return glpi Phones Types, but what is the most important, Phones Types will be shown exactly as you see in glpi dropdown Phones Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Phones Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Phones Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPhonesTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PhoneTypeId")]
        [alias('PTID')]
        [string[]]$PhoneTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PhoneTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PhoneTypeName")]
        [alias('PTN')]
        [string]$PhoneTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PhonesTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/phonetype/?range=0-9999999999999"
                }
                
                $PhonesTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PhoneType in $PhonesTypesAll) {
                    $PhoneTypeHash = [ordered]@{ }
                    $PhoneTypeProperties = $PhoneType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PhoneTypeProp in $PhoneTypeProperties) {
                        $PhoneTypeHash.Add($PhoneTypeProp.Name, $PhoneTypeProp.Value)
                    }
                    $object = [pscustomobject]$PhoneTypeHash
                    $PhonesTypesArray.Add($object)
                }
                $PhonesTypesArray
                $PhonesTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PhoneTypeId { 
                foreach ( $PTId in $PhoneTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/phonetype/$($PTId)"
                    }

                    Try {
                        $PhoneType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PhoneTypeHash = [ordered]@{ }
                            $PhoneTypeProperties = $PhoneType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhoneTypeProp in $PhoneTypeProperties) {
                                $PhoneTypeHash.Add($PhoneTypeProp.Name, $PhoneTypeProp.Value)
                            }
                            $object = [pscustomobject]$PhoneTypeHash
                            $PhonesTypesArray.Add($object)
                        } else {
                            $PhoneTypeHash = [ordered]@{ }
                            $PhoneTypeProperties = $PhoneType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhoneTypeProp in $PhoneTypeProperties) {

                                $PhoneTypePropNewValue = Get-GlpiToolsParameters -Parameter $PhoneTypeProp.Name -Value $PhoneTypeProp.Value

                                $PhoneTypeHash.Add($PhoneTypeProp.Name, $PhoneTypePropNewValue)
                            }
                            $object = [pscustomobject]$PhoneTypeHash
                            $PhonesTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Phone Type ID = $PTId is not found"
                        
                    }
                    $PhonesTypesArray
                    $PhonesTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PhoneTypeName { 
                Search-GlpiToolsItems -SearchFor phonetype -SearchType contains -SearchValue $PhoneTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}