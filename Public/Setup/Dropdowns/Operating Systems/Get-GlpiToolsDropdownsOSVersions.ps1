<#
.SYNOPSIS
    Function is getting Operating Systems Versions informations from GLPI
.DESCRIPTION
    Function is based on OSVersionId which you can find in GLPI website
    Returns object with property's of Operating Systems Versions
.PARAMETER All
    This parameter will return all Operating Systems Versions from GLPI
.PARAMETER OSVersionId
    This parameter can take pipline input, either, you can use this function with -OSVersionId keyword.
    Provide to this param OSVersionId from GLPI Operating Systems Versions Bookmark
.PARAMETER Raw
    Parameter which you can use with OSVersionId Parameter.
    OSVersionId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OSVersionName
    This parameter can take pipline input, either, you can use this function with -OSVersionId keyword.
    Provide to this param Operating Systems Versions Name from GLPI Operating Systems Versions Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSVersions -All
    Example will return all Operating Systems Versions from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOSVersions
    Function gets OSVersionId from GLPI from Pipline, and return Operating Systems Versions object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOSVersions
    Function gets OSVersionId from GLPI from Pipline (u can pass many ID's like that), and return Operating Systems Versions object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSVersions -OSVersionId 326
    Function gets OSVersionId from GLPI which is provided through -OSVersionId after Function type, and return Operating Systems Versions object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOSVersions -OSVersionId 326, 321
    Function gets Operating Systems VersionsId from GLPI which is provided through -OSVersionId keyword after Function type (u can provide many ID's like that), and return Operating Systems Versions object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSVersions -OSVersionName Fusion
    Example will return glpi Operating Systems Versions, but what is the most important, Operating Systems Versions will be shown exactly as you see in glpi dropdown Operating Systems Versions.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Operating Systems Versions ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Operating Systems Versions from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsOSVersions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OSVersionId")]
        [alias('OSVID')]
        [string[]]$OSVersionId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OSVersionId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OSVersionName")]
        [alias('OSVN')]
        [string]$OSVersionName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OSVersionsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/operatingsystemversion/?range=0-9999999999999"
                }
                
                $OSVersionsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OSVersion in $OSVersionsAll) {
                    $OSVersionHash = [ordered]@{ }
                    $OSVersionProperties = $OSVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OSVersionProp in $OSVersionProperties) {
                        $OSVersionHash.Add($OSVersionProp.Name, $OSVersionProp.Value)
                    }
                    $object = [pscustomobject]$OSVersionHash
                    $OSVersionsArray.Add($object)
                }
                $OSVersionsArray
                $OSVersionsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OSVersionId { 
                foreach ( $OSVId in $OSVersionId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/operatingsystemversion/$($OSVId)"
                    }

                    Try {
                        $OSVersion = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OSVersionHash = [ordered]@{ }
                            $OSVersionProperties = $OSVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSVersionProp in $OSVersionProperties) {
                                $OSVersionHash.Add($OSVersionProp.Name, $OSVersionProp.Value)
                            }
                            $object = [pscustomobject]$OSVersionHash
                            $OSVersionsArray.Add($object)
                        } else {
                            $OSVersionHash = [ordered]@{ }
                            $OSVersionProperties = $OSVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSVersionProp in $OSVersionProperties) {

                                $OSVersionPropNewValue = Get-GlpiToolsParameters -Parameter $OSVersionProp.Name -Value $OSVersionProp.Value

                                $OSVersionHash.Add($OSVersionProp.Name, $OSVersionPropNewValue)
                            }
                            $object = [pscustomobject]$OSVersionHash
                            $OSVersionsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Operating Systems Versions ID = $OSVId is not found"
                        
                    }
                    $OSVersionsArray
                    $OSVersionsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OSVersionName { 
                Search-GlpiToolsItems -SearchFor operatingsystemversion -SearchType contains -SearchValue $OSVersionName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}