<#
.SYNOPSIS
    Function is getting Blacklists informations from GLPI
.DESCRIPTION
    Function is based on BlacklistsId which you can find in GLPI website
    Returns object with property's of Blacklists
.PARAMETER All
    This parameter will return all Blacklists from GLPI
.PARAMETER BlacklistsId
    This parameter can take pipline input, either, you can use this function with -BlacklistsId keyword.
    Provide to this param Blacklists ID from GLPI Blacklists Bookmark
.PARAMETER Raw
    Parameter which you can use with BlacklistsId Parameter.
    BlacklistsId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER BlacklistsName
    This parameter can take pipline input, either, you can use this function with -BlacklistsId keyword.
    Provide to this param Blacklists Name from GLPI Blacklists Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBlacklists -All
    Example will return all Blacklists from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsBlacklists
    Function gets BlacklistsId from GLPI from Pipline, and return Blacklists object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsBlacklists
    Function gets BlacklistsId from GLPI from Pipline (u can pass many ID's like that), and return Blacklists object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBlacklists -BlacklistsId 326
    Function gets BlacklistsId from GLPI which is provided through -BlacklistsId after Function type, and return Blacklists object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsBlacklists -BlacklistsId 326, 321
    Function gets BlacklistsId from GLPI which is provided through -BlacklistsId keyword after Function type (u can provide many ID's like that), and return Blacklists object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBlacklists -BlacklistsId Fusion
    Example will return glpi Blacklists, but what is the most important, Blacklists will be shown exactly as you see in glpi dropdown Blacklists.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Blacklists ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Blacklists from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsBlacklists {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "BlacklistsId")]
        [alias('BID')]
        [string[]]$BlacklistsId,
        [parameter(Mandatory = $false,
            ParameterSetName = "BlacklistsId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "BlacklistsName")]
        [alias('BN')]
        [string]$BlacklistsName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $BlacklistsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Blacklist/?range=0-9999999999999"
                }
                
                $GlpiBlacklistsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Blacklists in $GlpiBlacklistsAll) {
                    $BlacklistsHash = [ordered]@{ }
                    $BlacklistsProperties = $Blacklists.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($BlacklistsProp in $BlacklistsProperties) {
                        $BlacklistsHash.Add($BlacklistsProp.Name, $BlacklistsProp.Value)
                    }
                    $object = [pscustomobject]$BlacklistsHash
                    $BlacklistsArray.Add($object)
                }
                $BlacklistsArray
                $BlacklistsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            BlacklistsId { 
                foreach ( $BId in $BlacklistsId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Blacklist/$($BId)"
                    }

                    Try {
                        $Blacklists = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $BlacklistsHash = [ordered]@{ }
                            $BlacklistsProperties = $Blacklists.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($BlacklistsProp in $BlacklistsProperties) {
                                $BlacklistsHash.Add($BlacklistsProp.Name, $BlacklistsProp.Value)
                            }
                            $object = [pscustomobject]$BlacklistsHash
                            $BlacklistsArray.Add($object)
                        } else {
                            $BlacklistsHash = [ordered]@{ }
                            $BlacklistsProperties = $Blacklists.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($BlacklistsProp in $BlacklistsProperties) {

                                $BlacklistsPropNewValue = Get-GlpiToolsParameters -Parameter $BlacklistsProp.Name -Value $BlacklistsProp.Value

                                $BlacklistsHash.Add($BlacklistsProp.Name, $BlacklistsPropNewValue)
                            }
                            $object = [pscustomobject]$BlacklistsHash
                            $BlacklistsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Blacklists ID = $BId is not found"
                        
                    }
                    $BlacklistsArray
                    $BlacklistsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            BlacklistsName { 
                Search-GlpiToolsItems -SearchFor Blacklist -SearchType contains -SearchValue $BlacklistsName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}