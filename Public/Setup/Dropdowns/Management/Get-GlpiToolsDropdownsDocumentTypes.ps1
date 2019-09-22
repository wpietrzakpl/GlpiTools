<#
.SYNOPSIS
    Function is getting Document types informations from GLPI
.DESCRIPTION
    Function is based on DocumentTypeId which you can find in GLPI website
    Returns object with property's of Document types
.PARAMETER All
    This parameter will return all Document types from GLPI
.PARAMETER DocumentTypeId
    This parameter can take pipeline input, either, you can use this function with -DocumentTypeId keyword.
    Provide to this param DocumentTypeId from GLPI Document types Bookmark
.PARAMETER Raw
    Parameter which you can use with DocumentTypeId Parameter.
    DocumentTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DocumentTypeName
    This parameter can take pipeline input, either, you can use this function with -DocumentTypeId keyword.
    Provide to this param Document types Name from GLPI Document types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDocumentTypes -All
    Example will return all Document types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDocumentTypes
    Function gets DocumentTypeId from GLPI from pipeline, and return Document types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDocumentTypes
    Function gets DocumentTypeId from GLPI from pipeline (u can pass many ID's like that), and return Document types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDocumentTypes -DocumentTypeId 326
    Function gets DocumentTypeId from GLPI which is provided through -DocumentTypeId after Function type, and return Document types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDocumentTypes -DocumentTypeId 326, 321
    Function gets Document types Id from GLPI which is provided through -DocumentTypeId keyword after Function type (u can provide many ID's like that), and return Document types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDocumentTypes -DocumentTypeName Fusion
    Example will return glpi Document types, but what is the most important, Document types will be shown exactly as you see in glpi dropdown Document types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Document types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Document types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDocumentTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DocumentTypeId")]
        [alias('DTID')]
        [string[]]$DocumentTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DocumentTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DocumentTypeName")]
        [alias('DTN')]
        [string]$DocumentTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DocumentTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/documenttype/?range=0-9999999999999"
                }
                
                $DocumentTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DocumentType in $DocumentTypesAll) {
                    $DocumentTypeHash = [ordered]@{ }
                    $DocumentTypeProperties = $DocumentType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DocumentTypeProp in $DocumentTypeProperties) {
                        $DocumentTypeHash.Add($DocumentTypeProp.Name, $DocumentTypeProp.Value)
                    }
                    $object = [pscustomobject]$DocumentTypeHash
                    $DocumentTypesArray.Add($object)
                }
                $DocumentTypesArray
                $DocumentTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DocumentTypeId { 
                foreach ( $DTId in $DocumentTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/documenttype/$($DTId)"
                    }

                    Try {
                        $DocumentType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DocumentTypeHash = [ordered]@{ }
                            $DocumentTypeProperties = $DocumentType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DocumentTypeProp in $DocumentTypeProperties) {
                                $DocumentTypeHash.Add($DocumentTypeProp.Name, $DocumentTypeProp.Value)
                            }
                            $object = [pscustomobject]$DocumentTypeHash
                            $DocumentTypesArray.Add($object)
                        } else {
                            $DocumentTypeHash = [ordered]@{ }
                            $DocumentTypeProperties = $DocumentType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DocumentTypeProp in $DocumentTypeProperties) {

                                $DocumentTypePropNewValue = Get-GlpiToolsParameters -Parameter $DocumentTypeProp.Name -Value $DocumentTypeProp.Value

                                $DocumentTypeHash.Add($DocumentTypeProp.Name, $DocumentTypePropNewValue)
                            }
                            $object = [pscustomobject]$DocumentTypeHash
                            $DocumentTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Document Type ID = $DTId is not found"
                        
                    }
                    $DocumentTypesArray
                    $DocumentTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DocumentTypeName { 
                Search-GlpiToolsItems -SearchFor documenttype -SearchType contains -SearchValue $DocumentTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}