<#
.SYNOPSIS
    Function is getting License Types informations from GLPI
.DESCRIPTION
    Function is based on LicenseTypeId which you can find in GLPI website
    Returns object with property's of License Types
.PARAMETER All
    This parameter will return all License Types from GLPI
.PARAMETER LicenseTypeId
    This parameter can take pipline input, either, you can use this function with -LicenseTypeId keyword.
    Provide to this param LicenseTypeId from GLPI License Types Bookmark
.PARAMETER Raw
    Parameter which you can use with LicenseTypeId Parameter.
    LicenseTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER LicenseTypeName
    This parameter can take pipline input, either, you can use this function with -LicenseTypeId keyword.
    Provide to this param License Types Name from GLPI License Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLicenseTypes -All
    Example will return all License Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsLicenseTypes
    Function gets LicenseTypeId from GLPI from Pipline, and return License Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsLicenseTypes
    Function gets LicenseTypeId from GLPI from Pipline (u can pass many ID's like that), and return License Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLicenseTypes -LicenseTypeId 326
    Function gets LicenseTypeId from GLPI which is provided through -LicenseTypeId after Function type, and return License Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsLicenseTypes -LicenseTypeId 326, 321
    Function gets License Types Id from GLPI which is provided through -LicenseTypeId keyword after Function type (u can provide many ID's like that), and return License Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLicenseTypes -LicenseTypeName Fusion
    Example will return glpi License Types, but what is the most important, License Types will be shown exactly as you see in glpi dropdown License Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    License Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of License Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsLicenseTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "LicenseTypeId")]
        [alias('LTID')]
        [string[]]$LicenseTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "LicenseTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "LicenseTypeName")]
        [alias('LTN')]
        [string]$LicenseTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $LicenseTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/softwarelicensetype/?range=0-9999999999999"
                }
                
                $LicenseTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($LicenseType in $LicenseTypesAll) {
                    $LicenseTypeHash = [ordered]@{ }
                    $LicenseTypeProperties = $LicenseType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($LicenseTypeProp in $LicenseTypeProperties) {
                        $LicenseTypeHash.Add($LicenseTypeProp.Name, $LicenseTypeProp.Value)
                    }
                    $object = [pscustomobject]$LicenseTypeHash
                    $LicenseTypesArray.Add($object)
                }
                $LicenseTypesArray
                $LicenseTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            LicenseTypeId { 
                foreach ( $LTId in $LicenseTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/softwarelicensetype/$($LTId)"
                    }

                    Try {
                        $LicenseType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $LicenseTypeHash = [ordered]@{ }
                            $LicenseTypeProperties = $LicenseType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($LicenseTypeProp in $LicenseTypeProperties) {
                                $LicenseTypeHash.Add($LicenseTypeProp.Name, $LicenseTypeProp.Value)
                            }
                            $object = [pscustomobject]$LicenseTypeHash
                            $LicenseTypesArray.Add($object)
                        } else {
                            $LicenseTypeHash = [ordered]@{ }
                            $LicenseTypeProperties = $LicenseType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($LicenseTypeProp in $LicenseTypeProperties) {

                                $LicenseTypePropNewValue = Get-GlpiToolsParameters -Parameter $LicenseTypeProp.Name -Value $LicenseTypeProp.Value

                                $LicenseTypeHash.Add($LicenseTypeProp.Name, $LicenseTypePropNewValue)
                            }
                            $object = [pscustomobject]$LicenseTypeHash
                            $LicenseTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "License Type ID = $LTId is not found"
                        
                    }
                    $LicenseTypesArray
                    $LicenseTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            LicenseTypeName { 
                Search-GlpiToolsItems -SearchFor softwarelicensetype -SearchType contains -SearchValue $LicenseTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}