<#
.SYNOPSIS
    Function is getting Operating Systems Service Packs informations from GLPI
.DESCRIPTION
    Function is based on OSServicePackId which you can find in GLPI website
    Returns object with property's of Operating Systems Service Packs
.PARAMETER All
    This parameter will return all Operating Systems Service Packs from GLPI
.PARAMETER OSServicePackId
    This parameter can take pipline input, either, you can use this function with -OSServicePackId keyword.
    Provide to this param OSServicePackId from GLPI Operating Systems Service Packs Bookmark
.PARAMETER Raw
    Parameter which you can use with OSServicePackId Parameter.
    OSServicePackId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OSServicePackName
    This parameter can take pipline input, either, you can use this function with -OSServicePackId keyword.
    Provide to this param Operating Systems Service Packs Name from GLPI Operating Systems Service Packs Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSServicePacks -All
    Example will return all Operating Systems Service Packs from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOSServicePacks
    Function gets OSServicePackId from GLPI from Pipline, and return Operating Systems Service Packs object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOSServicePacks
    Function gets OSServicePackId from GLPI from Pipline (u can pass many ID's like that), and return Operating Systems Service Packs object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSServicePacks -OSServicePackId 326
    Function gets OSServicePackId from GLPI which is provided through -OSServicePackId after Function type, and return Operating Systems Service Packs object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOSServicePacks -OSServicePackId 326, 321
    Function gets Operating Systems Service PacksId from GLPI which is provided through -OSServicePackId keyword after Function type (u can provide many ID's like that), and return Operating Systems Service Packs object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSServicePacks -OSServicePackName Fusion
    Example will return glpi Operating Systems Service Packs, but what is the most important, Operating Systems Service Packs will be shown exactly as you see in glpi dropdown Operating Systems Service Packs.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Operating Systems Service Packs ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Operating Systems Service Packs from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsOSServicePacks {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OSServicePackId")]
        [alias('OSSPID')]
        [string[]]$OSServicePackId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OSServicePackId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OSServicePackName")]
        [alias('OSPN')]
        [string]$OSServicePackName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OSServicePacksArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/OperatingSystemServicePack/?range=0-9999999999999"
                }
                
                $OSServicePacksAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OSServicePack in $OSServicePacksAll) {
                    $OSServicePackHash = [ordered]@{ }
                    $OSServicePackProperties = $OSServicePack.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OSServicePackProp in $OSServicePackProperties) {
                        $OSServicePackHash.Add($OSServicePackProp.Name, $OSServicePackProp.Value)
                    }
                    $object = [pscustomobject]$OSServicePackHash
                    $OSServicePacksArray.Add($object)
                }
                $OSServicePacksArray
                $OSServicePacksArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OSServicePackId { 
                foreach ( $OSSPId in $OSServicePackId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/OperatingSystemServicePack/$($OSSPId)"
                    }

                    Try {
                        $OSServicePack = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OSServicePackHash = [ordered]@{ }
                            $OSServicePackProperties = $OSServicePack.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSServicePackProp in $OSServicePackProperties) {
                                $OSServicePackHash.Add($OSServicePackProp.Name, $OSServicePackProp.Value)
                            }
                            $object = [pscustomobject]$OSServicePackHash
                            $OSServicePacksArray.Add($object)
                        } else {
                            $OSServicePackHash = [ordered]@{ }
                            $OSServicePackProperties = $OSServicePack.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSServicePackProp in $OSServicePackProperties) {

                                $OSServicePackPropNewValue = Get-GlpiToolsParameters -Parameter $OSServicePackProp.Name -Value $OSServicePackProp.Value

                                $OSServicePackHash.Add($OSServicePackProp.Name, $OSServicePackPropNewValue)
                            }
                            $object = [pscustomobject]$OSServicePackHash
                            $OSServicePacksArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Operating Systems Service Packs ID = $OSSPId is not found"
                        
                    }
                    $OSServicePacksArray
                    $OSServicePacksArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OSServicePackName { 
                Search-GlpiToolsItems -SearchFor OperatingSystemServicePack -SearchType contains -SearchValue $OSServicePackName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}