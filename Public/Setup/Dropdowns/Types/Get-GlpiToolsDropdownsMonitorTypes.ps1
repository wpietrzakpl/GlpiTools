<#
.SYNOPSIS
    Function is getting Monitor Types informations from GLPI
.DESCRIPTION
    Function is based on MonitorTypeId which you can find in GLPI website
    Returns object with property's of Monitor Types
.PARAMETER All
    This parameter will return all Monitor Types from GLPI
.PARAMETER MonitorTypeId
    This parameter can take pipline input, either, you can use this function with -MonitorTypeId keyword.
    Provide to this param MonitorTypeId from GLPI Monitor Types Bookmark
.PARAMETER Raw
    Parameter which you can use with MonitorTypeId Parameter.
    MonitorTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER MonitorTypeName
    This parameter can take pipline input, either, you can use this function with -MonitorTypeId keyword.
    Provide to this param Monitor Types Name from GLPI Monitor Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMonitorTypes -All
    Example will return all Monitor Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsMonitorTypes
    Function gets MonitorTypeId from GLPI from Pipline, and return Monitor Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsMonitorTypes
    Function gets MonitorTypeId from GLPI from Pipline (u can pass many ID's like that), and return Monitor Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMonitorTypes -MonitorTypeId 326
    Function gets MonitorTypeId from GLPI which is provided through -MonitorTypeId after Function type, and return Monitor Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsMonitorTypes -MonitorTypeId 326, 321
    Function gets Monitor Types Id from GLPI which is provided through -MonitorTypeId keyword after Function type (u can provide many ID's like that), and return Monitor Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsMonitorTypes -MonitorTypeName Fusion
    Example will return glpi Monitor Types, but what is the most important, Monitor Types will be shown exactly as you see in glpi dropdown Monitor Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Monitor Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Monitor Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsMonitorTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "MonitorTypeId")]
        [alias('MTID')]
        [string[]]$MonitorTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "MonitorTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "MonitorTypeName")]
        [alias('MTN')]
        [string]$MonitorTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $MonitorTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/monitortype/?range=0-9999999999999"
                }
                
                $MonitorTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($MonitorType in $MonitorTypesAll) {
                    $MonitorTypeHash = [ordered]@{ }
                    $MonitorTypeProperties = $MonitorType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($MonitorTypeProp in $MonitorTypeProperties) {
                        $MonitorTypeHash.Add($MonitorTypeProp.Name, $MonitorTypeProp.Value)
                    }
                    $object = [pscustomobject]$MonitorTypeHash
                    $MonitorTypesArray.Add($object)
                }
                $MonitorTypesArray
                $MonitorTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            MonitorTypeId { 
                foreach ( $MTId in $MonitorTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/monitortype/$($MTId)"
                    }

                    Try {
                        $MonitorType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $MonitorTypeHash = [ordered]@{ }
                            $MonitorTypeProperties = $MonitorType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MonitorTypeProp in $MonitorTypeProperties) {
                                $MonitorTypeHash.Add($MonitorTypeProp.Name, $MonitorTypeProp.Value)
                            }
                            $object = [pscustomobject]$MonitorTypeHash
                            $MonitorTypesArray.Add($object)
                        } else {
                            $MonitorTypeHash = [ordered]@{ }
                            $MonitorTypeProperties = $MonitorType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MonitorTypeProp in $MonitorTypeProperties) {

                                $MonitorTypePropNewValue = Get-GlpiToolsParameters -Parameter $MonitorTypeProp.Name -Value $MonitorTypeProp.Value

                                $MonitorTypeHash.Add($MonitorTypeProp.Name, $MonitorTypePropNewValue)
                            }
                            $object = [pscustomobject]$MonitorTypeHash
                            $MonitorTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Monitor Type ID = $MTId is not found"
                        
                    }
                    $MonitorTypesArray
                    $MonitorTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            MonitorTypeName { 
                Search-GlpiToolsItems -SearchFor monitortype -SearchType contains -SearchValue $MonitorTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}