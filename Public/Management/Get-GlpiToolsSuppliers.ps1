<#
.SYNOPSIS
    Function is getting Supplier informations from GLPI
.DESCRIPTION
    Function is based on SupplierId which you can find in GLPI website
    Returns object with property's of Supplier
.PARAMETER All
    This parameter will return all Supplier from GLPI
.PARAMETER SupplierId
    This parameter can take pipline input, either, you can use this function with -SupplierId keyword.
    Provide to this param SupplierId from GLPI Supplier Bookmark
.PARAMETER Raw
    Parameter which you can use with SupplierId Parameter.
    SupplierId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER SupplierName
    This parameter can take pipline input, either, you can use this function with -SupplierId keyword.
    Provide to this param Supplier Name from GLPI Supplier Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsSuppliers -All
    Example will return all Supplier from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsSuppliers
    Function gets SupplierId from GLPI from Pipline, and return Supplier object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsSuppliers
    Function gets SupplierId from GLPI from Pipline (u can pass many ID's like that), and return Supplier object
.EXAMPLE
    PS C:\> Get-GlpiToolsSuppliers -SupplierId 326
    Function gets SupplierId from GLPI which is provided through -SupplierId after Function type, and return Supplier object
.EXAMPLE 
    PS C:\> Get-GlpiToolsSuppliers -SupplierId 326, 321
    Function gets Supplier Id from GLPI which is provided through -SupplierId keyword after Function type (u can provide many ID's like that), and return Supplier object
.EXAMPLE
    PS C:\> Get-GlpiToolsSuppliers -SupplierName Fusion
    Example will return glpi Supplier, but what is the most important, Supplier will be shown exactly as you see in glpi dropdown Supplier.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Supplier ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Supplier from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsSuppliers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SupplierId")]
        [alias('SID')]
        [string[]]$SupplierId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SupplierId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "SupplierName")]
        [alias('SN')]
        [string]$SupplierName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SuppliersArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Supplier/?range=0-9999999999999"
                }
                
                $SuppliersAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Supplier in $SuppliersAll) {
                    $SupplierHash = [ordered]@{ }
                    $SupplierProperties = $Supplier.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SupplierProp in $SupplierProperties) {
                        $SupplierHash.Add($SupplierProp.Name, $SupplierProp.Value)
                    }
                    $object = [pscustomobject]$SupplierHash
                    $SuppliersArray.Add($object)
                }
                $SuppliersArray
                $SuppliersArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            SupplierId { 
                foreach ( $SId in $SupplierId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Supplier/$($SId)"
                    }

                    Try {
                        $Supplier = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SupplierHash = [ordered]@{ }
                            $SupplierProperties = $Supplier.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SupplierProp in $SupplierProperties) {
                                $SupplierHash.Add($SupplierProp.Name, $SupplierProp.Value)
                            }
                            $object = [pscustomobject]$SupplierHash
                            $SuppliersArray.Add($object)
                        } else {
                            $SupplierHash = [ordered]@{ }
                            $SupplierProperties = $Supplier.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SupplierProp in $SupplierProperties) {

                                $SupplierPropNewValue = Get-GlpiToolsParameters -Parameter $SupplierProp.Name -Value $SupplierProp.Value

                                $SupplierHash.Add($SupplierProp.Name, $SupplierPropNewValue)
                            }
                            $object = [pscustomobject]$SupplierHash
                            $SuppliersArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Supplier ID = $SId is not found"
                        
                    }
                    $SuppliersArray
                    $SuppliersArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            SupplierName { 
                Search-GlpiToolsItems -SearchFor Supplier -SearchType contains -SearchValue $SupplierName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}