<#
.SYNOPSIS
    Function is getting OS Kernel Versions informations from GLPI
.DESCRIPTION
    Function is based on OSKernelVersionId which you can find in GLPI website
    Returns object with property's of OS Kernel Versions
.PARAMETER All
    This parameter will return all OS Kernel Versions from GLPI
.PARAMETER OSKernelVersionId
    This parameter can take pipline input, either, you can use this function with -OSKernelVersionId keyword.
    Provide to this param OSKernelVersionId from GLPI OS Kernel Versions Bookmark
.PARAMETER Raw
    Parameter which you can use with OSKernelVersionId Parameter.
    OSKernelVersionId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OSKernelVersionName
    This parameter can take pipline input, either, you can use this function with -OSKernelVersionId keyword.
    Provide to this param OS Kernel Versions Name from GLPI OS Kernel Versions Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSKernelVersions -All
    Example will return all OS Kernel Versions from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOSKernelVersions
    Function gets OSKernelVersionId from GLPI from Pipline, and return OS Kernel Versions object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOSKernelVersions
    Function gets OSKernelVersionId from GLPI from Pipline (u can pass many ID's like that), and return OS Kernel Versions object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSKernelVersions -OSKernelVersionId 326
    Function gets OSKernelVersionId from GLPI which is provided through -OSKernelVersionId after Function type, and return OS Kernel Versions object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOSKernelVersions -OSKernelVersionId 326, 321
    Function gets OS Kernel VersionsId from GLPI which is provided through -OSKernelVersionId keyword after Function type (u can provide many ID's like that), and return OS Kernel Versions object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSKernelVersions -OSKernelVersionName Fusion
    Example will return glpi OS Kernel Versions, but what is the most important, OS Kernel Versions will be shown exactly as you see in glpi dropdown OS Kernel Versions.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    OS Kernel Versions ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of OS Kernel Versions from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsOSKernelVersions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OSKernelVersionId")]
        [alias('OSKVID')]
        [string[]]$OSKernelVersionId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OSKernelVersionId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OSKernelVersionName")]
        [alias('OSKVN')]
        [string]$OSKernelVersionName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OSKernelVersionsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Operatingsystemkernelversion/?range=0-9999999999999"
                }
                
                $OSKernelVersionsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OSKernelVersion in $OSKernelVersionsAll) {
                    $OSKernelVersionHash = [ordered]@{ }
                    $OSKernelVersionProperties = $OSKernelVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OSKernelVersionProp in $OSKernelVersionProperties) {
                        $OSKernelVersionHash.Add($OSKernelVersionProp.Name, $OSKernelVersionProp.Value)
                    }
                    $object = [pscustomobject]$OSKernelVersionHash
                    $OSKernelVersionsArray.Add($object)
                }
                $OSKernelVersionsArray
                $OSKernelVersionsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OSKernelVersionId { 
                foreach ( $OSKVId in $OSKernelVersionId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Operatingsystemkernelversion/$($OSKVId)"
                    }

                    Try {
                        $OSKernelVersion = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OSKernelVersionHash = [ordered]@{ }
                            $OSKernelVersionProperties = $OSKernelVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSKernelVersionProp in $OSKernelVersionProperties) {
                                $OSKernelVersionHash.Add($OSKernelVersionProp.Name, $OSKernelVersionProp.Value)
                            }
                            $object = [pscustomobject]$OSKernelVersionHash
                            $OSKernelVersionsArray.Add($object)
                        } else {
                            $OSKernelVersionHash = [ordered]@{ }
                            $OSKernelVersionProperties = $OSKernelVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSKernelVersionProp in $OSKernelVersionProperties) {

                                $OSKernelVersionPropNewValue = Get-GlpiToolsParameters -Parameter $OSKernelVersionProp.Name -Value $OSKernelVersionProp.Value

                                $OSKernelVersionHash.Add($OSKernelVersionProp.Name, $OSKernelVersionPropNewValue)
                            }
                            $object = [pscustomobject]$OSKernelVersionHash
                            $OSKernelVersionsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "OS Kernel Version ID = $OSKVId is not found"
                        
                    }
                    $OSKernelVersionsArray
                    $OSKernelVersionsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OSKernelVersionName { 
                Search-GlpiToolsItems -SearchFor Operatingsystemkernelversion -SearchType contains -SearchValue $OSKernelVersionName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}