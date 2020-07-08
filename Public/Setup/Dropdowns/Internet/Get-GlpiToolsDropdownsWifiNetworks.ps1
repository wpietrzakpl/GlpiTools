<#
.SYNOPSIS
    Function is getting Wifi Networks informations from GLPI
.DESCRIPTION
    Function is based on WifiNetworkId which you can find in GLPI website
    Returns object with property's of Wifi Networks
.PARAMETER All
    This parameter will return all Wifi Networks from GLPI
.PARAMETER WifiNetworkId
    This parameter can take pipeline input, either, you can use this function with -WifiNetworkId keyword.
    Provide to this param WifiNetworkId from GLPI Wifi Networks Bookmark
.PARAMETER Raw
    Parameter which you can use with WifiNetworkId Parameter.
    WifiNetworkId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER WifiNetworkName
    This parameter can take pipeline input, either, you can use this function with -WifiNetworkId keyword.
    Provide to this param Wifi Networks Name from GLPI Wifi Networks Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsWifiNetworks -All
    Example will return all Wifi Networks from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsWifiNetworks
    Function gets WifiNetworkId from GLPI from pipeline, and return Wifi Networks object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsWifiNetworks
    Function gets WifiNetworkId from GLPI from pipeline (u can pass many ID's like that), and return Wifi Networks object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsWifiNetworks -WifiNetworkId 326
    Function gets WifiNetworkId from GLPI which is provided through -WifiNetworkId after Function type, and return Wifi Networks object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsWifiNetworks -WifiNetworkId 326, 321
    Function gets Wifi Networks Id from GLPI which is provided through -WifiNetworkId keyword after Function type (u can provide many ID's like that), and return Wifi Networks object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsWifiNetworks -WifiNetworkName Fusion
    Example will return glpi Wifi Networks, but what is the most important, Wifi Networks will be shown exactly as you see in glpi dropdown Wifi Networks.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Wifi Networks ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Wifi Networks from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsWifiNetworks {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "WifiNetworkId")]
        [alias('WNID')]
        [string[]]$WifiNetworkId,
        [parameter(Mandatory = $false,
            ParameterSetName = "WifiNetworkId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "WifiNetworkName")]
        [alias('WNN')]
        [string]$WifiNetworkName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $WifiNetworksArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/wifinetwork/?range=0-9999999999999"
                }
                
                $WifiNetworksAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($WifiNetwork in $WifiNetworksAll) {
                    $WifiNetworkHash = [ordered]@{ }
                    $WifiNetworkProperties = $WifiNetwork.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($WifiNetworkProp in $WifiNetworkProperties) {
                        $WifiNetworkHash.Add($WifiNetworkProp.Name, $WifiNetworkProp.Value)
                    }
                    $object = [pscustomobject]$WifiNetworkHash
                    $WifiNetworksArray.Add($object)
                }
                $WifiNetworksArray
                $WifiNetworksArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            WifiNetworkId { 
                foreach ( $WNId in $WifiNetworkId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/wifinetwork/$($WNId)"
                    }

                    Try {
                        $WifiNetwork = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $WifiNetworkHash = [ordered]@{ }
                            $WifiNetworkProperties = $WifiNetwork.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($WifiNetworkProp in $WifiNetworkProperties) {
                                $WifiNetworkHash.Add($WifiNetworkProp.Name, $WifiNetworkProp.Value)
                            }
                            $object = [pscustomobject]$WifiNetworkHash
                            $WifiNetworksArray.Add($object)
                        } else {
                            $WifiNetworkHash = [ordered]@{ }
                            $WifiNetworkProperties = $WifiNetwork.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($WifiNetworkProp in $WifiNetworkProperties) {

                                $WifiNetworkPropNewValue = Get-GlpiToolsParameters -Parameter $WifiNetworkProp.Name -Value $WifiNetworkProp.Value

                                $WifiNetworkHash.Add($WifiNetworkProp.Name, $WifiNetworkPropNewValue)
                            }
                            $object = [pscustomobject]$WifiNetworkHash
                            $WifiNetworksArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Wifi Network ID = $WNId is not found"
                        
                    }
                    $WifiNetworksArray
                    $WifiNetworksArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            WifiNetworkName { 
                Search-GlpiToolsItems -SearchFor wifinetwork -SearchType contains -SearchValue $WifiNetworkName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}