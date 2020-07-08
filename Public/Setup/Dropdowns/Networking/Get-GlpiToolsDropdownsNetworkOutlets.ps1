<#
.SYNOPSIS
    Function is getting Network Outlets informations from GLPI
.DESCRIPTION
    Function is based on NetworkOutletId which you can find in GLPI website
    Returns object with property's of Network Outlets
.PARAMETER All
    This parameter will return all Network Outlets from GLPI
.PARAMETER NetworkOutletId
    This parameter can take pipeline input, either, you can use this function with -NetworkOutletId keyword.
    Provide to this param NetworkOutletId from GLPI Network Outlets Bookmark
.PARAMETER Raw
    Parameter which you can use with NetworkOutletId Parameter.
    NetworkOutletId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER NetworkOutletName
    This parameter can take pipeline input, either, you can use this function with -NetworkOutletId keyword.
    Provide to this param Network Outlets Name from GLPI Network Outlets Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkOutlets -All
    Example will return all Network Outlets from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsNetworkOutlets
    Function gets NetworkOutletId from GLPI from pipeline, and return Network Outlets object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsNetworkOutlets
    Function gets NetworkOutletId from GLPI from pipeline (u can pass many ID's like that), and return Network Outlets object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkOutlets -NetworkOutletId 326
    Function gets NetworkOutletId from GLPI which is provided through -NetworkOutletId after Function type, and return Network Outlets object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsNetworkOutlets -NetworkOutletId 326, 321
    Function gets Network Outlets Id from GLPI which is provided through -NetworkOutletId keyword after Function type (u can provide many ID's like that), and return Network Outlets object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkOutlets -NetworkOutletName Fusion
    Example will return glpi Network Outlets, but what is the most important, Network Outlets will be shown exactly as you see in glpi dropdown Network Outlets.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Network Outlets ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Network Outlets from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsNetworkOutlets {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "NetworkOutletId")]
        [alias('NOID')]
        [string[]]$NetworkOutletId,
        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkOutletId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "NetworkOutletName")]
        [alias('NON')]
        [string]$NetworkOutletName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $NetworkOutletsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/netpoint/?range=0-9999999999999"
                }
                
                $NetworkOutletAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($NetworkOutlet in $NetworkOutletAll) {
                    $NetworkOutletHash = [ordered]@{ }
                    $NetworkOutletProperties = $NetworkOutlet.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($NetworkOutletProp in $NetworkOutletProperties) {
                        $NetworkOutletHash.Add($NetworkOutletProp.Name, $NetworkOutletProp.Value)
                    }
                    $object = [pscustomobject]$NetworkOutletHash
                    $NetworkOutletsArray.Add($object)
                }
                $NetworkOutletsArray
                $NetworkOutletsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            NetworkOutletId { 
                foreach ( $NOId in $NetworkOutletId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/netpoint/$($NOId)"
                    }

                    Try {
                        $NetworkOutlet = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $NetworkOutletHash = [ordered]@{ }
                            $NetworkOutletProperties = $NetworkOutlet.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkOutletProp in $NetworkOutletProperties) {
                                $NetworkOutletHash.Add($NetworkOutletProp.Name, $NetworkOutletProp.Value)
                            }
                            $object = [pscustomobject]$NetworkOutletHash
                            $NetworkOutletsArray.Add($object)
                        } else {
                            $NetworkOutletHash = [ordered]@{ }
                            $NetworkOutletProperties = $NetworkOutlet.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkOutletProp in $NetworkOutletProperties) {

                                $NetworkOutletPropNewValue = Get-GlpiToolsParameters -Parameter $NetworkOutletProp.Name -Value $NetworkOutletProp.Value

                                $NetworkOutletHash.Add($NetworkOutletProp.Name, $NetworkOutletPropNewValue)
                            }
                            $object = [pscustomobject]$NetworkOutletHash
                            $NetworkOutletsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Network Outlet ID = $NOId is not found"
                        
                    }
                    $NetworkOutletsArray
                    $NetworkOutletsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            NetworkOutletName { 
                Search-GlpiToolsItems -SearchFor netpoint -SearchType contains -SearchValue $NetworkOutletName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}