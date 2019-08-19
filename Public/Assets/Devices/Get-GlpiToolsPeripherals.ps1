<#
.SYNOPSIS
    Function is getting Peripheral informations from GLPI
.DESCRIPTION
    Function is based on PeripheralID which you can find in GLPI website
    Returns object with property's of Peripheral
.PARAMETER All
    This parameter will return all Peripherals from GLPI
.PARAMETER PeripheralId
    This parameter can take pipline input, either, you can use this function with -PeripheralId keyword.
    Provide to this param Peripheral ID from GLPI Peripherals Bookmark
.PARAMETER Raw
    Parameter which you can use with PeripheralId Parameter.
    PeripheralId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PeripheralName
    Provide to this param Peripheral Name from GLPI Peripherals Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with PeripheralName Parameter.
    If you want Search for Peripheral name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with PeripheralId Parameter. 
    If you want to get additional parameter of Peripheral object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsPeripherals
    Function gets PeripheralID from GLPI from Pipline, and return Peripheral object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsPeripherals
    Function gets PeripheralID from GLPI from Pipline (u can pass many ID's like that), and return Peripheral object
.EXAMPLE
    PS C:\> Get-GlpiToolsPeripherals -PeripheralId 326
    Function gets PeripheralID from GLPI which is provided through -PeripheralId after Function type, and return Peripheral object
.EXAMPLE 
    PS C:\> Get-GlpiToolsPeripherals -PeripheralId 326, 321
    Function gets PeripheralID from GLPI which is provided through -PeripheralId keyword after Function type (u can provide many ID's like that), and return Peripheral object
.EXAMPLE
    PS C:\> Get-GlpiToolsPeripherals -PeripheralId 234 -Raw
    Example will show Peripheral with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsPeripherals -Raw
    Example will show Peripheral with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsPeripherals -PeripheralName glpi
    Example will return glpi Peripheral, but what is the most important, Peripheral will be shown exacly as you see in glpi Peripherals tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsPeripherals -PeripheralName glpi -SearchInTrash Yes
    Example will return glpi Peripheral, but from trash
.INPUTS
    Peripheral ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Peripherals from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsPeripherals {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PeripheralId")]
        [alias('PID')]
        [string[]]$PeripheralId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PeripheralId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "PeripheralName")]
        [alias('PN')]
        [string]$PeripheralName,
        [parameter(Mandatory = $false,
            ParameterSetName = "PeripheralName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "PeripheralId")]
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

        $PeripheralObjectArray = [System.Collections.ArrayList]::new()

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
                    uri     = "$($PathToGlpi)/Peripheral/?range=0-9999999999999"
                }
                
                $GlpiPeripheralAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiPeripheral in $GlpiPeripheralAll) {
                    $PeripheralHash = [ordered]@{ }
                            $PeripheralProperties = $GlpiPeripheral.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PeripheralProp in $PeripheralProperties) {
                                $PeripheralHash.Add($PeripheralProp.Name, $PeripheralProp.Value)
                            }
                            $object = [pscustomobject]$PeripheralHash
                            $PeripheralObjectArray.Add($object)
                }
                $PeripheralObjectArray
                $PeripheralObjectArray = [System.Collections.ArrayList]::new()
            }
            PeripheralId { 
                foreach ( $PId in $PeripheralId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Peripheral/$($PId)$ParamValue"
                    }

                    Try {
                        $GlpiPeripheral = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PeripheralHash = [ordered]@{ }
                            $PeripheralProperties = $GlpiPeripheral.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PeripheralProp in $PeripheralProperties) {
                                $PeripheralHash.Add($PeripheralProp.Name, $PeripheralProp.Value)
                            }
                            $object = [pscustomobject]$PeripheralHash
                            $PeripheralObjectArray.Add($object)
                        } else {
                            $PeripheralHash = [ordered]@{ }
                            $PeripheralProperties = $GlpiPeripheral.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PeripheralProp in $PeripheralProperties) {

                                switch ($PeripheralProp.Name) {
                                    entities_id { $PeripheralPropNewValue = $PeripheralProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id { $PeripheralPropNewValue = $PeripheralProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } }
                                    Default {
                                        $PeripheralPropNewValue = $PeripheralProp.Value
                                    }
                                }
                                
                                $PeripheralHash.Add($PeripheralProp.Name, $PeripheralPropNewValue)
                            }
                            $object = [pscustomobject]$PeripheralHash
                            $PeripheralObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Peripheral ID = $PId is not found"
                        
                    }
                    $PeripheralObjectArray
                    $PeripheralObjectArray = [System.Collections.ArrayList]::new()
                }
            }
            PeripheralName { 
                Search-GlpiToolsItems -SearchFor Peripheral -SearchType contains -SearchValue $PeripheralName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}