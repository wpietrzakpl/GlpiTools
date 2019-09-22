<#
.SYNOPSIS
    Function is getting Knowledge Base Categories informations from GLPI
.DESCRIPTION
    Function is based on KnowledgeBaseCategoryId which you can find in GLPI website
    Returns object with property's of Knowledge Base Categories
.PARAMETER All
    This parameter will return all Knowledge Base Categories from GLPI
.PARAMETER KnowledgeBaseCategoryId
    This parameter can take pipeline input, either, you can use this function with -KnowledgeBaseCategoryId keyword.
    Provide to this param KnowledgeBaseCategoryId from GLPI Knowledge Base Categories Bookmark
.PARAMETER Raw
    Parameter which you can use with KnowledgeBaseCategoryId Parameter.
    KnowledgeBaseCategoryId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER KnowledgeBaseCategoryName
    This parameter can take pipeline input, either, you can use this function with -KnowledgeBaseCategoryId keyword.
    Provide to this param Knowledge Base Categories Name from GLPI Knowledge Base Categories Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsKnowledgeBaseCategories -All
    Example will return all Knowledge Base Categories from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsKnowledgeBaseCategories
    Function gets KnowledgeBaseCategoryId from GLPI from pipeline, and return Knowledge Base Categories object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsKnowledgeBaseCategories
    Function gets KnowledgeBaseCategoryId from GLPI from pipeline (u can pass many ID's like that), and return Knowledge Base Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsKnowledgeBaseCategories -KnowledgeBaseCategoryId 326
    Function gets KnowledgeBaseCategoryId from GLPI which is provided through -KnowledgeBaseCategoryId after Function type, and return Knowledge Base Categories object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsKnowledgeBaseCategories -KnowledgeBaseCategoryId 326, 321
    Function gets Knowledge Base Categories Id from GLPI which is provided through -KnowledgeBaseCategoryId keyword after Function type (u can provide many ID's like that), and return Knowledge Base Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsKnowledgeBaseCategories -KnowledgeBaseCategoryName Fusion
    Example will return glpi Knowledge Base Categories, but what is the most important, Knowledge Base Categories will be shown exactly as you see in glpi dropdown Knowledge Base Categories.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Knowledge Base Categories ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Knowledge Base Categories from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsKnowledgeBaseCategories {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "KnowledgeBaseCategoryId")]
        [alias('KBCID')]
        [string[]]$KnowledgeBaseCategoryId,
        [parameter(Mandatory = $false,
            ParameterSetName = "KnowledgeBaseCategoryId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "KnowledgeBaseCategoryName")]
        [alias('KBCN')]
        [string]$KnowledgeBaseCategoryName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $KnowledgeBaseCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/knowbaseitemcategory/?range=0-9999999999999"
                }
                
                $KnowledgeBaseCategoriesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($KnowledgeBaseCategory in $KnowledgeBaseCategoriesAll) {
                    $KnowledgeBaseCategoryHash = [ordered]@{ }
                    $KnowledgeBaseCategoryProperties = $KnowledgeBaseCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($KnowledgeBaseCategoryProp in $KnowledgeBaseCategoryProperties) {
                        $KnowledgeBaseCategoryHash.Add($KnowledgeBaseCategoryProp.Name, $KnowledgeBaseCategoryProp.Value)
                    }
                    $object = [pscustomobject]$KnowledgeBaseCategoryHash
                    $KnowledgeBaseCategoriesArray.Add($object)
                }
                $KnowledgeBaseCategoriesArray
                $KnowledgeBaseCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            KnowledgeBaseCategoryId { 
                foreach ( $KBCId in $KnowledgeBaseCategoryId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/knowbaseitemcategory/$($KBCId)"
                    }

                    Try {
                        $KnowledgeBaseCategory = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $KnowledgeBaseCategoryHash = [ordered]@{ }
                            $KnowledgeBaseCategoryProperties = $KnowledgeBaseCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($KnowledgeBaseCategoryProp in $KnowledgeBaseCategoryProperties) {
                                $KnowledgeBaseCategoryHash.Add($KnowledgeBaseCategoryProp.Name, $KnowledgeBaseCategoryProp.Value)
                            }
                            $object = [pscustomobject]$KnowledgeBaseCategoryHash
                            $KnowledgeBaseCategoriesArray.Add($object)
                        } else {
                            $KnowledgeBaseCategoryHash = [ordered]@{ }
                            $KnowledgeBaseCategoryProperties = $KnowledgeBaseCategory.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($KnowledgeBaseCategoryProp in $KnowledgeBaseCategoryProperties) {

                                $KnowledgeBaseCategoryPropNewValue = Get-GlpiToolsParameters -Parameter $KnowledgeBaseCategoryProp.Name -Value $KnowledgeBaseCategoryProp.Value

                                $KnowledgeBaseCategoryHash.Add($KnowledgeBaseCategoryProp.Name, $KnowledgeBaseCategoryPropNewValue)
                            }
                            $object = [pscustomobject]$KnowledgeBaseCategoryHash
                            $KnowledgeBaseCategoriesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Knowledge Base Category ID = $KBCId is not found"
                        
                    }
                    $KnowledgeBaseCategoriesArray
                    $KnowledgeBaseCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            KnowledgeBaseCategoryName { 
                Search-GlpiToolsItems -SearchFor knowbaseitemcategory -SearchType contains -SearchValue $KnowledgeBaseCategoryName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}