<#
.SYNOPSIS
    Function is getting Printer Types informations from GLPI
.DESCRIPTION
    Function is based on PrinterTypeId which you can find in GLPI website
    Returns object with property's of Printer Types
.PARAMETER All
    This parameter will return all Printer Types from GLPI
.PARAMETER PrinterTypeId
    This parameter can take pipline input, either, you can use this function with -PrinterTypeId keyword.
    Provide to this param PrinterTypeId from GLPI Printer Types Bookmark
.PARAMETER Raw
    Parameter which you can use with PrinterTypeId Parameter.
    PrinterTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PrinterTypeName
    This parameter can take pipline input, either, you can use this function with -PrinterTypeId keyword.
    Provide to this param Printer Types Name from GLPI Printer Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPrinterTypes -All
    Example will return all Printer Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPrinterTypes
    Function gets PrinterTypeId from GLPI from Pipline, and return Printer Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPrinterTypes
    Function gets PrinterTypeId from GLPI from Pipline (u can pass many ID's like that), and return Printer Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPrinterTypes -PrinterTypeId 326
    Function gets PrinterTypeId from GLPI which is provided through -PrinterTypeId after Function type, and return Printer Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPrinterTypes -PrinterTypeId 326, 321
    Function gets Printer Types Id from GLPI which is provided through -PrinterTypeId keyword after Function type (u can provide many ID's like that), and return Printer Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPrinterTypes -PrinterTypeName Fusion
    Example will return glpi Printer Types, but what is the most important, Printer Types will be shown exactly as you see in glpi dropdown Printer Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Printer Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Printer Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPrinterTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PrinterTypeId")]
        [alias('PTID')]
        [string[]]$PrinterTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PrinterTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PrinterTypeName")]
        [alias('PTN')]
        [string]$PrinterTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PrinterTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/printertype/?range=0-9999999999999"
                }
                
                $PrinterTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PrinterType in $PrinterTypesAll) {
                    $PrinterTypeHash = [ordered]@{ }
                    $PrinterTypeProperties = $PrinterType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PrinterTypeProp in $PrinterTypeProperties) {
                        $PrinterTypeHash.Add($PrinterTypeProp.Name, $PrinterTypeProp.Value)
                    }
                    $object = [pscustomobject]$PrinterTypeHash
                    $PrinterTypesArray.Add($object)
                }
                $PrinterTypesArray
                $PrinterTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PrinterTypeId { 
                foreach ( $PTId in $PrinterTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/printertype/$($PTId)"
                    }

                    Try {
                        $PrinterType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PrinterTypeHash = [ordered]@{ }
                            $PrinterTypeProperties = $PrinterType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PrinterTypeProp in $PrinterTypeProperties) {
                                $PrinterTypeHash.Add($PrinterTypeProp.Name, $PrinterTypeProp.Value)
                            }
                            $object = [pscustomobject]$PrinterTypeHash
                            $PrinterTypesArray.Add($object)
                        } else {
                            $PrinterTypeHash = [ordered]@{ }
                            $PrinterTypeProperties = $PrinterType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PrinterTypeProp in $PrinterTypeProperties) {

                                $PrinterTypePropNewValue = Get-GlpiToolsParameters -Parameter $PrinterTypeProp.Name -Value $PrinterTypeProp.Value

                                $PrinterTypeHash.Add($PrinterTypeProp.Name, $PrinterTypePropNewValue)
                            }
                            $object = [pscustomobject]$PrinterTypeHash
                            $PrinterTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Printer Type ID = $PTId is not found"
                        
                    }
                    $PrinterTypesArray
                    $PrinterTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PrinterTypeName { 
                Search-GlpiToolsItems -SearchFor printertype -SearchType contains -SearchValue $PrinterTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}