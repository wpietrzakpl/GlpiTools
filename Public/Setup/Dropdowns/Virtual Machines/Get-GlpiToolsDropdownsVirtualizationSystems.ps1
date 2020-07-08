<#
.SYNOPSIS
    Function is getting Virtualization Systems informations from GLPI
.DESCRIPTION
    Function is based on VirtualizationSystemId which you can find in GLPI website
    Returns object with property's of Virtualization Systems
.PARAMETER All
    This parameter will return all Virtualization Systems from GLPI
.PARAMETER VirtualizationSystemId
    This parameter can take pipeline input, either, you can use this function with -VirtualizationSystemId keyword.
    Provide to this param VirtualizationSystemId from GLPI Virtualization Systems Bookmark
.PARAMETER Raw
    Parameter which you can use with VirtualizationSystemId Parameter.
    VirtualizationSystemId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER VirtualizationSystemName
    This parameter can take pipeline input, either, you can use this function with -VirtualizationSystemId keyword.
    Provide to this param Virtualization Systems Name from GLPI Virtualization Systems Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVirtualizationSystems -All
    Example will return all Virtualization Systems from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsVirtualizationSystems
    Function gets VirtualizationSystemId from GLPI from pipeline, and return Virtualization Systems object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsVirtualizationSystems
    Function gets VirtualizationSystemId from GLPI from pipeline (u can pass many ID's like that), and return Virtualization Systems object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVirtualizationSystems -VirtualizationSystemId 326
    Function gets VirtualizationSystemId from GLPI which is provided through -VirtualizationSystemId after Function type, and return Virtualization Systems object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsVirtualizationSystems -VirtualizationSystemId 326, 321
    Function gets Virtualization Systems Id from GLPI which is provided through -VirtualizationSystemId keyword after Function type (u can provide many ID's like that), and return Virtualization Systems object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsVirtualizationSystems -VirtualizationSystemName Fusion
    Example will return glpi Virtualization Systems, but what is the most important, Virtualization Systems will be shown exactly as you see in glpi dropdown Virtualization Systems.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Virtualization Systems ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Virtualization Systems from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsVirtualizationSystems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "VirtualizationSystemId")]
        [alias('VSID')]
        [string[]]$VirtualizationSystemId,
        [parameter(Mandatory = $false,
            ParameterSetName = "VirtualizationSystemId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "VirtualizationSystemName")]
        [alias('VSN')]
        [string]$VirtualizationSystemName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $VirtualizationSystemsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/virtualmachinetype/?range=0-9999999999999"
                }
                
                $VirtualizationSystemsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($VirtualizationSystem in $VirtualizationSystemsAll) {
                    $VirtualizationSystemHash = [ordered]@{ }
                    $VirtualizationSystemProperties = $VirtualizationSystem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($VirtualizationSystemProp in $VirtualizationSystemProperties) {
                        $VirtualizationSystemHash.Add($VirtualizationSystemProp.Name, $VirtualizationSystemProp.Value)
                    }
                    $object = [pscustomobject]$VirtualizationSystemHash
                    $VirtualizationSystemsArray.Add($object)
                }
                $VirtualizationSystemsArray
                $VirtualizationSystemsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            VirtualizationSystemId { 
                foreach ( $VSId in $VirtualizationSystemId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/virtualmachinetype/$($VSId)"
                    }

                    Try {
                        $VirtualizationSystem = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $VirtualizationSystemHash = [ordered]@{ }
                            $VirtualizationSystemProperties = $VirtualizationSystem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($VirtualizationSystemProp in $VirtualizationSystemProperties) {
                                $VirtualizationSystemHash.Add($VirtualizationSystemProp.Name, $VirtualizationSystemProp.Value)
                            }
                            $object = [pscustomobject]$VirtualizationSystemHash
                            $VirtualizationSystemsArray.Add($object)
                        } else {
                            $VirtualizationSystemHash = [ordered]@{ }
                            $VirtualizationSystemProperties = $VirtualizationSystem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($VirtualizationSystemProp in $VirtualizationSystemProperties) {

                                $VirtualizationSystemPropNewValue = Get-GlpiToolsParameters -Parameter $VirtualizationSystemProp.Name -Value $VirtualizationSystemProp.Value

                                $VirtualizationSystemHash.Add($VirtualizationSystemProp.Name, $VirtualizationSystemPropNewValue)
                            }
                            $object = [pscustomobject]$VirtualizationSystemHash
                            $VirtualizationSystemsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Virtualization System ID = $VSId is not found"
                        
                    }
                    $VirtualizationSystemsArray
                    $VirtualizationSystemsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            VirtualizationSystemName { 
                Search-GlpiToolsItems -SearchFor virtualmachinetype -SearchType contains -SearchValue $VirtualizationSystemName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}