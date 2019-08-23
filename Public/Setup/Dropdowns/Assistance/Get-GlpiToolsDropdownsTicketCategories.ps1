<#
.SYNOPSIS
    Function is getting Ticket Categories informations from GLPI
.DESCRIPTION
    Function is based on TicketCategoriesId which you can find in GLPI website
    Returns object with property's of Ticket Categories
.PARAMETER All
    This parameter will return all Ticket Categories from GLPI
.PARAMETER TicketCategoriesId
    This parameter can take pipline input, either, you can use this function with -TicketCategoriesId keyword.
    Provide to this param TicketCategoriesId from GLPI Ticket Categories Bookmark
.PARAMETER Raw
    Parameter which you can use with TicketCategoriesId Parameter.
    TicketCategoriesId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER TicketCategoriesName
    This parameter can take pipline input, either, you can use this function with -TicketCategoriesId keyword.
    Provide to this param Ticket Categories Name from GLPI Ticket Categories Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsTicketCategories -All
    Example will return all Ticket Categories from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsTicketCategories
    Function gets TicketCategoriesId from GLPI from Pipline, and return Ticket Categories object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsTicketCategories
    Function gets TicketCategoriesId from GLPI from Pipline (u can pass many ID's like that), and return Ticket Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsTicketCategories -TicketCategoriesId 326
    Function gets TicketCategoriesId from GLPI which is provided through -TicketCategoriesId after Function type, and return Ticket Categories object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsTicketCategories -TicketCategoriesId 326, 321
    Function gets Ticket CategoriesId from GLPI which is provided through -TicketCategoriesId keyword after Function type (u can provide many ID's like that), and return Ticket Categories object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsTicketCategories -TicketCategoriesName Fusion
    Example will return glpi Ticket Categories, but what is the most important, Ticket Categories will be shown exactly as you see in glpi dropdown Ticket Categories.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Ticket Categories ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Ticket Categories from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsTicketCategories {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "TicketCategoriesId")]
        [alias('TCID')]
        [string[]]$TicketCategoriesId,
        [parameter(Mandatory = $false,
            ParameterSetName = "TicketCategoriesId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "TicketCategoriesName")]
        [alias('TCN')]
        [string]$TicketCategoriesName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $TicketCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/itilcategory/?range=0-9999999999999"
                }
                
                $TicketCategoriesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($TicketCategories in $TicketCategoriesAll) {
                    $TicketCategoriesHash = [ordered]@{ }
                    $TicketCategoriesProperties = $TicketCategories.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($TicketCategoriesProp in $TicketCategoriesProperties) {
                        $TicketCategoriesHash.Add($TicketCategoriesProp.Name, $TicketCategoriesProp.Value)
                    }
                    $object = [pscustomobject]$TicketCategoriesHash
                    $TicketCategoriesArray.Add($object)
                }
                $TicketCategoriesArray
                $TicketCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            TicketCategoriesId { 
                foreach ( $TCId in $TicketCategoriesId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/itilcategory/$($TCId)"
                    }

                    Try {
                        $TicketCategories = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $TicketCategoriesHash = [ordered]@{ }
                            $TicketCategoriesProperties = $TicketCategories.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TicketCategoriesProp in $TicketCategoriesProperties) {
                                $TicketCategoriesHash.Add($TicketCategoriesProp.Name, $TicketCategoriesProp.Value)
                            }
                            $object = [pscustomobject]$TicketCategoriesHash
                            $TicketCategoriesArray.Add($object)
                        } else {
                            $TicketCategoriesHash = [ordered]@{ }
                            $TicketCategoriesProperties = $TicketCategories.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TicketCategoriesProp in $TicketCategoriesProperties) {

                                $TicketCategoriesPropNewValue = Get-GlpiToolsParameters -Parameter $TicketCategoriesProp.Name -Value $TicketCategoriesProp.Value

                                $TicketCategoriesHash.Add($TicketCategoriesProp.Name, $TicketCategoriesPropNewValue)
                            }
                            $object = [pscustomobject]$TicketCategoriesHash
                            $TicketCategoriesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Ticket Categories ID = $TCId is not found"
                        
                    }
                    $TicketCategoriesArray
                    $TicketCategoriesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            TicketCategoriesName { 
                Search-GlpiToolsItems -SearchFor Itilcategory -SearchType contains -SearchValue $TicketCategoriesName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}