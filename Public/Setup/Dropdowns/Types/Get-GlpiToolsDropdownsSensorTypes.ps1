<#
.SYNOPSIS
    Function is getting Sensor Types informations from GLPI
.DESCRIPTION
    Function is based on SensorTypeId which you can find in GLPI website
    Returns object with property's of Sensor Types
.PARAMETER All
    This parameter will return all Sensor Types from GLPI
.PARAMETER SensorTypeId
    This parameter can take pipline input, either, you can use this function with -SensorTypeId keyword.
    Provide to this param SensorTypeId from GLPI Sensor Types Bookmark
.PARAMETER Raw
    Parameter which you can use with SensorTypeId Parameter.
    SensorTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER SensorTypeName
    This parameter can take pipline input, either, you can use this function with -SensorTypeId keyword.
    Provide to this param Sensor Types Name from GLPI Sensor Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSensorTypes -All
    Example will return all Sensor Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsSensorTypes
    Function gets SensorTypeId from GLPI from Pipline, and return Sensor Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsSensorTypes
    Function gets SensorTypeId from GLPI from Pipline (u can pass many ID's like that), and return Sensor Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSensorTypes -SensorTypeId 326
    Function gets SensorTypeId from GLPI which is provided through -SensorTypeId after Function type, and return Sensor Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsSensorTypes -SensorTypeId 326, 321
    Function gets Sensor Types Id from GLPI which is provided through -SensorTypeId keyword after Function type (u can provide many ID's like that), and return Sensor Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsSensorTypes -SensorTypeName Fusion
    Example will return glpi Sensor Types, but what is the most important, Sensor Types will be shown exactly as you see in glpi dropdown Sensor Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Sensor Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Sensor Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsSensorTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SensorTypeId")]
        [alias('STID')]
        [string[]]$SensorTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SensorTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "SensorTypeName")]
        [alias('STN')]
        [string]$SensorTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SensorTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DeviceSensorType/?range=0-9999999999999"
                }
                
                $SensorTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($SensorType in $SensorTypesAll) {
                    $SensorTypeHash = [ordered]@{ }
                    $SensorTypeProperties = $SensorType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SensorTypeProp in $SensorTypeProperties) {
                        $SensorTypeHash.Add($SensorTypeProp.Name, $SensorTypeProp.Value)
                    }
                    $object = [pscustomobject]$SensorTypeHash
                    $SensorTypesArray.Add($object)
                }
                $SensorTypesArray
                $SensorTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            SensorTypeId { 
                foreach ( $STId in $SensorTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DeviceSensorType/$($STId)"
                    }

                    Try {
                        $SensorType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SensorTypeHash = [ordered]@{ }
                            $SensorTypeProperties = $SensorType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SensorTypeProp in $SensorTypeProperties) {
                                $SensorTypeHash.Add($SensorTypeProp.Name, $SensorTypeProp.Value)
                            }
                            $object = [pscustomobject]$SensorTypeHash
                            $SensorTypesArray.Add($object)
                        } else {
                            $SensorTypeHash = [ordered]@{ }
                            $SensorTypeProperties = $SensorType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SensorTypeProp in $SensorTypeProperties) {

                                $SensorTypePropNewValue = Get-GlpiToolsParameters -Parameter $SensorTypeProp.Name -Value $SensorTypeProp.Value

                                $SensorTypeHash.Add($SensorTypeProp.Name, $SensorTypePropNewValue)
                            }
                            $object = [pscustomobject]$SensorTypeHash
                            $SensorTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Sensor Type ID = $STId is not found"
                        
                    }
                    $SensorTypesArray
                    $SensorTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            SensorTypeName { 
                Search-GlpiToolsItems -SearchFor DeviceSensorType -SearchType contains -SearchValue $SensorTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}