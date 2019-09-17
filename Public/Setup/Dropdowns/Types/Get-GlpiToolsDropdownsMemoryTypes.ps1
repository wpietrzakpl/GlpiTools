<#
.SYNOPSIS
    Function is getting Memory Types informations from GLPI
.DESCRIPTION
    Function is based on MemoryTypeId which you can find in GLPI website
    Returns object with property's of Memory Types
.PARAMETER All
    This parameter will return all Memory Types from GLPI
.PARAMETER MemoryTypeId
    This parameter can take pipline input, either, you can use this function with -MemoryTypeId keyword.
    Provide to this param MemoryTypeId from GLPI Memory Types Bookmark
.PARAMETER Raw
    Parameter which you can use with MemoryTypeId Parameter.
    MemoryTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER MemoryTypeName
    This parameter can take pipline input, either, you can use this function with -MemoryTypeId keyword.
    Provide to this param Memory Types Name from GLPI Memory Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMemoryTypes -All
    Example will return all Memory Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsMemoryTypes
    Function gets MemoryTypeId from GLPI from Pipline, and return Memory Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsMemoryTypes
    Function gets MemoryTypeId from GLPI from Pipline (u can pass many ID's like that), and return Memory Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMemoryTypes -MemoryTypeId 326
    Function gets MemoryTypeId from GLPI which is provided through -MemoryTypeId after Function type, and return Memory Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsMemoryTypes -MemoryTypeId 326, 321
    Function gets Memory Types Id from GLPI which is provided through -MemoryTypeId keyword after Function type (u can provide many ID's like that), and return Memory Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMemoryTypes -MemoryTypeName Fusion
    Example will return glpi Memory Types, but what is the most important, Memory Types will be shown exactly as you see in glpi dropdown Memory Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Memory Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Memory Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsMemoryTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "MemoryTypeId")]
        [alias('MTID')]
        [string[]]$MemoryTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "MemoryTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "MemoryTypeName")]
        [alias('MTN')]
        [string]$MemoryTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $MemoryTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceMemoryType/?range=0-9999999999999"
                }
                
                $MemoryTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($MemoryType in $MemoryTypesAll) {
                    $MemoryTypeHash = [ordered]@{ }
                    $MemoryTypeProperties = $MemoryType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($MemoryTypeProp in $MemoryTypeProperties) {
                        $MemoryTypeHash.Add($MemoryTypeProp.Name, $MemoryTypeProp.Value)
                    }
                    $object = [pscustomobject]$MemoryTypeHash
                    $MemoryTypesArray.Add($object)
                }
                $MemoryTypesArray
                $MemoryTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            MemoryTypeId { 
                foreach ( $MTId in $MemoryTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceMemoryType/$($MTId)"
                    }

                    Try {
                        $MemoryType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $MemoryTypeHash = [ordered]@{ }
                            $MemoryTypeProperties = $MemoryType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MemoryTypeProp in $MemoryTypeProperties) {
                                $MemoryTypeHash.Add($MemoryTypeProp.Name, $MemoryTypeProp.Value)
                            }
                            $object = [pscustomobject]$MemoryTypeHash
                            $MemoryTypesArray.Add($object)
                        } else {
                            $MemoryTypeHash = [ordered]@{ }
                            $MemoryTypeProperties = $MemoryType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MemoryTypeProp in $MemoryTypeProperties) {

                                $MemoryTypePropNewValue = Get-GlpiToolsParameters -Parameter $MemoryTypeProp.Name -Value $MemoryTypeProp.Value

                                $MemoryTypeHash.Add($MemoryTypeProp.Name, $MemoryTypePropNewValue)
                            }
                            $object = [pscustomobject]$MemoryTypeHash
                            $MemoryTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Memory Type ID = $MTId is not found"
                        
                    }
                    $MemoryTypesArray
                    $MemoryTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            MemoryTypeName { 
                Search-GlpiToolsItems -SearchFor DeviceMemoryType -SearchType contains -SearchValue $MemoryTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}