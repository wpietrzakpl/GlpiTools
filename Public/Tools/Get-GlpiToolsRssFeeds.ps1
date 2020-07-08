<#
.SYNOPSIS
    Function is getting RSS feeds informations from GLPI
.DESCRIPTION
    Function is based on RssfeedId which you can find in GLPI website
    Returns object with property's of RSS feeds
.PARAMETER All
    This parameter will return all RSS feeds from GLPI
.PARAMETER RssfeedId
    This parameter can take pipline input, either, you can use this function with -RssfeedId keyword.
    Provide to this param RssfeedId from GLPI RSS feeds Bookmark
.PARAMETER Raw
    Parameter which you can use with RssfeedId Parameter.
    RssfeedId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER RssfeedName
    This parameter can take pipline input, either, you can use this function with -RssfeedId keyword.
    Provide to this param RSS feeds Name from GLPI RSS feeds Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsRssFeeds -All
    Example will return all RSS feeds from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsRssFeeds
    Function gets RssfeedId from GLPI from Pipline, and return RSS feeds object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsRssFeeds
    Function gets RssfeedId from GLPI from Pipline (u can pass many ID's like that), and return RSS feeds object
.EXAMPLE
    PS C:\> Get-GlpiToolsRssFeeds -RssfeedId 326
    Function gets RssfeedId from GLPI which is provided through -RssfeedId after Function type, and return RSS feeds object
.EXAMPLE 
    PS C:\> Get-GlpiToolsRssFeeds -RssfeedId 326, 321
    Function gets RSS feeds Id from GLPI which is provided through -RssfeedId keyword after Function type (u can provide many ID's like that), and return RSS feeds object
.EXAMPLE
    PS C:\> Get-GlpiToolsRssFeeds -RssfeedName Fusion
    Example will return glpi RSS feeds, but what is the most important, RSS feeds will be shown exactly as you see in glpi dropdown RSS feeds.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    RSS feeds ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of RSS feeds from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsRssFeeds {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "RssfeedId")]
        [alias('RFID')]
        [string[]]$RssfeedId,
        [parameter(Mandatory = $false,
            ParameterSetName = "RssfeedId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "RssfeedName")]
        [alias('RFN')]
        [string]$RssfeedName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $RssfeedsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/rssfeed/?range=0-9999999999999"
                }
                
                $RssfeedsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Rssfeed in $RssfeedsAll) {
                    $RssfeedHash = [ordered]@{ }
                    $RssfeedProperties = $Rssfeed.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($RssfeedProp in $RssfeedProperties) {
                        $RssfeedHash.Add($RssfeedProp.Name, $RssfeedProp.Value)
                    }
                    $object = [pscustomobject]$RssfeedHash
                    $RssfeedsArray.Add($object)
                }
                $RssfeedsArray
                $RssfeedsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            RssfeedId { 
                foreach ( $RFId in $RssfeedId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/rssfeed/$($RFId)"
                    }

                    Try {
                        $Rssfeed = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $RssfeedHash = [ordered]@{ }
                            $RssfeedProperties = $Rssfeed.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RssfeedProp in $RssfeedProperties) {
                                $RssfeedHash.Add($RssfeedProp.Name, $RssfeedProp.Value)
                            }
                            $object = [pscustomobject]$RssfeedHash
                            $RssfeedsArray.Add($object)
                        } else {
                            $RssfeedHash = [ordered]@{ }
                            $RssfeedProperties = $Rssfeed.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RssfeedProp in $RssfeedProperties) {

                                $RssfeedPropNewValue = Get-GlpiToolsParameters -Parameter $RssfeedProp.Name -Value $RssfeedProp.Value

                                $RssfeedHash.Add($RssfeedProp.Name, $RssfeedPropNewValue)
                            }
                            $object = [pscustomobject]$RssfeedHash
                            $RssfeedsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "RSS Feed ID = $RFId is not found"
                        
                    }
                    $RssfeedsArray
                    $RssfeedsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            RssfeedName { 
                Search-GlpiToolsItems -SearchFor rssfeed -SearchType contains -SearchValue $RssfeedName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}