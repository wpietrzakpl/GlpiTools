<#
.SYNOPSIS
    Function is getting Network informations from GLPI
.DESCRIPTION
    Function is based on NetworkID which you can find in GLPI website
    Returns object with property's of Network
.PARAMETER All
    This parameter will return all Network from GLPI
.PARAMETER NetworkId
    This parameter can take pipline input, either, you can use this function with -NetworkId keyword.
    Provide to this param Network ID from GLPI Network Bookmark
.PARAMETER Raw
    Parameter which you can use with NetworkId Parameter.
    NetworkId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER NetworkName
    This parameter can take pipline input, either, you can use this function with -NetworkName keyword.
    Provide to this param Network Name from GLPI Network Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworks -All
    Example will return all Network from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsNetworks
    Function gets NetworkId from GLPI from Pipline, and return Network object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsNetworks
    Function gets NetworkId from GLPI from Pipline (u can pass many ID's like that), and return Network object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworks -NetworkId 326
    Function gets NetworkId from GLPI which is provided through -NetworkId after Function type, and return Network object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsNetworks -NetworkId 326, 321
    Function gets NetworkId from GLPI which is provided through -NetworkId keyword after Function type (u can provide many ID's like that), and return Network object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworks -NetworkName Fusion
    Example will return glpi Network, but what is the most important, Network will be shown exactly as you see in glpi dropdown Network.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Network ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Network from GLPI
.NOTES
    PSP 06/2019
#>

function Get-GlpiToolsDropdownsNetworks {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "NetworkId")]
        [alias('NID')]
        [string[]]$NetworkId,
        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "NetworkName")]
        [alias('NN')]
        [string]$NetworkName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $NetworkArray = [System.Collections.ArrayList]::new()
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
                    uri     = "$($PathToGlpi)/Network/?range=0-9999999999999"
                }
                
                $GlpiNetworkAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($NetworkModel in $GlpiNetworkAll) {
                    $NetworkHash = [ordered]@{ }
                    $NetworkProperties = $NetworkModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($NetworkProp in $NetworkProperties) {
                        $NetworkHash.Add($NetworkProp.Name, $NetworkProp.Value)
                    }
                    $object = [pscustomobject]$NetworkHash
                    $NetworkArray.Add($object)
                }
                $NetworkArray
                $NetworkArray = [System.Collections.ArrayList]::new()
            }
            NetworkId { 
                foreach ( $NId in $NetworkId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Network/$($NId)"
                    }

                    Try {
                        $NetworkModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $NetworkHash = [ordered]@{ }
                            $NetworkProperties = $NetworkModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkProp in $NetworkProperties) {
                                $NetworkHash.Add($NetworkProp.Name, $NetworkProp.Value)
                            }
                            $object = [pscustomobject]$NetworkHash
                            $NetworkArray.Add($object)
                        } else {
                            $NetworkHash = [ordered]@{ }
                            $NetworkProperties = $NetworkModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkProp in $NetworkProperties) {

                                switch ($NetworkProp.Name) {
                                    Default { $NetworkPropNewValue = $NetworkProp.Value }
                                }

                                $NetworkHash.Add($NetworkProp.Name, $NetworkPropNewValue)
                            }
                            $object = [pscustomobject]$NetworkHash
                            $NetworkArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Network ID = $NId is not found"
                        
                    }
                    $NetworkArray
                    $NetworkArray = [System.Collections.ArrayList]::new()
                }
            }
            NetworkName { 
                Search-GlpiToolsItems -SearchFor Network -SearchType contains -SearchValue $NetworkName 
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}