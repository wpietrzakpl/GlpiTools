<#
.SYNOPSIS
    Function is getting Document headings informations from GLPI
.DESCRIPTION
    Function is based on DocumentHeadingId which you can find in GLPI website
    Returns object with property's of Document headings
.PARAMETER All
    This parameter will return all Document headings from GLPI
.PARAMETER DocumentHeadingId
    This parameter can take pipeline input, either, you can use this function with -DocumentHeadingId keyword.
    Provide to this param DocumentHeadingId from GLPI Document headings Bookmark
.PARAMETER Raw
    Parameter which you can use with DocumentHeadingId Parameter.
    DocumentHeadingId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DocumentHeadingName
    This parameter can take pipeline input, either, you can use this function with -DocumentHeadingId keyword.
    Provide to this param Document headings Name from GLPI Document headings Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDocumentHeadings -All
    Example will return all Document headings from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDocumentHeadings
    Function gets DocumentHeadingId from GLPI from pipeline, and return Document headings object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDocumentHeadings
    Function gets DocumentHeadingId from GLPI from pipeline (u can pass many ID's like that), and return Document headings object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDocumentHeadings -DocumentHeadingId 326
    Function gets DocumentHeadingId from GLPI which is provided through -DocumentHeadingId after Function type, and return Document headings object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDocumentHeadings -DocumentHeadingId 326, 321
    Function gets Document headings Id from GLPI which is provided through -DocumentHeadingId keyword after Function type (u can provide many ID's like that), and return Document headings object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDocumentHeadings -DocumentHeadingName Fusion
    Example will return glpi Document headings, but what is the most important, Document headings will be shown exactly as you see in glpi dropdown Document headings.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Document headings ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Document headings from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDocumentHeadings {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DocumentHeadingId")]
        [alias('DHID')]
        [string[]]$DocumentHeadingId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DocumentHeadingId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DocumentHeadingName")]
        [alias('DHN')]
        [string]$DocumentHeadingName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DocumentHeadingsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/documentcategory/?range=0-9999999999999"
                }
                
                $DocumentHeadingsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DocumentHeading in $DocumentHeadingsAll) {
                    $DocumentHeadingHash = [ordered]@{ }
                    $DocumentHeadingProperties = $DocumentHeading.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DocumentHeadingProp in $DocumentHeadingProperties) {
                        $DocumentHeadingHash.Add($DocumentHeadingProp.Name, $DocumentHeadingProp.Value)
                    }
                    $object = [pscustomobject]$DocumentHeadingHash
                    $DocumentHeadingsArray.Add($object)
                }
                $DocumentHeadingsArray
                $DocumentHeadingsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DocumentHeadingId { 
                foreach ( $DHId in $DocumentHeadingId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/documentcategory/$($DHId)"
                    }

                    Try {
                        $DocumentHeading = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DocumentHeadingHash = [ordered]@{ }
                            $DocumentHeadingProperties = $DocumentHeading.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DocumentHeadingProp in $DocumentHeadingProperties) {
                                $DocumentHeadingHash.Add($DocumentHeadingProp.Name, $DocumentHeadingProp.Value)
                            }
                            $object = [pscustomobject]$DocumentHeadingHash
                            $DocumentHeadingsArray.Add($object)
                        } else {
                            $DocumentHeadingHash = [ordered]@{ }
                            $DocumentHeadingProperties = $DocumentHeading.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DocumentHeadingProp in $DocumentHeadingProperties) {

                                $DocumentHeadingPropNewValue = Get-GlpiToolsParameters -Parameter $DocumentHeadingProp.Name -Value $DocumentHeadingProp.Value

                                $DocumentHeadingHash.Add($DocumentHeadingProp.Name, $DocumentHeadingPropNewValue)
                            }
                            $object = [pscustomobject]$DocumentHeadingHash
                            $DocumentHeadingsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Document Heading ID = $DHId is not found"
                        
                    }
                    $DocumentHeadingsArray
                    $DocumentHeadingsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DocumentHeadingName { 
                Search-GlpiToolsItems -SearchFor documentcategory -SearchType contains -SearchValue $DocumentHeadingName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}