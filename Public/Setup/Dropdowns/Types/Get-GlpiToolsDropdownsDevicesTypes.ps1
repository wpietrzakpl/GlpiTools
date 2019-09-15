<#
.SYNOPSIS
    Function is getting Devices Types informations from GLPI
.DESCRIPTION
    Function is based on DeviceTypeId which you can find in GLPI website
    Returns object with property's of Devices Types
.PARAMETER All
    This parameter will return all Devices Types from GLPI
.PARAMETER DeviceTypeId
    This parameter can take pipline input, either, you can use this function with -DeviceTypeId keyword.
    Provide to this param DeviceTypeId from GLPI Devices Types Bookmark
.PARAMETER Raw
    Parameter which you can use with DeviceTypeId Parameter.
    DeviceTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DeviceTypeName
    This parameter can take pipline input, either, you can use this function with -DeviceTypeId keyword.
    Provide to this param Devices Types Name from GLPI Devices Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDevicesTypes -All
    Example will return all Devices Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDevicesTypes
    Function gets DeviceTypeId from GLPI from Pipline, and return Devices Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDevicesTypes
    Function gets DeviceTypeId from GLPI from Pipline (u can pass many ID's like that), and return Devices Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDevicesTypes -DeviceTypeId 326
    Function gets DeviceTypeId from GLPI which is provided through -DeviceTypeId after Function type, and return Devices Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDevicesTypes -DeviceTypeId 326, 321
    Function gets Devices Types Id from GLPI which is provided through -DeviceTypeId keyword after Function type (u can provide many ID's like that), and return Devices Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDevicesTypes -DeviceTypeName Fusion
    Example will return glpi Devices Types, but what is the most important, Devices Types will be shown exactly as you see in glpi dropdown Devices Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Devices Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Devices Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsDevicesTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DeviceTypeId")]
        [alias('DTID')]
        [string[]]$DeviceTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DeviceTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DeviceTypeName")]
        [alias('DTN')]
        [string]$DeviceTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DevicesTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/peripheraltype/?range=0-9999999999999"
                }
                
                $DevicesTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DeviceType in $DevicesTypesAll) {
                    $DeviceTypeHash = [ordered]@{ }
                    $DeviceTypeProperties = $DeviceType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DeviceTypeProp in $DeviceTypeProperties) {
                        $DeviceTypeHash.Add($DeviceTypeProp.Name, $DeviceTypeProp.Value)
                    }
                    $object = [pscustomobject]$DeviceTypeHash
                    $DevicesTypesArray.Add($object)
                }
                $DevicesTypesArray
                $DevicesTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DeviceTypeId { 
                foreach ( $DTId in $DeviceTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/peripheraltype/$($DTId)"
                    }

                    Try {
                        $DeviceType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DeviceTypeHash = [ordered]@{ }
                            $DeviceTypeProperties = $DeviceType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceTypeProp in $DeviceTypeProperties) {
                                $DeviceTypeHash.Add($DeviceTypeProp.Name, $DeviceTypeProp.Value)
                            }
                            $object = [pscustomobject]$DeviceTypeHash
                            $DevicesTypesArray.Add($object)
                        } else {
                            $DeviceTypeHash = [ordered]@{ }
                            $DeviceTypeProperties = $DeviceType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DeviceTypeProp in $DeviceTypeProperties) {

                                $DeviceTypePropNewValue = Get-GlpiToolsParameters -Parameter $DeviceTypeProp.Name -Value $DeviceTypeProp.Value

                                $DeviceTypeHash.Add($DeviceTypeProp.Name, $DeviceTypePropNewValue)
                            }
                            $object = [pscustomobject]$DeviceTypeHash
                            $DevicesTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Device Type ID = $DTId is not found"
                        
                    }
                    $DevicesTypesArray
                    $DevicesTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DeviceTypeName { 
                Search-GlpiToolsItems -SearchFor peripheraltype -SearchType contains -SearchValue $DeviceTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}