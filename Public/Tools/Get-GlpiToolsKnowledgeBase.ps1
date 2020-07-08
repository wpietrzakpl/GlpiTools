<#
.SYNOPSIS
    Function is getting Knowledge Base informations from GLPI
.DESCRIPTION
    Function is based on KnowledgeBaseId which you can find in GLPI website
    Returns object with property's of Knowledge Base
.PARAMETER All
    This parameter will return all Knowledge Base from GLPI
.PARAMETER KnowledgeBaseId
    This parameter can take pipline input, either, you can use this function with -KnowledgeBaseId keyword.
    Provide to this param KnowledgeBaseId from GLPI Knowledge Base Bookmark
.PARAMETER Raw
    Parameter which you can use with KnowledgeBaseId Parameter.
    KnowledgeBaseId has converted parameters from default, parameter Raw allows not convert this parameters.
.EXAMPLE
    PS C:\> Get-GlpiToolsKnowledgeBase -All
    Example will return all Knowledge Base from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsKnowledgeBase
    Function gets KnowledgeBaseId from GLPI from Pipline, and return Knowledge Base object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsKnowledgeBase
    Function gets KnowledgeBaseId from GLPI from Pipline (u can pass many ID's like that), and return Knowledge Base object
.EXAMPLE
    PS C:\> Get-GlpiToolsKnowledgeBase -KnowledgeBaseId 326
    Function gets KnowledgeBaseId from GLPI which is provided through -KnowledgeBaseId after Function type, and return Knowledge Base object
.EXAMPLE 
    PS C:\> Get-GlpiToolsKnowledgeBase -KnowledgeBaseId 326, 321
    Function gets Knowledge Base Id from GLPI which is provided through -KnowledgeBaseId keyword after Function type (u can provide many ID's like that), and return Knowledge Base object
.INPUTS
    Knowledge Base ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Knowledge Base from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsKnowledgeBase {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "KnowledgeBaseId")]
        [alias('KBID')]
        [string[]]$KnowledgeBaseId,
        [parameter(Mandatory = $false,
            ParameterSetName = "KnowledgeBaseId")]
        [switch]$Raw
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $KnowledgeBaseArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/knowbaseitem/?range=0-9999999999999"
                }
                
                $KnowledgeBaseAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($KnowledgeBase in $KnowledgeBaseAll) {
                    $KnowledgeBaseHash = [ordered]@{ }
                    $KnowledgeBaseProperties = $KnowledgeBase.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($KnowledgeBaseProp in $KnowledgeBaseProperties) {
                        $KnowledgeBaseHash.Add($KnowledgeBaseProp.Name, $KnowledgeBaseProp.Value)
                    }
                    $object = [pscustomobject]$KnowledgeBaseHash
                    $KnowledgeBaseArray.Add($object)
                }
                $KnowledgeBaseArray
                $KnowledgeBaseArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            KnowledgeBaseId { 
                foreach ( $KBId in $KnowledgeBaseId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/knowbaseitem/$($KBId)"
                    }

                    Try {
                        $KnowledgeBase = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $KnowledgeBaseHash = [ordered]@{ }
                            $KnowledgeBaseProperties = $KnowledgeBase.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($KnowledgeBaseProp in $KnowledgeBaseProperties) {
                                $KnowledgeBaseHash.Add($KnowledgeBaseProp.Name, $KnowledgeBaseProp.Value)
                            }
                            $object = [pscustomobject]$KnowledgeBaseHash
                            $KnowledgeBaseArray.Add($object)
                        } else {
                            $KnowledgeBaseHash = [ordered]@{ }
                            $KnowledgeBaseProperties = $KnowledgeBase.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($KnowledgeBaseProp in $KnowledgeBaseProperties) {

                                $KnowledgeBasePropNewValue = Get-GlpiToolsParameters -Parameter $KnowledgeBaseProp.Name -Value $KnowledgeBaseProp.Value

                                $KnowledgeBaseHash.Add($KnowledgeBaseProp.Name, $KnowledgeBasePropNewValue)
                            }
                            $object = [pscustomobject]$KnowledgeBaseHash
                            $KnowledgeBaseArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Knowledge Base ID = $KBId is not found"
                        
                    }
                    $KnowledgeBaseArray
                    $KnowledgeBaseArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}