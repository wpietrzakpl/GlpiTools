<#
.SYNOPSIS
    Function is getting Third Party Types informations from GLPI
.DESCRIPTION
    Function is based on ThirdPartyTypeId which you can find in GLPI website
    Returns object with property's of Third Party Types
.PARAMETER All
    This parameter will return all Third Party Types from GLPI
.PARAMETER ThirdPartyTypeId
    This parameter can take pipline input, either, you can use this function with -ThirdPartyTypeId keyword.
    Provide to this param ThirdPartyTypeId from GLPI Third Party Types Bookmark
.PARAMETER Raw
    Parameter which you can use with ThirdPartyTypeId Parameter.
    ThirdPartyTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ThirdPartyTypeName
    This parameter can take pipline input, either, you can use this function with -ThirdPartyTypeId keyword.
    Provide to this param Third Party Types Name from GLPI Third Party Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsThirdPartyTypes -All
    Example will return all Third Party Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsThirdPartyTypes
    Function gets ThirdPartyTypeId from GLPI from Pipline, and return Third Party Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsThirdPartyTypes
    Function gets ThirdPartyTypeId from GLPI from Pipline (u can pass many ID's like that), and return Third Party Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsThirdPartyTypes -ThirdPartyTypeId 326
    Function gets ThirdPartyTypeId from GLPI which is provided through -ThirdPartyTypeId after Function type, and return Third Party Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsThirdPartyTypes -ThirdPartyTypeId 326, 321
    Function gets Third Party Types Id from GLPI which is provided through -ThirdPartyTypeId keyword after Function type (u can provide many ID's like that), and return Third Party Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsThirdPartyTypes -ThirdPartyTypeName Fusion
    Example will return glpi Third Party Types, but what is the most important, Third Party Types will be shown exactly as you see in glpi dropdown Third Party Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Third Party Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Third Party Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsThirdPartyTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ThirdPartyTypeId")]
        [alias('TPTID')]
        [string[]]$ThirdPartyTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ThirdPartyTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ThirdPartyTypeName")]
        [alias('TPTN')]
        [string]$ThirdPartyTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ThirdPartyTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/suppliertype/?range=0-9999999999999"
                }
                
                $ThirdPartyTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ThirdPartyType in $ThirdPartyTypesAll) {
                    $ThirdPartyTypeHash = [ordered]@{ }
                    $ThirdPartyTypeProperties = $ThirdPartyType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ThirdPartyTypeProp in $ThirdPartyTypeProperties) {
                        $ThirdPartyTypeHash.Add($ThirdPartyTypeProp.Name, $ThirdPartyTypeProp.Value)
                    }
                    $object = [pscustomobject]$ThirdPartyTypeHash
                    $ThirdPartyTypesArray.Add($object)
                }
                $ThirdPartyTypesArray
                $ThirdPartyTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ThirdPartyTypeId { 
                foreach ( $TPTId in $ThirdPartyTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/suppliertype/$($TPTId)"
                    }

                    Try {
                        $ThirdPartyType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ThirdPartyTypeHash = [ordered]@{ }
                            $ThirdPartyTypeProperties = $ThirdPartyType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ThirdPartyTypeProp in $ThirdPartyTypeProperties) {
                                $ThirdPartyTypeHash.Add($ThirdPartyTypeProp.Name, $ThirdPartyTypeProp.Value)
                            }
                            $object = [pscustomobject]$ThirdPartyTypeHash
                            $ThirdPartyTypesArray.Add($object)
                        } else {
                            $ThirdPartyTypeHash = [ordered]@{ }
                            $ThirdPartyTypeProperties = $ThirdPartyType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ThirdPartyTypeProp in $ThirdPartyTypeProperties) {

                                $ThirdPartyTypePropNewValue = Get-GlpiToolsParameters -Parameter $ThirdPartyTypeProp.Name -Value $ThirdPartyTypeProp.Value

                                $ThirdPartyTypeHash.Add($ThirdPartyTypeProp.Name, $ThirdPartyTypePropNewValue)
                            }
                            $object = [pscustomobject]$ThirdPartyTypeHash
                            $ThirdPartyTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Third Party Type ID = $TPTId is not found"
                        
                    }
                    $ThirdPartyTypesArray
                    $ThirdPartyTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ThirdPartyTypeName { 
                Search-GlpiToolsItems -SearchFor suppliertype -SearchType contains -SearchValue $ThirdPartyTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}