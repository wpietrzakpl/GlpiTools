<#
.SYNOPSIS
    Function is getting Network Interfaces informations from GLPI
.DESCRIPTION
    Function is based on NetworkInterfaceId which you can find in GLPI website
    Returns object with property's of Network Interfaces
.PARAMETER All
    This parameter will return all Network Interfaces from GLPI
.PARAMETER NetworkInterfaceId
    This parameter can take pipeline input, either, you can use this function with -NetworkInterfaceId keyword.
    Provide to this param NetworkInterfaceId from GLPI Network Interfaces Bookmark
.PARAMETER Raw
    Parameter which you can use with NetworkInterfaceId Parameter.
    NetworkInterfaceId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER NetworkInterfaceName
    This parameter can take pipeline input, either, you can use this function with -NetworkInterfaceId keyword.
    Provide to this param Network Interfaces Name from GLPI Network Interfaces Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkInterfaces -All
    Example will return all Network Interfaces from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsNetworkInterfaces
    Function gets NetworkInterfaceId from GLPI from pipeline, and return Network Interfaces object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsNetworkInterfaces
    Function gets NetworkInterfaceId from GLPI from pipeline (u can pass many ID's like that), and return Network Interfaces object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkInterfaces -NetworkInterfaceId 326
    Function gets NetworkInterfaceId from GLPI which is provided through -NetworkInterfaceId after Function type, and return Network Interfaces object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsNetworkInterfaces -NetworkInterfaceId 326, 321
    Function gets Network Interfaces Id from GLPI which is provided through -NetworkInterfaceId keyword after Function type (u can provide many ID's like that), and return Network Interfaces object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkInterfaces -NetworkInterfaceName Fusion
    Example will return glpi Network Interfaces, but what is the most important, Network Interfaces will be shown exactly as you see in glpi dropdown Network Interfaces.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Network Interfaces ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Network Interfaces from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsNetworkInterfaces {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "NetworkInterfaceId")]
        [alias('NIID')]
        [string[]]$NetworkInterfaceId,
        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkInterfaceId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "NetworkInterfaceName")]
        [alias('NIN')]
        [string]$NetworkInterfaceName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $NetworkInterfacesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/networkinterface/?range=0-9999999999999"
                }
                
                $NetworkInterfacesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($NetworkInterface in $NetworkInterfacesAll) {
                    $NetworkInterfaceHash = [ordered]@{ }
                    $NetworkInterfaceProperties = $NetworkInterface.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($NetworkInterfaceProp in $NetworkInterfaceProperties) {
                        $NetworkInterfaceHash.Add($NetworkInterfaceProp.Name, $NetworkInterfaceProp.Value)
                    }
                    $object = [pscustomobject]$NetworkInterfaceHash
                    $NetworkInterfacesArray.Add($object)
                }
                $NetworkInterfacesArray
                $NetworkInterfacesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            NetworkInterfaceId { 
                foreach ( $NIId in $NetworkInterfaceId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/networkinterface/$($NIId)"
                    }

                    Try {
                        $NetworkInterface = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $NetworkInterfaceHash = [ordered]@{ }
                            $NetworkInterfaceProperties = $NetworkInterface.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkInterfaceProp in $NetworkInterfaceProperties) {
                                $NetworkInterfaceHash.Add($NetworkInterfaceProp.Name, $NetworkInterfaceProp.Value)
                            }
                            $object = [pscustomobject]$NetworkInterfaceHash
                            $NetworkInterfacesArray.Add($object)
                        } else {
                            $NetworkInterfaceHash = [ordered]@{ }
                            $NetworkInterfaceProperties = $NetworkInterface.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkInterfaceProp in $NetworkInterfaceProperties) {

                                $NetworkInterfacePropNewValue = Get-GlpiToolsParameters -Parameter $NetworkInterfaceProp.Name -Value $NetworkInterfaceProp.Value

                                $NetworkInterfaceHash.Add($NetworkInterfaceProp.Name, $NetworkInterfacePropNewValue)
                            }
                            $object = [pscustomobject]$NetworkInterfaceHash
                            $NetworkInterfacesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Network Interface ID = $NIId is not found"
                        
                    }
                    $NetworkInterfacesArray
                    $NetworkInterfacesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            NetworkInterfaceName { 
                Search-GlpiToolsItems -SearchFor networkinterface -SearchType contains -SearchValue $NetworkInterfaceName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}