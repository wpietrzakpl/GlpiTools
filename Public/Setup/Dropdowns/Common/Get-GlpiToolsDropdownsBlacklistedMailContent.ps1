<#
.SYNOPSIS
    Function is getting Blacklisted Mail Content informations from GLPI
.DESCRIPTION
    Function is based on BlacklistedMailContentId which you can find in GLPI website
    Returns object with property's of Blacklisted Mail Content
.PARAMETER All
    This parameter will return all Blacklisted Mail Content from GLPI
.PARAMETER BlacklistedMailContentId
    This parameter can take pipline input, either, you can use this function with -BlacklistedMailContentId keyword.
    Provide to this param BlacklistedMailContentID from GLPI Blacklisted Mail Content Bookmark
.PARAMETER Raw
    Parameter which you can use with BlacklistedMailContentId Parameter.
    BlacklistedMailContentId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER BlacklistedMailContentName
    This parameter can take pipline input, either, you can use this function with -BlacklistedMailContentId keyword.
    Provide to this param Blacklisted Mail Content Name from GLPI Blacklisted Mail Content Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBlacklistedMailContent -All
    Example will return all Blacklisted Mail Content from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsBlacklistedMailContent
    Function gets BlacklistedMailContentId from GLPI from Pipline, and return Blacklisted Mail Content object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsBlacklistedMailContent
    Function gets BlacklistedMailContentId from GLPI from Pipline (u can pass many ID's like that), and return Blacklisted Mail Content object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBlacklistedMailContent -BlacklistedMailContentId 326
    Function gets BlacklistedMailContentId from GLPI which is provided through -BlacklistedMailContentId after Function type, and return Blacklisted Mail Content object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsBlacklistedMailContent -BlacklistedMailContentId 326, 321
    Function gets Blacklisted Mail ContentId from GLPI which is provided through -Blacklisted Mail ContentId keyword after Function type (u can provide many ID's like that), and return Blacklisted Mail Content object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBlacklistedMailContent -BlacklistedMailContentName Fusion
    Example will return glpi Blacklisted Mail Content, but what is the most important, Blacklisted Mail Content will be shown exactly as you see in glpi dropdown Blacklisted Mail Content.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Blacklisted Mail Content ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Blacklisted Mail Content from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsBlacklistedMailContent {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "BlacklistedMailContentId")]
        [alias('BMCID')]
        [string[]]$BlacklistedMailContentId,
        [parameter(Mandatory = $false,
            ParameterSetName = "BlacklistedMailContentId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "BlacklistedMailContentName")]
        [alias('BMCN')]
        [string]$BlacklistedMailContentName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $BlacklistedMailContentArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Blacklistedmailcontent/?range=0-9999999999999"
                }
                
                $GlpiBlacklistedMailContentAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($BlacklistedMailContent in $GlpiBlacklistedMailContentAll) {
                    $BlacklistedMailContentHash = [ordered]@{ }
                    $BlacklistedMailContentProperties = $BlacklistedMailContent.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($BlacklistedMailContentProp in $BlacklistedMailContentProperties) {
                        $BlacklistedMailContentHash.Add($BlacklistedMailContentProp.Name, $BlacklistedMailContentProp.Value)
                    }
                    $object = [pscustomobject]$BlacklistedMailContentHash
                    $BlacklistedMailContentArray.Add($object)
                }
                $BlacklistedMailContentArray
                $BlacklistedMailContentArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            BlacklistedMailContentId { 
                foreach ( $BMCId in $BlacklistedMailContentId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Blacklistedmailcontent/$($BMCId)"
                    }

                    Try {
                        $BlacklistedMailContent = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $BlacklistedMailContentHash = [ordered]@{ }
                            $BlacklistedMailContentProperties = $BlacklistedMailContent.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($BlacklistedMailContentProp in $BlacklistedMailContentProperties) {
                                $BlacklistedMailContentHash.Add($BlacklistedMailContentProp.Name, $BlacklistedMailContentProp.Value)
                            }
                            $object = [pscustomobject]$BlacklistedMailContentHash
                            $BlacklistedMailContentArray.Add($object)
                        } else {
                            $BlacklistedMailContentHash = [ordered]@{ }
                            $BlacklistedMailContentProperties = $BlacklistedMailContent.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($BlacklistedMailContentProp in $BlacklistedMailContentProperties) {

                                $BlacklistedMailContentPropNewValue = Get-GlpiToolsParameters -Parameter $BlacklistedMailContentProp.Name -Value $BlacklistedMailContentProp.Value

                                $BlacklistedMailContentHash.Add($BlacklistedMailContentProp.Name, $BlacklistedMailContentPropNewValue)
                            }
                            $object = [pscustomobject]$BlacklistedMailContentHash
                            $BlacklistedMailContentArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Blacklisted Mail Content ID = $BMCId is not found"
                        
                    }
                    $BlacklistedMailContentArray
                    $BlacklistedMailContentArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            BlacklistedMailContentName { 
                Search-GlpiToolsItems -SearchFor Blacklistedmailcontent -SearchType contains -SearchValue $BlacklistedMailContentName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}