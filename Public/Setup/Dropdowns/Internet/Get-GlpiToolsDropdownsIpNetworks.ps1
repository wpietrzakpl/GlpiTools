<#
.SYNOPSIS
    Function is getting Ip Networks informations from GLPI
.DESCRIPTION
    Function is based on IpNetworkId which you can find in GLPI website
    Returns object with property's of Ip Networks
.PARAMETER All
    This parameter will return all Ip Networks from GLPI
.PARAMETER IpNetworkId
    This parameter can take pipeline input, either, you can use this function with -IpNetworkId keyword.
    Provide to this param IpNetworkId from GLPI Ip Networks Bookmark
.PARAMETER Raw
    Parameter which you can use with IpNetworkId Parameter.
    IpNetworkId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER IpNetworkName
    This parameter can take pipeline input, either, you can use this function with -IpNetworkId keyword.
    Provide to this param Ip Networks Name from GLPI Ip Networks Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsIpNetworks -All
    Example will return all Ip Networks from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsIpNetworks
    Function gets IpNetworkId from GLPI from pipeline, and return Ip Networks object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsIpNetworks
    Function gets IpNetworkId from GLPI from pipeline (u can pass many ID's like that), and return Ip Networks object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsIpNetworks -IpNetworkId 326
    Function gets IpNetworkId from GLPI which is provided through -IpNetworkId after Function type, and return Ip Networks object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsIpNetworks -IpNetworkId 326, 321
    Function gets Ip Networks Id from GLPI which is provided through -IpNetworkId keyword after Function type (u can provide many ID's like that), and return Ip Networks object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsIpNetworks -IpNetworkName Fusion
    Example will return glpi Ip Networks, but what is the most important, Ip Networks will be shown exactly as you see in glpi dropdown Ip Networks.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Ip Networks ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Ip Networks from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsIpNetworks {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "IpNetworkId")]
        [alias('INID')]
        [string[]]$IpNetworkId,
        [parameter(Mandatory = $false,
            ParameterSetName = "IpNetworkId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "IpNetworkName")]
        [alias('INN')]
        [string]$IpNetworkName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $IpNetworksArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/ipnetwork/?range=0-9999999999999"
                }
                
                $IpNetworksAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($IpNetwork in $IpNetworksAll) {
                    $IpNetworkHash = [ordered]@{ }
                    $IpNetworkProperties = $IpNetwork.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($IpNetworkProp in $IpNetworkProperties) {
                        $IpNetworkHash.Add($IpNetworkProp.Name, $IpNetworkProp.Value)
                    }
                    $object = [pscustomobject]$IpNetworkHash
                    $IpNetworksArray.Add($object)
                }
                $IpNetworksArray
                $IpNetworksArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            IpNetworkId { 
                foreach ( $INId in $IpNetworkId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/ipnetwork/$($INId)"
                    }

                    Try {
                        $IpNetwork = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $IpNetworkHash = [ordered]@{ }
                            $IpNetworkProperties = $IpNetwork.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($IpNetworkProp in $IpNetworkProperties) {
                                $IpNetworkHash.Add($IpNetworkProp.Name, $IpNetworkProp.Value)
                            }
                            $object = [pscustomobject]$IpNetworkHash
                            $IpNetworksArray.Add($object)
                        } else {
                            $IpNetworkHash = [ordered]@{ }
                            $IpNetworkProperties = $IpNetwork.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($IpNetworkProp in $IpNetworkProperties) {

                                $IpNetworkPropNewValue = Get-GlpiToolsParameters -Parameter $IpNetworkProp.Name -Value $IpNetworkProp.Value

                                $IpNetworkHash.Add($IpNetworkProp.Name, $IpNetworkPropNewValue)
                            }
                            $object = [pscustomobject]$IpNetworkHash
                            $IpNetworksArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Ip Network ID = $INId is not found"
                        
                    }
                    $IpNetworksArray
                    $IpNetworksArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            IpNetworkName { 
                Search-GlpiToolsItems -SearchFor ipnetwork -SearchType contains -SearchValue $IpNetworkName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}