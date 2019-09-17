<#
.SYNOPSIS
    Function is getting Generic Device Types informations from GLPI
.DESCRIPTION
    Function is based on GenericDeviceTypeId which you can find in GLPI website
    Returns object with property's of Generic Device Types
.PARAMETER All
    This parameter will return all Generic Device Types from GLPI
.PARAMETER GenericDeviceTypeId
    This parameter can take pipline input, either, you can use this function with -GenericDeviceTypeId keyword.
    Provide to this param GenericDeviceTypeId from GLPI Generic Device Types Bookmark
.PARAMETER Raw
    Parameter which you can use with GenericDeviceTypeId Parameter.
    GenericDeviceTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER GenericDeviceTypeName
    This parameter can take pipline input, either, you can use this function with -GenericDeviceTypeId keyword.
    Provide to this param Generic Device Types Name from GLPI Generic Device Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsGenericDeviceTypes -All
    Example will return all Generic Device Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsGenericDeviceTypes
    Function gets GenericDeviceTypeId from GLPI from Pipline, and return Generic Device Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsGenericDeviceTypes
    Function gets GenericDeviceTypeId from GLPI from Pipline (u can pass many ID's like that), and return Generic Device Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsGenericDeviceTypes -GenericDeviceTypeId 326
    Function gets GenericDeviceTypeId from GLPI which is provided through -GenericDeviceTypeId after Function type, and return Generic Device Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsGenericDeviceTypes -GenericDeviceTypeId 326, 321
    Function gets Generic Device Types Id from GLPI which is provided through -GenericDeviceTypeId keyword after Function type (u can provide many ID's like that), and return Generic Device Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsGenericDeviceTypes -GenericDeviceTypeName Fusion
    Example will return glpi Generic Device Types, but what is the most important, Generic Device Types will be shown exactly as you see in glpi dropdown Generic Device Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Generic Device Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Generic Device Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsGenericDeviceTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "GenericDeviceTypeId")]
        [alias('GDTID')]
        [string[]]$GenericDeviceTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "GenericDeviceTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "GenericDeviceTypeName")]
        [alias('GDTN')]
        [string]$GenericDeviceTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $GenericDeviceTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceGenericType/?range=0-9999999999999"
                }
                
                $GenericDeviceTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GenericDeviceType in $GenericDeviceTypesAll) {
                    $GenericDeviceTypeHash = [ordered]@{ }
                    $GenericDeviceTypeProperties = $GenericDeviceType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($GenericDeviceTypeProp in $GenericDeviceTypeProperties) {
                        $GenericDeviceTypeHash.Add($GenericDeviceTypeProp.Name, $GenericDeviceTypeProp.Value)
                    }
                    $object = [pscustomobject]$GenericDeviceTypeHash
                    $GenericDeviceTypesArray.Add($object)
                }
                $GenericDeviceTypesArray
                $GenericDeviceTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            GenericDeviceTypeId { 
                foreach ( $GDTId in $GenericDeviceTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceGenericType/$($GDTId)"
                    }

                    Try {
                        $GenericDeviceType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $GenericDeviceTypeHash = [ordered]@{ }
                            $GenericDeviceTypeProperties = $GenericDeviceType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($GenericDeviceTypeProp in $GenericDeviceTypeProperties) {
                                $GenericDeviceTypeHash.Add($GenericDeviceTypeProp.Name, $GenericDeviceTypeProp.Value)
                            }
                            $object = [pscustomobject]$GenericDeviceTypeHash
                            $GenericDeviceTypesArray.Add($object)
                        } else {
                            $GenericDeviceTypeHash = [ordered]@{ }
                            $GenericDeviceTypeProperties = $GenericDeviceType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($GenericDeviceTypeProp in $GenericDeviceTypeProperties) {

                                $GenericDeviceTypePropNewValue = Get-GlpiToolsParameters -Parameter $GenericDeviceTypeProp.Name -Value $GenericDeviceTypeProp.Value

                                $GenericDeviceTypeHash.Add($GenericDeviceTypeProp.Name, $GenericDeviceTypePropNewValue)
                            }
                            $object = [pscustomobject]$GenericDeviceTypeHash
                            $GenericDeviceTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Generic Device Type ID = $GDTId is not found"
                        
                    }
                    $GenericDeviceTypesArray
                    $GenericDeviceTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            GenericDeviceTypeName { 
                Search-GlpiToolsItems -SearchFor DeviceGenericType -SearchType contains -SearchValue $GenericDeviceTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}