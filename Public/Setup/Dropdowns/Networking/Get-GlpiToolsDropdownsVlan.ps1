<#
.SYNOPSIS
    Function is getting Vlan informations from GLPI
.DESCRIPTION
    Function is based on VlanId which you can find in GLPI website
    Returns object with property's of Vlan
.PARAMETER All
    This parameter will return all Vlan from GLPI
.PARAMETER VlanId
    This parameter can take pipeline input, either, you can use this function with -VlanId keyword.
    Provide to this param VlanId from GLPI Vlan Bookmark
.PARAMETER Raw
    Parameter which you can use with VlanId Parameter.
    VlanId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER VlanName
    This parameter can take pipeline input, either, you can use this function with -VlanId keyword.
    Provide to this param Vlan Name from GLPI Vlan Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVlan -All
    Example will return all Vlan from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsVlan
    Function gets VlanId from GLPI from pipeline, and return Vlan object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsVlan
    Function gets VlanId from GLPI from pipeline (u can pass many ID's like that), and return Vlan object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVlan -VlanId 326
    Function gets VlanId from GLPI which is provided through -VlanId after Function type, and return Vlan object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsVlan -VlanId 326, 321
    Function gets Vlan Id from GLPI which is provided through -VlanId keyword after Function type (u can provide many ID's like that), and return Vlan object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVlan -VlanName Fusion
    Example will return glpi Vlan, but what is the most important, Vlan will be shown exactly as you see in glpi dropdown Vlan.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Vlan ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Vlan from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsVlan {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "VlanId")]
        [alias('VID')]
        [string[]]$VlanId,
        [parameter(Mandatory = $false,
            ParameterSetName = "VlanId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "VlanName")]
        [alias('VN')]
        [string]$VlanName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $VlanArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/vlan/?range=0-9999999999999"
                }
                
                $VlanAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Vlan in $VlanAll) {
                    $VlanHash = [ordered]@{ }
                    $VlanProperties = $Vlan.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($VlanProp in $VlanProperties) {
                        $VlanHash.Add($VlanProp.Name, $VlanProp.Value)
                    }
                    $object = [pscustomobject]$VlanHash
                    $VlanArray.Add($object)
                }
                $VlanArray
                $VlanArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            VlanId { 
                foreach ( $VId in $VlanId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/vlan/$($VId)"
                    }

                    Try {
                        $Vlan = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $VlanHash = [ordered]@{ }
                            $VlanProperties = $Vlan.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($VlanProp in $VlanProperties) {
                                $VlanHash.Add($VlanProp.Name, $VlanProp.Value)
                            }
                            $object = [pscustomobject]$VlanHash
                            $VlanArray.Add($object)
                        } else {
                            $VlanHash = [ordered]@{ }
                            $VlanProperties = $Vlan.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($VlanProp in $VlanProperties) {

                                $VlanPropNewValue = Get-GlpiToolsParameters -Parameter $VlanProp.Name -Value $VlanProp.Value

                                $VlanHash.Add($VlanProp.Name, $VlanPropNewValue)
                            }
                            $object = [pscustomobject]$VlanHash
                            $VlanArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Vlan ID = $VId is not found"
                        
                    }
                    $VlanArray
                    $VlanArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            VlanName { 
                Search-GlpiToolsItems -SearchFor vlan -SearchType contains -SearchValue $VlanName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}