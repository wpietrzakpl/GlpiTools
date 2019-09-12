<#
.SYNOPSIS
    Function is getting Task Categories informations from GLPI
.DESCRIPTION
    Function is based on TaskCategoryId which you can find in GLPI website
    Returns object with property's of Task Categories
.PARAMETER All
    This parameter will return all Task Categories from GLPI
.PARAMETER TaskCategoryId
    This parameter can take pipline input, either, you can use this function with -TaskCategoryId keyword.
    Provide to this param TaskCategoryId from GLPI Task Categories Bookmark
.PARAMETER Raw
    Parameter which you can use with TaskCategoryId Parameter.
    TaskCategoryId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER TaskCategoryName
    This parameter can take pipline input, either, you can use this function with -TaskCategoryId keyword.
    Provide to this param Task Categories Name from GLPI Task Categories Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsTaskCategories -All
    Example will return all Task Categories from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsTaskCategories
    Function gets TaskCategoryId from GLPI from Pipline, and return Task Categories object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsTaskCategories
    Function gets TaskCategoryId from GLPI from Pipline (u can pass many ID's like that), and return Task Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsTaskCategories -TaskCategoryId 326
    Function gets TaskCategoryId from GLPI which is provided through -TaskCategoryId after Function type, and return Task Categories object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsTaskCategories -TaskCategoryId 326, 321
    Function gets Task Categories Id from GLPI which is provided through -TaskCategoryId keyword after Function type (u can provide many ID's like that), and return Task Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsTaskCategories -TaskCategoryName Fusion
    Example will return glpi Task Categories, but what is the most important, Task Categories will be shown exactly as you see in glpi dropdown Task Categories.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Task Categories ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Task Categories from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsTaskCategories {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "TaskCategoryId")]
        [alias('TCID')]
        [string[]]$TaskCategoryId,
        [parameter(Mandatory = $false,
            ParameterSetName = "TaskCategoryId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "TaskCategoryName")]
        [alias('TCN')]
        [string]$TaskCategoryName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $TaskCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/taskcategory/?range=0-9999999999999"
                }
                
                $TaskCategoriesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($TaskCategory in $TaskCategoriesAll) {
                    $TaskCategoryHash = [ordered]@{ }
                    $TaskCategoryProperties = $TaskCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($TaskCategoryProp in $TaskCategoryProperties) {
                        $TaskCategoryHash.Add($TaskCategoryProp.Name, $TaskCategoryProp.Value)
                    }
                    $object = [pscustomobject]$TaskCategoryHash
                    $TaskCategoriesArray.Add($object)
                }
                $TaskCategoriesArray
                $TaskCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            TaskCategoryId { 
                foreach ( $TCId in $TaskCategoryId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/taskcategory/$($TCId)"
                    }

                    Try {
                        $TaskCategory = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $TaskCategoryHash = [ordered]@{ }
                            $TaskCategoryProperties = $TaskCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TaskCategoryProp in $TaskCategoryProperties) {
                                $TaskCategoryHash.Add($TaskCategoryProp.Name, $TaskCategoryProp.Value)
                            }
                            $object = [pscustomobject]$TaskCategoryHash
                            $TaskCategoriesArray.Add($object)
                        } else {
                            $TaskCategoryHash = [ordered]@{ }
                            $TaskCategoryProperties = $TaskCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TaskCategoryProp in $TaskCategoryProperties) {

                                $TaskCategoryPropNewValue = Get-GlpiToolsParameters -Parameter $TaskCategoryProp.Name -Value $TaskCategoryProp.Value

                                $TaskCategoryHash.Add($TaskCategoryProp.Name, $TaskCategoryPropNewValue)
                            }
                            $object = [pscustomobject]$TaskCategoryHash
                            $TaskCategoriesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Task Category ID = $TCId is not found"
                        
                    }
                    $TaskCategoriesArray
                    $TaskCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            TaskCategoryName { 
                Search-GlpiToolsItems -SearchFor taskcategory -SearchType contains -SearchValue $TaskCategoryName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}