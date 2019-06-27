<#
.SYNOPSIS
    Function is getting Manufacturer informations from GLPI
.DESCRIPTION
    Function is based on ManufacturerID which you can find in GLPI website
    Returns object with property's of Manufacturer
.PARAMETER All
    This parameter will return all Manufacturer from GLPI
.PARAMETER ManufacturerId
    This parameter can take pipline input, either, you can use this function with -ManufacturerId keyword.
    Provide to this param Manufacturer ID from GLPI Manufacturer Bookmark
.PARAMETER Raw
    Parameter which you can use with ManufacturerId Parameter.
    ManufacturerId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER Manufacturer
    This parameter can take pipline input, either, you can use this function with -Manufacturer keyword.
    Provide to this param Manufacturer Name from GLPI Manufacturer Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsManufacturers -All
    Example will return all Manufacturer from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsManufacturers
    Function gets ManufacturerId from GLPI from Pipline, and return Manufacturer object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsManufacturers
    Function gets ManufacturerId from GLPI from Pipline (u can pass many ID's like that), and return Manufacturer object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsManufacturers -ManufacturerId 326
    Function gets ManufacturerId from GLPI which is provided through -ManufacturerId after Function type, and return Manufacturer object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsManufacturers -ManufacturerId 326, 321
    Function gets ManufacturerId from GLPI which is provided through -ManufacturerId keyword after Function type (u can provide many ID's like that), and return Manufacturer object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsManufacturers -Manufacturer Fusion
    Example will return glpi Manufacturer, but what is the most important, Manufacturer will be shown exactly as you see in glpi dropdown Manufacturer.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Manufacturer ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Manufacturer from GLPI
.NOTES
    PSP 06/2019
#>

function Get-GlpiToolsDropdownsManufacturers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ManufacturerId")]
        [alias('MID')]
        [string[]]$ManufacturerId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ManufacturerId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ManufacturerName")]
        [alias('MN')]
        [string]$ManufacturerName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ManufacturerArray = @()
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
                    uri     = "$($PathToGlpi)/Manufacturer/?range=0-9999999999999"
                }
                
                $GlpiManufacturerAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ManufacturerModel in $GlpiManufacturerAll) {
                    $ManufacturerHash = [ordered]@{ }
                    $ManufacturerProperties = $ManufacturerModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ManufacturerProp in $ManufacturerProperties) {
                        $ManufacturerHash.Add($ManufacturerProp.Name, $ManufacturerProp.Value)
                    }
                    $object = [pscustomobject]$ManufacturerHash
                    $ManufacturerArray += $object 
                }
                $ManufacturerArray
                $ManufacturerArray = @()
            }
            ManufacturerId { 
                foreach ( $MId in $ManufacturerId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Manufacturer/$($MId)"
                    }

                    Try {
                        $ManufacturerModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ManufacturerHash = [ordered]@{ }
                            $ManufacturerProperties = $ManufacturerModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ManufacturerProp in $ManufacturerProperties) {
                                $ManufacturerHash.Add($ManufacturerProp.Name, $ManufacturerProp.Value)
                            }
                            $object = [pscustomobject]$ManufacturerHash
                            $ManufacturerArray += $object 
                        } else {
                            $ManufacturerHash = [ordered]@{ }
                            $ManufacturerProperties = $ManufacturerModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ManufacturerProp in $ManufacturerProperties) {

                                switch ($ManufacturerProp.Name) {
                                    Default { $ManufacturerPropNewValue = $ManufacturerProp.Value }
                                }

                                $ManufacturerHash.Add($ManufacturerProp.Name, $ManufacturerPropNewValue)
                            }
                            $object = [pscustomobject]$ManufacturerHash
                            $ManufacturerArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "Manufacturer ID = $MId is not found"
                        
                    }
                    $ManufacturerArray
                    $ManufacturerArray = @()
                }
            }
            ManufacturerName { 
                Search-GlpiToolsItems -SearchFor Manufacturer -SearchType contains -SearchValue $ManufacturerName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}