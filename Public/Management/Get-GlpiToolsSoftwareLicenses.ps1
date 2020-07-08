<#
.SYNOPSIS
    Function is getting Software License informations from GLPI
.DESCRIPTION
    Function is based on SoftwareLicenseId which you can find in GLPI website
    Returns object with property's of Software License
.PARAMETER All
    This parameter will return all Software License from GLPI
.PARAMETER SoftwareLicenseId
    This parameter can take pipline input, either, you can use this function with -SoftwareLicenseId keyword.
    Provide to this param SoftwareLicenseId from GLPI Software License Bookmark
.PARAMETER Raw
    Parameter which you can use with SoftwareLicenseId Parameter.
    SoftwareLicenseId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER SoftwareLicenseName
    This parameter can take pipline input, either, you can use this function with -SoftwareLicenseId keyword.
    Provide to this param Software License Name from GLPI Software License Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsSoftwareLicenses -All
    Example will return all Software License from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsSoftwareLicenses
    Function gets SoftwareLicenseId from GLPI from Pipline, and return Software License object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsSoftwareLicenses
    Function gets SoftwareLicenseId from GLPI from Pipline (u can pass many ID's like that), and return Software License object
.EXAMPLE
    PS C:\> Get-GlpiToolsSoftwareLicenses -SoftwareLicenseId 326
    Function gets SoftwareLicenseId from GLPI which is provided through -SoftwareLicenseId after Function type, and return Software License object
.EXAMPLE 
    PS C:\> Get-GlpiToolsSoftwareLicenses -SoftwareLicenseId 326, 321
    Function gets Software License Id from GLPI which is provided through -SoftwareLicenseId keyword after Function type (u can provide many ID's like that), and return Software License object
.EXAMPLE
    PS C:\> Get-GlpiToolsSoftwareLicenses -SoftwareLicenseName Fusion
    Example will return glpi Software License, but what is the most important, Software License will be shown exactly as you see in glpi dropdown Software License.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Software License ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Software License from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsSoftwareLicenses {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SoftwareLicenseId")]
        [alias('SLID')]
        [string[]]$SoftwareLicenseId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SoftwareLicenseId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "SoftwareLicenseName")]
        [alias('SLN')]
        [string]$SoftwareLicenseName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SoftwareLicenseArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/softwarelicense/?range=0-9999999999999"
                }
                
                $SoftwareLicensesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($SoftwareLicense in $SoftwareLicensesAll) {
                    $SoftwareLicenseHash = [ordered]@{ }
                    $SoftwareLicenseProperties = $SoftwareLicense.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SoftwareLicenseProp in $SoftwareLicenseProperties) {
                        $SoftwareLicenseHash.Add($SoftwareLicenseProp.Name, $SoftwareLicenseProp.Value)
                    }
                    $object = [pscustomobject]$SoftwareLicenseHash
                    $SoftwareLicenseArray.Add($object)
                }
                $SoftwareLicenseArray
                $SoftwareLicenseArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            SoftwareLicenseId { 
                foreach ( $SLId in $SoftwareLicenseId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/softwarelicense/$($SLId)"
                    }

                    Try {
                        $SoftwareLicense = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SoftwareLicenseHash = [ordered]@{ }
                            $SoftwareLicenseProperties = $SoftwareLicense.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SoftwareLicenseProp in $SoftwareLicenseProperties) {
                                $SoftwareLicenseHash.Add($SoftwareLicenseProp.Name, $SoftwareLicenseProp.Value)
                            }
                            $object = [pscustomobject]$SoftwareLicenseHash
                            $SoftwareLicenseArray.Add($object)
                        } else {
                            $SoftwareLicenseHash = [ordered]@{ }
                            $SoftwareLicenseProperties = $SoftwareLicense.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SoftwareLicenseProp in $SoftwareLicenseProperties) {

                                $SoftwareLicensePropNewValue = Get-GlpiToolsParameters -Parameter $SoftwareLicenseProp.Name -Value $SoftwareLicenseProp.Value

                                $SoftwareLicenseHash.Add($SoftwareLicenseProp.Name, $SoftwareLicensePropNewValue)
                            }
                            $object = [pscustomobject]$SoftwareLicenseHash
                            $SoftwareLicenseArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Software License ID = $SLId is not found"
                        
                    }
                    $SoftwareLicenseArray
                    $SoftwareLicenseArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            SoftwareLicenseName { 
                Search-GlpiToolsItems -SearchFor softwarelicense -SearchType contains -SearchValue $SoftwareLicenseName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}