<#
.SYNOPSIS
    Function is getting User Categories informations from GLPI
.DESCRIPTION
    Function is based on UserCategoryId which you can find in GLPI website
    Returns object with property's of User Categories
.PARAMETER All
    This parameter will return all User Categories from GLPI
.PARAMETER UserCategoryId
    This parameter can take pipline input, either, you can use this function with -UserCategoryId keyword.
    Provide to this param UserCategoryId from GLPI User Categories Bookmark
.PARAMETER Raw
    Parameter which you can use with UserCategoryId Parameter.
    UserCategoryId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER UserCategoryName
    This parameter can take pipline input, either, you can use this function with -UserCategoryId keyword.
    Provide to this param User Categories Name from GLPI User Categories Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUserCategories -All
    Example will return all User Categories from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsUserCategories
    Function gets UserCategoryId from GLPI from Pipline, and return User Categories object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsUserCategories
    Function gets UserCategoryId from GLPI from Pipline (u can pass many ID's like that), and return User Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUserCategories -UserCategoryId 326
    Function gets UserCategoryId from GLPI which is provided through -UserCategoryId after Function type, and return User Categories object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsUserCategories -UserCategoryId 326, 321
    Function gets User CategoriesId from GLPI which is provided through -UserCategoryId keyword after Function type (u can provide many ID's like that), and return User Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUserCategories -UserCategoryName Fusion
    Example will return glpi User Categories, but what is the most important, User Categories will be shown exactly as you see in glpi dropdown User Categories.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    User Categories ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of User Categories from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsUserCategories {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "UserCategoryId")]
        [alias('UCID')]
        [string[]]$UserCategoryId,
        [parameter(Mandatory = $false,
            ParameterSetName = "UserCategoryId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "UserCategoryName")]
        [alias('UCN')]
        [string]$UserCategoryName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $UserCategoryArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/UserCategory/?range=0-9999999999999"
                }
                
                $UserCategoriesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($UserCategory in $UserCategoriesAll) {
                    $UserCategoryHash = [ordered]@{ }
                    $UserCategoryProperties = $UserCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($UserCategoryProp in $UserCategoryProperties) {
                        $UserCategoryHash.Add($UserCategoryProp.Name, $UserCategoryProp.Value)
                    }
                    $object = [pscustomobject]$UserCategoryHash
                    $UserCategoryArray.Add($object)
                }
                $UserCategoryArray
                $UserCategoryArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            UserCategoryId { 
                foreach ( $UCId in $UserCategoryId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/UserCategory/$($UCId)"
                    }

                    Try {
                        $UserCategory = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $UserCategoryHash = [ordered]@{ }
                            $UserCategoryProperties = $UserCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($UserCategoryProp in $UserCategoryProperties) {
                                $UserCategoryHash.Add($UserCategoryProp.Name, $UserCategoryProp.Value)
                            }
                            $object = [pscustomobject]$UserCategoryHash
                            $UserCategoryArray.Add($object)
                        } else {
                            $UserCategoryHash = [ordered]@{ }
                            $UserCategoryProperties = $UserCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($UserCategoryProp in $UserCategoryProperties) {

                                $UserCategoryPropNewValue = Get-GlpiToolsParameters -Parameter $UserCategoryProp.Name -Value $UserCategoryProp.Value

                                $UserCategoryHash.Add($UserCategoryProp.Name, $UserCategoryPropNewValue)
                            }
                            $object = [pscustomobject]$UserCategoryHash
                            $UserCategoryArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "User Categories ID = $UCId is not found"
                        
                    }
                    $UserCategoryArray
                    $UserCategoryArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            UserCategoryName { 
                Search-GlpiToolsItems -SearchFor Usercategory -SearchType contains -SearchValue $UserCategoryName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}