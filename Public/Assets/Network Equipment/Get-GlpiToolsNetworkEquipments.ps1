<#
.SYNOPSIS
    Function is getting NetworkEquipment informations from GLPI
.DESCRIPTION
    Function is based on NetworkEquipmentID which you can find in GLPI website
    Returns object with property's of NetworkEquipment
.PARAMETER All
    This parameter will return all NetworkEquipments from GLPI
.PARAMETER NetworkEquipmentId
    This parameter can take pipline input, either, you can use this function with -NetworkEquipmentId keyword.
    Provide to this param NetworkEquipment ID from GLPI NetworkEquipments Bookmark
.PARAMETER Raw
    Parameter which you can use with NetworkEquipmentId Parameter.
    NetworkEquipmentId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER NetworkEquipmentName
    Provide to this param NetworkEquipment Name from GLPI NetworkEquipments Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with NetworkEquipmentName Parameter.
    If you want Search for NetworkEquipment name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with NetworkEquipmentId Parameter. 
    If you want to get additional parameter of NetworkEquipment object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsNetworkEquipments
    Function gets NetworkEquipmentID from GLPI from Pipline, and return NetworkEquipment object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsNetworkEquipments
    Function gets NetworkEquipmentID from GLPI from Pipline (u can pass many ID's like that), and return NetworkEquipment object
.EXAMPLE
    PS C:\> Get-GlpiToolsNetworkEquipments -NetworkEquipmentId 326
    Function gets NetworkEquipmentID from GLPI which is provided through -NetworkEquipmentId after Function type, and return NetworkEquipment object
.EXAMPLE 
    PS C:\> Get-GlpiToolsNetworkEquipments -NetworkEquipmentId 326, 321
    Function gets NetworkEquipmentID from GLPI which is provided through -NetworkEquipmentId keyword after Function type (u can provide many ID's like that), and return NetworkEquipment object
.EXAMPLE
    PS C:\> Get-GlpiToolsNetworkEquipments -NetworkEquipmentId 234 -Raw
    Example will show NetworkEquipment with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsNetworkEquipments -Raw
    Example will show NetworkEquipment with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsNetworkEquipments -NetworkEquipmentName glpi
    Example will return glpi NetworkEquipment, but what is the most important, NetworkEquipment will be shown exacly as you see in glpi NetworkEquipments tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsNetworkEquipments -NetworkEquipmentName glpi -SearchInTrash Yes
    Example will return glpi NetworkEquipment, but from trash
.INPUTS
    NetworkEquipment ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of NetworkEquipments from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsNetworkEquipments {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "NetworkEquipmentId")]
        [alias('MID')]
        [string[]]$NetworkEquipmentId,
        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkEquipmentId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "NetworkEquipmentName")]
        [alias('NEN')]
        [string]$NetworkEquipmentName,
        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkEquipmentName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "NetworkEquipmentId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithDevices",
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

        $NetworkEquipmentObjectArray = [System.Collections.Generic.List[PSObject]]::New()

        switch ($Parameter) {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
            WithDevices { $ParamValue = "?with_devices=true" }
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
                    uri     = "$($PathToGlpi)/NetworkEquipment/?range=0-9999999999999"
                }
                
                $GlpiNetworkEquipmentAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiNetworkEquipment in $GlpiNetworkEquipmentAll) {
                    $NetworkEquipmentHash = [ordered]@{ }
                            $NetworkEquipmentProperties = $GlpiNetworkEquipment.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkEquipmentProp in $NetworkEquipmentProperties) {
                                $NetworkEquipmentHash.Add($NetworkEquipmentProp.Name, $NetworkEquipmentProp.Value)
                            }
                            $object = [pscustomobject]$NetworkEquipmentHash
                            $NetworkEquipmentObjectArray.Add($object)
                }
                $NetworkEquipmentObjectArray
                $NetworkEquipmentObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            NetworkEquipmentId { 
                foreach ( $NEId in $NetworkEquipmentId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/NetworkEquipment/$($NEId)$ParamValue"
                    }

                    Try {
                        $GlpiNetworkEquipment = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $NetworkEquipmentHash = [ordered]@{ }
                            $NetworkEquipmentProperties = $GlpiNetworkEquipment.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkEquipmentProp in $NetworkEquipmentProperties) {
                                $NetworkEquipmentHash.Add($NetworkEquipmentProp.Name, $NetworkEquipmentProp.Value)
                            }
                            $object = [pscustomobject]$NetworkEquipmentHash
                            $NetworkEquipmentObjectArray.Add($object)
                        } else {
                            $NetworkEquipmentHash = [ordered]@{ }
                            $NetworkEquipmentProperties = $GlpiNetworkEquipment.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($NetworkEquipmentProp in $NetworkEquipmentProperties) {

                                $NetworkEquipmentPropNewValue = Get-GlpiToolsParameters -Parameter $NetworkEquipmentProp.Name -Value $NetworkEquipmentProp.Value

                                $NetworkEquipmentHash.Add($NetworkEquipmentProp.Name, $NetworkEquipmentPropNewValue)
                            }
                            $object = [pscustomobject]$NetworkEquipmentHash
                            $NetworkEquipmentObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "NetworkEquipment ID = $NEId is not found"
                        
                    }
                    $NetworkEquipmentObjectArray
                    $NetworkEquipmentObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            NetworkEquipmentName { 
                Search-GlpiToolsItems -SearchFor NetworkEquipment -SearchType contains -SearchValue $NetworkEquipmentName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}