<#
.SYNOPSIS
    Function is getting Certificate Types informations from GLPI
.DESCRIPTION
    Function is based on CertificateTypeId which you can find in GLPI website
    Returns object with property's of Certificate Types
.PARAMETER All
    This parameter will return all Certificate Types from GLPI
.PARAMETER CertificateTypeId
    This parameter can take pipline input, either, you can use this function with -CertificateTypeId keyword.
    Provide to this param CertificateTypeId from GLPI Certificate Types Bookmark
.PARAMETER Raw
    Parameter which you can use with CertificateTypeId Parameter.
    CertificateTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER CertificateTypeName
    This parameter can take pipline input, either, you can use this function with -CertificateTypeId keyword.
    Provide to this param Certificate Types Name from GLPI Certificate Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCertificateTypes -All
    Example will return all Certificate Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsCertificateTypes
    Function gets CertificateTypeId from GLPI from Pipline, and return Certificate Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsCertificateTypes
    Function gets CertificateTypeId from GLPI from Pipline (u can pass many ID's like that), and return Certificate Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCertificateTypes -CertificateTypeId 326
    Function gets CertificateTypeId from GLPI which is provided through -CertificateTypeId after Function type, and return Certificate Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsCertificateTypes -CertificateTypeId 326, 321
    Function gets Certificate Types Id from GLPI which is provided through -CertificateTypeId keyword after Function type (u can provide many ID's like that), and return Certificate Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCertificateTypes -CertificateTypeName Fusion
    Example will return glpi Certificate Types, but what is the most important, Certificate Types will be shown exactly as you see in glpi dropdown Certificate Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Certificate Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Certificate Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsCertificateTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "CertificateTypeId")]
        [alias('CTID')]
        [string[]]$CertificateTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "CertificateTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "CertificateTypeName")]
        [alias('CTN')]
        [string]$CertificateTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $CertificateTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/certificatetype/?range=0-9999999999999"
                }
                
                $CertificateTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($CertificateType in $CertificateTypesAll) {
                    $CertificateTypeHash = [ordered]@{ }
                    $CertificateTypeProperties = $CertificateType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($CertificateTypeProp in $CertificateTypeProperties) {
                        $CertificateTypeHash.Add($CertificateTypeProp.Name, $CertificateTypeProp.Value)
                    }
                    $object = [pscustomobject]$CertificateTypeHash
                    $CertificateTypesArray.Add($object)
                }
                $CertificateTypesArray
                $CertificateTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            CertificateTypeId { 
                foreach ( $CTId in $CertificateTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/certificatetype/$($CTId)"
                    }

                    Try {
                        $CertificateType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $CertificateTypeHash = [ordered]@{ }
                            $CertificateTypeProperties = $CertificateType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CertificateTypeProp in $CertificateTypeProperties) {
                                $CertificateTypeHash.Add($CertificateTypeProp.Name, $CertificateTypeProp.Value)
                            }
                            $object = [pscustomobject]$CertificateTypeHash
                            $CertificateTypesArray.Add($object)
                        } else {
                            $CertificateTypeHash = [ordered]@{ }
                            $CertificateTypeProperties = $CertificateType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CertificateTypeProp in $CertificateTypeProperties) {

                                $CertificateTypePropNewValue = Get-GlpiToolsParameters -Parameter $CertificateTypeProp.Name -Value $CertificateTypeProp.Value

                                $CertificateTypeHash.Add($CertificateTypeProp.Name, $CertificateTypePropNewValue)
                            }
                            $object = [pscustomobject]$CertificateTypeHash
                            $CertificateTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Certificate Type ID = $CTId is not found"
                        
                    }
                    $CertificateTypesArray
                    $CertificateTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            CertificateTypeName { 
                Search-GlpiToolsItems -SearchFor certificatetype -SearchType contains -SearchValue $CertificateTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}