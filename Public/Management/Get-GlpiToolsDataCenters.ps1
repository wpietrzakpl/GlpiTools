<#
.SYNOPSIS
    Function is getting Data Center informations from GLPI
.DESCRIPTION
    Function is based on DataCenterId which you can find in GLPI website
    Returns object with property's of Data Center
.PARAMETER All
    This parameter will return all Data Center from GLPI
.PARAMETER DataCenterId
    This parameter can take pipData Center input, either, you can use this function with -DataCenterId keyword.
    Provide to this param DataCenterId from GLPI Data Center Bookmark
.PARAMETER Raw
    Parameter which you can use with DataCenterId Parameter.
    DataCenterId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DataCenterName
    This parameter can take pipData Center input, either, you can use this function with -DataCenterId keyword.
    Provide to this param Data Center Name from GLPI Data Center Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDataCenters -All
    Example will return all Data Center from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDataCenters
    Function gets DataCenterId from GLPI from PipData Center, and return Data Center object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDataCenters
    Function gets DataCenterId from GLPI from PipData Center (u can pass many ID's like that), and return Data Center object
.EXAMPLE
    PS C:\> Get-GlpiToolsDataCenters -DataCenterId 326
    Function gets DataCenterId from GLPI which is provided through -DataCenterId after Function type, and return Data Center object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDataCenters -DataCenterId 326, 321
    Function gets Data Center Id from GLPI which is provided through -DataCenterId keyword after Function type (u can provide many ID's like that), and return Data Center object
.EXAMPLE
    PS C:\> Get-GlpiToolsDataCenters -DataCenterName Fusion
    Example will return glpi Data Center, but what is the most important, Data Center will be shown exactly as you see in glpi dropdown Data Center.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Data Center ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Data Center from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsDataCenters {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeLine = $true,
            ParameterSetName = "DataCenterId")]
        [alias('DCID')]
        [string[]]$DataCenterId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DataCenterId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DataCenterName")]
        [alias('DCN')]
        [string]$DataCenterName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DataCentersArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/DataCenter/?range=0-9999999999999"
                }
                
                $DataCentersAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DataCenter in $DataCentersAll) {
                    $DataCenterHash = [ordered]@{ }
                    $DataCenterProperties = $DataCenter.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DataCenterProp in $DataCenterProperties) {
                        $DataCenterHash.Add($DataCenterProp.Name, $DataCenterProp.Value)
                    }
                    $object = [pscustomobject]$DataCenterHash
                    $DataCentersArray.Add($object)
                }
                $DataCentersArray
                $DataCentersArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            DataCenterId { 
                foreach ( $DCId in $DataCenterId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/DataCenter/$($DCId)"
                    }

                    Try {
                        $DataCenter = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DataCenterHash = [ordered]@{ }
                            $DataCenterProperties = $DataCenter.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DataCenterProp in $DataCenterProperties) {
                                $DataCenterHash.Add($DataCenterProp.Name, $DataCenterProp.Value)
                            }
                            $object = [pscustomobject]$DataCenterHash
                            $DataCentersArray.Add($object)
                        } else {
                            $DataCenterHash = [ordered]@{ }
                            $DataCenterProperties = $DataCenter.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DataCenterProp in $DataCenterProperties) {

                                $DataCenterPropNewValue = Get-GlpiToolsParameters -Parameter $DataCenterProp.Name -Value $DataCenterProp.Value

                                $DataCenterHash.Add($DataCenterProp.Name, $DataCenterPropNewValue)
                            }
                            $object = [pscustomobject]$DataCenterHash
                            $DataCentersArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Data Center ID = $DCId is not found"
                        
                    }
                    $DataCentersArray
                    $DataCentersArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            DataCenterName { 
                Search-GlpiToolsItems -SearchFor DataCenter -SearchType contains -SearchValue $DataCenterName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}