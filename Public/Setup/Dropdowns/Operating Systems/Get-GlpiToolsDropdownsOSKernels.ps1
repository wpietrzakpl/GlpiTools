<#
.SYNOPSIS
    Function is getting OS Kernels informations from GLPI
.DESCRIPTION
    Function is based on OSKernelId which you can find in GLPI website
    Returns object with property's of OS Kernels
.PARAMETER All
    This parameter will return all OS Kernels from GLPI
.PARAMETER OSKernelId
    This parameter can take pipline input, either, you can use this function with -OSKernelId keyword.
    Provide to this param OSKernelId from GLPI OS Kernels Bookmark
.PARAMETER Raw
    Parameter which you can use with OSKernelId Parameter.
    OSKernelId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OSKernelName
    This parameter can take pipline input, either, you can use this function with -OSKernelId keyword.
    Provide to this param OS Kernels Name from GLPI OS Kernels Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSKernels -All
    Example will return all OS Kernels from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOSKernels
    Function gets OSKernelId from GLPI from Pipline, and return OS Kernels object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOSKernels
    Function gets OSKernelId from GLPI from Pipline (u can pass many ID's like that), and return OS Kernels object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSKernels -OSKernelId 326
    Function gets OSKernelId from GLPI which is provided through -OSKernelId after Function type, and return OS Kernels object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOSKernels -OSKernelId 326, 321
    Function gets OS KernelsId from GLPI which is provided through -OSKernelId keyword after Function type (u can provide many ID's like that), and return OS Kernels object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSKernels -OSKernelName Fusion
    Example will return glpi OS Kernels, but what is the most important, OS Kernels will be shown exactly as you see in glpi dropdown OS Kernels.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    OS Kernels ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of OS Kernels from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsOSKernels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OSKernelId")]
        [alias('OSKID')]
        [string[]]$OSKernelId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OSKernelId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OSKernelName")]
        [alias('OSKN')]
        [string]$OSKernelName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OSKernelsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/operatingsystemkernel/?range=0-9999999999999"
                }
                
                $OSKernelsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OSKernel in $OSKernelsAll) {
                    $OSKernelHash = [ordered]@{ }
                    $OSKernelProperties = $OSKernel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OSKernelProp in $OSKernelProperties) {
                        $OSKernelHash.Add($OSKernelProp.Name, $OSKernelProp.Value)
                    }
                    $object = [pscustomobject]$OSKernelHash
                    $OSKernelsArray.Add($object)
                }
                $OSKernelsArray
                $OSKernelsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OSKernelId { 
                foreach ( $OSKId in $OSKernelId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/operatingsystemkernel/$($OSKId)"
                    }

                    Try {
                        $OSKernel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OSKernelHash = [ordered]@{ }
                            $OSKernelProperties = $OSKernel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSKernelProp in $OSKernelProperties) {
                                $OSKernelHash.Add($OSKernelProp.Name, $OSKernelProp.Value)
                            }
                            $object = [pscustomobject]$OSKernelHash
                            $OSKernelsArray.Add($object)
                        } else {
                            $OSKernelHash = [ordered]@{ }
                            $OSKernelProperties = $OSKernel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSKernelProp in $OSKernelProperties) {

                                $OSKernelPropNewValue = Get-GlpiToolsParameters -Parameter $OSKernelProp.Name -Value $OSKernelProp.Value

                                $OSKernelHash.Add($OSKernelProp.Name, $OSKernelPropNewValue)
                            }
                            $object = [pscustomobject]$OSKernelHash
                            $OSKernelsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "OS Kernel ID = $OSKId is not found"
                        
                    }
                    $OSKernelsArray
                    $OSKernelsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OSKernelName { 
                Search-GlpiToolsItems -SearchFor Operatingsystemkernel -SearchType contains -SearchValue $OSKernelName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}