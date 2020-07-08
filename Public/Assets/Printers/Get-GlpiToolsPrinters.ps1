<#
.SYNOPSIS
    Function is getting Printer informations from GLPI
.DESCRIPTION
    Function is based on PrinterID which you can find in GLPI website
    Returns object with property's of Printer
.PARAMETER All
    This parameter will return all Printers from GLPI
.PARAMETER PrinterId
    This parameter can take pipline input, either, you can use this function with -PrinterId keyword.
    Provide to this param Printer ID from GLPI Printers Bookmark
.PARAMETER Raw
    Parameter which you can use with PrinterId Parameter.
    PrinterId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PrinterName
    Provide to this param Printer Name from GLPI Printers Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with PrinterName Parameter.
    If you want Search for Printer name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with PrinterId Parameter. 
    If you want to get additional parameter of Printer object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsPrinters
    Function gets PrinterID from GLPI from Pipline, and return Printer object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsPrinters
    Function gets PrinterID from GLPI from Pipline (u can pass many ID's like that), and return Printer object
.EXAMPLE
    PS C:\> Get-GlpiToolsPrinters -PrinterId 326
    Function gets PrinterID from GLPI which is provided through -PrinterId after Function type, and return Printer object
.EXAMPLE 
    PS C:\> Get-GlpiToolsPrinters -PrinterId 326, 321
    Function gets PrinterID from GLPI which is provided through -PrinterId keyword after Function type (u can provide many ID's like that), and return Printer object
.EXAMPLE
    PS C:\> Get-GlpiToolsPrinters -PrinterId 234 -Raw
    Example will show Printer with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsPrinters -Raw
    Example will show Printer with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsPrinters -PrinterName glpi
    Example will return glpi Printer, but what is the most important, Printer will be shown exacly as you see in glpi Printers tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsPrinters -PrinterName glpi -SearchInTrash Yes
    Example will return glpi Printer, but from trash
.INPUTS
    Printer ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Printers from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsPrinters {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PrinterId")]
        [alias('PID')]
        [string[]]$PrinterId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PrinterId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "PrinterName")]
        [alias('PN')]
        [string]$PrinterName,
        [parameter(Mandatory = $false,
            ParameterSetName = "PrinterName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "PrinterId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithDevices",
            "WithDisks",
            "WithSoftwares",
            "WithConnections",
            "WithNetworkports",
            "WithInfocoms",
            "WithContracts",
            "WithDocuments",
            "WithTickets",
            "WithProblems",
            "WithChanges",
            "WithNotes",
            "WithLogs")]
        [string]$Parameter
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PrinterObjectArray = [System.Collections.Generic.List[PSObject]]::New()

        switch ($Parameter) {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
            WithDevices { $ParamValue = "?with_devices=true" }
            WithDisks { $ParamValue = "?with_disks=true" }
            WithSoftwares { $ParamValue = "?with_softwares=true" }
            WithConnections { $ParamValue = "?with_connections=true" }
            WithNetworkports { $ParamValue = "?with_networkports=true" }
            WithInfocoms { $ParamValue = "?with_infocoms=true" }
            WithContracts { $ParamValue = "?with_contracts=true" }
            WithDocuments { $ParamValue = "?with_documents=true" }
            WithTickets { $ParamValue = "?with_tickets=true" } 
            WithProblems { $ParamValue = "?with_problems=true" }
            WithChanges { $ParamValue = "?with_changes=true" }
            WithNotes { $ParamValue = "?with_notes=true" } 
            WithLogs { $ParamValue = "?with_logs=true" }
            Default { $ParamValue = "" }
        }

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
                    uri     = "$($PathToGlpi)/Printer/?range=0-9999999999999"
                }
                
                $GlpiPrinterAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiPrinter in $GlpiPrinterAll) {
                    $PrinterHash = [ordered]@{ }
                            $PrinterProperties = $GlpiPrinter.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PrinterProp in $PrinterProperties) {
                                $PrinterHash.Add($PrinterProp.Name, $PrinterProp.Value)
                            }
                            $object = [pscustomobject]$PrinterHash
                            $PrinterObjectArray.Add($object)
                }
                $PrinterObjectArray
                $PrinterObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PrinterId { 
                foreach ( $PId in $PrinterId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Printer/$($PId)$ParamValue"
                    }

                    Try {
                        $GlpiPrinter = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PrinterHash = [ordered]@{ }
                            $PrinterProperties = $GlpiPrinter.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PrinterProp in $PrinterProperties) {
                                $PrinterHash.Add($PrinterProp.Name, $PrinterProp.Value)
                            }
                            $object = [pscustomobject]$PrinterHash
                            $PrinterObjectArray.Add($object)
                        } else {
                            $PrinterHash = [ordered]@{ }
                            $PrinterProperties = $GlpiPrinter.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PrinterProp in $PrinterProperties) {

                                $PrinterPropNewValue = Get-GlpiToolsParameters -Parameter $PrinterProp.Name -Value $PrinterProp.Value
                                $PrinterHash.Add($PrinterProp.Name, $PrinterPropNewValue)
                            }
                            $object = [pscustomobject]$PrinterHash
                            $PrinterObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Printer ID = $PId is not found"
                        
                    }
                    $PrinterObjectArray
                    $PrinterObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PrinterName { 
                Search-GlpiToolsItems -SearchFor Printer -SearchType contains -SearchValue $PrinterName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}