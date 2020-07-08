<#
.SYNOPSIS
    Function is getting Network Names informations from GLPI
.DESCRIPTION
    Function is based on NetworkNameId which you can find in GLPI website
    Returns object with property's of Network Names
.PARAMETER All
    This parameter will return all Network Names from GLPI
.PARAMETER NetworkNameId
    This parameter can take pipeline input, either, you can use this function with -NetworkNameId keyword.
    Provide to this param NetworkNameId from GLPI Network Names Bookmark
.PARAMETER Raw
    Parameter which you can use with NetworkNameId Parameter.
    NetworkNameId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER NetworkNameName
    This parameter can take pipeline input, either, you can use this function with -NetworkNameId keyword.
    Provide to this param Network Names Name from GLPI Network Names Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkNames -All
    Example will return all Network Names from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsNetworkNames
    Function gets NetworkNameId from GLPI from pipeline, and return Network Names object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsNetworkNames
    Function gets NetworkNameId from GLPI from pipeline (u can pass many ID's like that), and return Network Names object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkNames -NetworkNameId 326
    Function gets NetworkNameId from GLPI which is provided through -NetworkNameId after Function type, and return Network Names object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsNetworkNames -NetworkNameId 326, 321
    Function gets Network Names Id from GLPI which is provided through -NetworkNameId keyword after Function type (u can provide many ID's like that), and return Network Names object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsNetworkNames -NetworkNameName Fusion
    Example will return glpi Network Names, but what is the most important, Network Names will be shown exactly as you see in glpi dropdown Network Names.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Network Names ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Network Names from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsNetworkNames {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "NetworkNameId")]
        [alias('NNID')]
        [string[]]$NetworkNameId,
        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkNameId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "NetworkNameName")]
        [alias('NNN')]
        [string]$NetworkNameName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $NetworkNamesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/networkname/?range=0-9999999999999"
                }
                
                $NetworkNamesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($NetworkName in $NetworkNamesAll) {
                    $NetworkNameHash = [ordered]@{ }
                    $NetworkNameProperties = $NetworkName.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($NetworkNameProp in $NetworkNameProperties) {
                        $NetworkNameHash.Add($NetworkNameProp.Name, $NetworkNameProp.Value)
                    }
                    $object = [pscustomobject]$NetworkNameHash
                    $NetworkNamesArray.Add($object)
                }
                $NetworkNamesArray
                $NetworkNamesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            NetworkNameId { 
                foreach ( $NNId in $NetworkNameId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/networkname/$($NNId)"
                    }

                    Try {
                        $NetworkName = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $NetworkNameHash = [ordered]@{ }
                            $NetworkNameProperties = $NetworkName.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkNameProp in $NetworkNameProperties) {
                                $NetworkNameHash.Add($NetworkNameProp.Name, $NetworkNameProp.Value)
                            }
                            $object = [pscustomobject]$NetworkNameHash
                            $NetworkNamesArray.Add($object)
                        } else {
                            $NetworkNameHash = [ordered]@{ }
                            $NetworkNameProperties = $NetworkName.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkNameProp in $NetworkNameProperties) {

                                $NetworkNamePropNewValue = Get-GlpiToolsParameters -Parameter $NetworkNameProp.Name -Value $NetworkNameProp.Value

                                $NetworkNameHash.Add($NetworkNameProp.Name, $NetworkNamePropNewValue)
                            }
                            $object = [pscustomobject]$NetworkNameHash
                            $NetworkNamesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Network Name ID = $NNId is not found"
                        
                    }
                    $NetworkNamesArray
                    $NetworkNamesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            NetworkNameName { 
                Search-GlpiToolsItems -SearchFor networkname -SearchType contains -SearchValue $NetworkNameName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}