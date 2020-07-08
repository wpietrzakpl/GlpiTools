<#
.SYNOPSIS
    Function is getting Rack Types informations from GLPI
.DESCRIPTION
    Function is based on RackTypeId which you can find in GLPI website
    Returns object with property's of Rack Types
.PARAMETER All
    This parameter will return all Rack Types from GLPI
.PARAMETER RackTypeId
    This parameter can take pipeline input, either, you can use this function with -RackTypeId keyword.
    Provide to this param RackTypeId from GLPI Rack Types Bookmark
.PARAMETER Raw
    Parameter which you can use with RackTypeId Parameter.
    RackTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER RackTypeName
    This parameter can take pipeline input, either, you can use this function with -RackTypeId keyword.
    Provide to this param Rack Types Name from GLPI Rack Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRackTypes -All
    Example will return all Rack Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsRackTypes
    Function gets RackTypeId from GLPI from pipeline, and return Rack Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsRackTypes
    Function gets RackTypeId from GLPI from pipeline (u can pass many ID's like that), and return Rack Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRackTypes -RackTypeId 326
    Function gets RackTypeId from GLPI which is provided through -RackTypeId after Function type, and return Rack Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsRackTypes -RackTypeId 326, 321
    Function gets Rack Types Id from GLPI which is provided through -RackTypeId keyword after Function type (u can provide many ID's like that), and return Rack Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsRackTypes -RackTypeName Fusion
    Example will return glpi Rack Types, but what is the most important, Rack Types will be shown exactly as you see in glpi dropdown Rack Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Rack Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Rack Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsRackTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "RackTypeId")]
        [alias('RTID')]
        [string[]]$RackTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "RackTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "RackTypeName")]
        [alias('RTN')]
        [string]$RackTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $RackTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Racktype/?range=0-9999999999999"
                }
                
                $RackTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($RackType in $RackTypesAll) {
                    $RackTypeHash = [ordered]@{ }
                    $RackTypeProperties = $RackType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($RackTypeProp in $RackTypeProperties) {
                        $RackTypeHash.Add($RackTypeProp.Name, $RackTypeProp.Value)
                    }
                    $object = [pscustomobject]$RackTypeHash
                    $RackTypesArray.Add($object)
                }
                $RackTypesArray
                $RackTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            RackTypeId { 
                foreach ( $RTId in $RackTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Racktype/$($RTId)"
                    }

                    Try {
                        $RackType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $RackTypeHash = [ordered]@{ }
                            $RackTypeProperties = $RackType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RackTypeProp in $RackTypeProperties) {
                                $RackTypeHash.Add($RackTypeProp.Name, $RackTypeProp.Value)
                            }
                            $object = [pscustomobject]$RackTypeHash
                            $RackTypesArray.Add($object)
                        } else {
                            $RackTypeHash = [ordered]@{ }
                            $RackTypeProperties = $RackType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RackTypeProp in $RackTypeProperties) {

                                $RackTypePropNewValue = Get-GlpiToolsParameters -Parameter $RackTypeProp.Name -Value $RackTypeProp.Value

                                $RackTypeHash.Add($RackTypeProp.Name, $RackTypePropNewValue)
                            }
                            $object = [pscustomobject]$RackTypeHash
                            $RackTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Rack Type ID = $RTId is not found"
                        
                    }
                    $RackTypesArray
                    $RackTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            RackTypeName { 
                Search-GlpiToolsItems -SearchFor Racktype -SearchType contains -SearchValue $RackTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}