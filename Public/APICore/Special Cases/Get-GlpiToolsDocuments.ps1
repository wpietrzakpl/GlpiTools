<#
.SYNOPSIS
    Function is getting Document informations from GLPI
.DESCRIPTION
    Function is based on DocumentID which you can find in GLPI website
    Returns object with property's of document.
.PARAMETER All
    This parameter will return all documents from GLPI
.PARAMETER DocumentId
    This parameter can take pipline input, either, you can use this function with -DocumentId keyword.
    Provide to this param Document ID from GLPI Documents Bookmark
.PARAMETER Raw
    Parameter which you can use with DocumentId Parameter.
    DocumentId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER RawDocument
    Parameter which you can use with DocumentId Parameter.
    This parameter get document and return what document has inside. 
.EXAMPLE
    PS C:\> Get-GlpiToolsDocuments -All
    Example will show all documents from Document GLPI Bookmark.
.EXAMPLE
    PS C:\> Get-GlpiToolsDocuments -ComputerId 2
    Example will return object of document which id is 2. Example will convert values to human readable. 
.EXAMPLE
    PS C:\> Get-GlpiToolsDocuments -ComputerId 2 -Raw
    Example will return object of document which id is 2. Example will not convert values to human readable.
.EXAMPLE
    PS C:\> Get-GlpiToolsDocuments -ComputerId 2 -RawDocument
    Example will return content which document has inside the file.
.INPUTS
    Document ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of document's from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsDocuments {
    [CmdletBinding(DefaultParameterSetName = 'DocumentId')]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ParameterSetName = "DocumentId",
            Position = 0)]
        [Parameter(ParameterSetName = 'Raw')]
        [Parameter(ParameterSetName = 'RawDocument')]
        [alias('DocID')]
        [int[]]$DocumentId,

        [parameter(Mandatory = $false,
            ParameterSetName = "Raw",
            Position = 1)]
        [switch]$Raw,
        [parameter(Mandatory = $false,
            ParameterSetName = "RawDocument",
            Position = 1)]
        [switch]$RawDocument
    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DocumentObjectArray = [System.Collections.ArrayList]::new()

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
                    uri     = "$($PathToGlpi)/Document/?range=0-9999999999999"
                }
                
                $GlpiDocumentAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiDocument in $GlpiDocumentAll) {
                    $DocumentHash = [ordered]@{ }
                    $DocumentProperties = $GlpiDocument.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DocumentProp in $DocumentProperties) {
                        $DocumentHash.Add($DocumentProp.Name, $DocumentProp.Value)
                    }
                    $object = [pscustomobject]$DocumentHash
                    $DocumentObjectArray.Add($object)
                }
                $DocumentObjectArray
                $DocumentObjectArray = [System.Collections.ArrayList]::new()
            }
            DocumentId {
                foreach ( $DId in $DocumentId ) {

                    if ($RawDocument) {

                        $params = @{
                            headers = @{
                                'Content-Type'  = 'application/json'
                                'App-Token'     = $AppToken
                                'Session-Token' = $SessionToken
                                'Accept'        = 'application/octet-stream'
                            }
                            method  = 'get'
                            uri     = "$($PathToGlpi)/Document/$($DId)"
                        }
                        try {
                            $GlpiDocument = Invoke-RestMethod @params

                            $GlpiDocument
                        } catch {
                            Write-Verbose -Message "Computer ID = $DId is not found"
                        }
                    } elseif ($Raw) {

                        $params = @{
                            headers = @{
                                'Content-Type'  = 'application/json'
                                'App-Token'     = $AppToken
                                'Session-Token' = $SessionToken
                            }
                            method  = 'get'
                            uri     = "$($PathToGlpi)/Document/$($DId)"
                        }

                        try {
                            $GlpiDocument = Invoke-RestMethod @params

                            $DocumentHash = [ordered]@{ }
                            $DocumentProperties = $GlpiDocument.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DocumentProp in $DocumentProperties) {
                                $DocumentHash.Add($DocumentProp.Name, $DocumentProp.Value)
                            }
                            $object = [pscustomobject]$DocumentHash
                            $DocumentObjectArray.Add($object)
                            
                            $DocumentObjectArray
                            $DocumentObjectArray = [System.Collections.ArrayList]::new()
                        } catch {
                            Write-Verbose -Message "Computer ID = $DId is not found"
                        }
                    } else {

                        $params = @{
                            headers = @{
                                'Content-Type'  = 'application/json'
                                'App-Token'     = $AppToken
                                'Session-Token' = $SessionToken
                            }
                            method  = 'get'
                            uri     = "$($PathToGlpi)/Document/$($DId)"
                        }

                        try {
                            $GlpiDocument = Invoke-RestMethod @params

                            $DocumentHash = [ordered]@{ }
                            $DocumentProperties = $GlpiDocument.PSObject.Properties | Select-Object -Property Name, Value 
                            
                            foreach ($DocumentProp in $DocumentProperties) {

                                switch ($DocumentProp.Name) {
                                    entities_id { $DocumentPropNewValue = $DocumentProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id { $DocumentPropNewValue = $DocumentProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname, $_.realname } }
                                    Default {
                                        $DocumentPropNewValue = $DocumentProp.Value
                                    }
                                }
                            
                                $DocumentHash.Add($DocumentProp.Name, $DocumentPropNewValue)
                            }
                            $object = [pscustomobject]$DocumentHash
                            $DocumentObjectArray.Add($object)

                            $DocumentObjectArray
                            $DocumentObjectArray = [System.Collections.ArrayList]::new()
                        
                        } catch {
                            Write-Verbose -Message "Computer ID = $DId is not found"
                        } 
                    }
                }
            }
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}