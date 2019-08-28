<#
.SYNOPSIS
    Function is getting Operating Systems informations from GLPI
.DESCRIPTION
    Function is based on OperatingSystemId which you can find in GLPI website
    Returns object with property's of Operating Systems
.PARAMETER All
    This parameter will return all Operating Systems from GLPI
.PARAMETER OperatingSystemId
    This parameter can take pipline input, either, you can use this function with -OperatingSystemId keyword.
    Provide to this param OperatingSystemId from GLPI Operating Systems Bookmark
.PARAMETER Raw
    Parameter which you can use with OperatingSystemId Parameter.
    OperatingSystemId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OperatingSystemName
    This parameter can take pipline input, either, you can use this function with -OperatingSystemId keyword.
    Provide to this param Operating Systems Name from GLPI Operating Systems Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOperatingSystems -All
    Example will return all Operating Systems from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOperatingSystems
    Function gets OperatingSystemId from GLPI from Pipline, and return Operating Systems object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOperatingSystems
    Function gets OperatingSystemId from GLPI from Pipline (u can pass many ID's like that), and return Operating Systems object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOperatingSystems -OperatingSystemId 326
    Function gets OperatingSystemId from GLPI which is provided through -OperatingSystemId after Function type, and return Operating Systems object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOperatingSystems -OperatingSystemId 326, 321
    Function gets Operating SystemsId from GLPI which is provided through -OperatingSystemId keyword after Function type (u can provide many ID's like that), and return Operating Systems object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOperatingSystems -OperatingSystemName Fusion
    Example will return glpi Operating Systems, but what is the most important, Operating Systems will be shown exactly as you see in glpi dropdown Operating Systems.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Operating Systems ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Operating Systems from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsOperatingSystems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OperatingSystemId")]
        [alias('OSID')]
        [string[]]$OperatingSystemId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OperatingSystemId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OperatingSystemName")]
        [alias('OSN')]
        [string]$OperatingSystemName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OperatingSystemArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/OperatingSystem/?range=0-9999999999999"
                }
                
                $OperatingSystemsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OperatingSystem in $OperatingSystemsAll) {
                    $OperatingSystemHash = [ordered]@{ }
                    $OperatingSystemProperties = $OperatingSystem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OperatingSystemProp in $OperatingSystemProperties) {
                        $OperatingSystemHash.Add($OperatingSystemProp.Name, $OperatingSystemProp.Value)
                    }
                    $object = [pscustomobject]$OperatingSystemHash
                    $OperatingSystemArray.Add($object)
                }
                $OperatingSystemArray
                $OperatingSystemArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OperatingSystemId { 
                foreach ( $OSId in $OperatingSystemId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/OperatingSystem/$($OSId)"
                    }

                    Try {
                        $OperatingSystem = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OperatingSystemHash = [ordered]@{ }
                            $OperatingSystemProperties = $OperatingSystem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OperatingSystemProp in $OperatingSystemProperties) {
                                $OperatingSystemHash.Add($OperatingSystemProp.Name, $OperatingSystemProp.Value)
                            }
                            $object = [pscustomobject]$OperatingSystemHash
                            $OperatingSystemArray.Add($object)
                        } else {
                            $OperatingSystemHash = [ordered]@{ }
                            $OperatingSystemProperties = $OperatingSystem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OperatingSystemProp in $OperatingSystemProperties) {

                                $OperatingSystemPropNewValue = Get-GlpiToolsParameters -Parameter $OperatingSystemProp.Name -Value $OperatingSystemProp.Value

                                $OperatingSystemHash.Add($OperatingSystemProp.Name, $OperatingSystemPropNewValue)
                            }
                            $object = [pscustomobject]$OperatingSystemHash
                            $OperatingSystemArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Operating Systems ID = $OSId is not found"
                        
                    }
                    $OperatingSystemArray
                    $OperatingSystemArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OperatingSystemName { 
                Search-GlpiToolsItems -SearchFor Operatingsystem -SearchType contains -SearchValue $OperatingSystemName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}