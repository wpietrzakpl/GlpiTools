<#
.SYNOPSIS
    Function is getting Software Category's informations from GLPI
.DESCRIPTION
    Function is based on SoftwareCategoryId which you can find on GLPI website
    Returns object with property's of Software Category's
.PARAMETER All
    This parameter will return all Software Category's from GLPI
.PARAMETER SoftwareCategoryId
    This parameter can take pipline input, either, you can use this function with -SoftwareCategoryId keyword.
    Provide to this param Software Category ID from GLPI Software Category Bookmark
.PARAMETER SoftwareCategoryName
    You can use this function with -SoftwareCategoryName keyword.
    Provide to this param Software Category Name from GLPI Software Category Bookmark
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsDropdownsSoftwareCategory
    Function gets SoftwareCategoryId from GLPI from Pipline, and return Update Sources object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsDropdownsSoftwareCategory
    Function gets SoftwareCategoryId from GLPI from Pipline (u can pass many ID's like that), and return Software Category object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsSoftwareCategory -SoftwareCategoryId 326
    Function gets SoftwareCategoryId from GLPI which is provided through -SoftwareCategoryId after Function type, and return Software Category object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsSoftwareCategory -SoftwareCategoryId 326, 321
    Function gets SoftwareCategoryId from GLPI which is provided through -SoftwareCategoryId keyword after Function type (u can provide many ID's like that), and return Software Category object
.INPUTS
    Software Category's ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Software Category's from GLPI
.NOTES
    PSP 04/2019
#>

function Get-GlpiToolsDropdownsSoftwareCategory {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SoftwareCategoryId")]
        [alias('SCID')]
        [string[]]$SoftwareCategoryId,

        [parameter(Mandatory = $true,
            ParameterSetName = "SoftwareCategoryName")]
        [alias('SCN')]
        [string]$SoftwareCategoryName

    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SoftwareCategoryObjectArray = @()

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
                    uri     = "$($PathToGlpi)/SoftwareCategory/?range=0-99999999999"
                }
                
                $GlpiSoftwareCategoryAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiSoftwareCategory in $GlpiSoftwareCategoryAll) {
                    $SoftwareCategoryHash = [ordered]@{ }
                    $SoftwareCategoryProperties = $GlpiSoftwareCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SoftwareCategoryProp in $SoftwareCategoryProperties) {
                        $SoftwareCategoryHash.Add($SoftwareCategoryProp.Name, $SoftwareCategoryProp.Value)
                    }
                    $object = [pscustomobject]$SoftwareCategoryHash
                    $SoftwareCategoryObjectArray += $object 
                }
                $SoftwareCategoryObjectArray
                $SoftwareCategoryObjectArray = @()
            }
            SoftwareCategoryId {
                foreach ( $SCId in $SoftwareCategoryId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/SoftwareCategory/$($SCId)"
                    }
                    Try {
                        $GlpiSoftwareCategory = Invoke-RestMethod @params -ErrorAction Stop
                        
                        $SoftwareCategoryHash = [ordered]@{ }
                        $SoftwareCategoryProperties = $GlpiSoftwareCategory.PSObject.Properties | Select-Object -Property Name, Value 
                            
                        foreach ($SoftwareCategoryProp in $SoftwareCategoryProperties) {
                            $SoftwareCategoryHash.Add($SoftwareCategoryProp.Name, $SoftwareCategoryProp.Value)
                        }
                        $object = [pscustomobject]$SoftwareCategoryHash
                        $SoftwareCategoryObjectArray += $object
                    } catch {
                        Write-Verbose -Message "Software Category ID = $SCId is not found"
                    }
                    $SoftwareCategoryObjectArray
                    $SoftwareCategoryObjectArray = @()
                }
            }
            SoftwareCategoryName {
                Search-GlpiToolsItems -SearchFor Softwarecategory -SearchType contains -SearchValue $SoftwareCategoryName
            }
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}