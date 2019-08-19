<#
.SYNOPSIS
    Function is getting Monitor informations from GLPI
.DESCRIPTION
    Function is based on MonitorID which you can find in GLPI website
    Returns object with property's of Monitor
.PARAMETER All
    This parameter will return all Monitors from GLPI
.PARAMETER MonitorId
    This parameter can take pipline input, either, you can use this function with -MonitorId keyword.
    Provide to this param Monitor ID from GLPI Monitors Bookmark
.PARAMETER Raw
    Parameter which you can use with MonitorId Parameter.
    MonitorId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER MonitorName
    Provide to this param Monitor Name from GLPI Monitors Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with MonitorName Parameter.
    If you want Search for Monitor name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with MonitorId Parameter. 
    If you want to get additional parameter of Monitor object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsMonitors
    Function gets MonitorID from GLPI from Pipline, and return Monitor object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsMonitors
    Function gets MonitorID from GLPI from Pipline (u can pass many ID's like that), and return Monitor object
.EXAMPLE
    PS C:\> Get-GlpiToolsMonitors -MonitorId 326
    Function gets MonitorID from GLPI which is provided through -MonitorId after Function type, and return Monitor object
.EXAMPLE 
    PS C:\> Get-GlpiToolsMonitors -MonitorId 326, 321
    Function gets MonitorID from GLPI which is provided through -MonitorId keyword after Function type (u can provide many ID's like that), and return Monitor object
.EXAMPLE
    PS C:\> Get-GlpiToolsMonitors -MonitorId 234 -Raw
    Example will show Monitor with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsMonitors -Raw
    Example will show Monitor with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsMonitors -MonitorName glpi
    Example will return glpi Monitor, but what is the most important, Monitor will be shown exacly as you see in glpi Monitors tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsMonitors -MonitorName glpi -SearchInTrash Yes
    Example will return glpi Monitor, but from trash
.INPUTS
    Monitor ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Monitors from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsMonitors {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "MonitorId")]
        [alias('MID')]
        [string[]]$MonitorId,
        [parameter(Mandatory = $false,
            ParameterSetName = "MonitorId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "MonitorName")]
        [alias('MN')]
        [string]$MonitorName,
        [parameter(Mandatory = $false,
            ParameterSetName = "MonitorName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "MonitorId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithDevices",
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

        $MonitorObjectArray = [System.Collections.ArrayList]::new()

        switch ($Parameter) {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
            WithDevices { $ParamValue = "?with_devices=true" }
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
                    uri     = "$($PathToGlpi)/Monitor/?range=0-9999999999999"
                }
                
                $GlpiMonitorAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiMonitor in $GlpiMonitorAll) {
                    $MonitorHash = [ordered]@{ }
                            $MonitorProperties = $GlpiMonitor.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MonitorProp in $MonitorProperties) {
                                $MonitorHash.Add($MonitorProp.Name, $MonitorProp.Value)
                            }
                            $object = [pscustomobject]$MonitorHash
                            $MonitorObjectArray.Add($object)
                }
                $MonitorObjectArray
                $MonitorObjectArray = [System.Collections.ArrayList]::new()
            }
            MonitorId { 
                foreach ( $MId in $MonitorId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Monitor/$($MId)$ParamValue"
                    }

                    Try {
                        $GlpiMonitor = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $MonitorHash = [ordered]@{ }
                            $MonitorProperties = $GlpiMonitor.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MonitorProp in $MonitorProperties) {
                                $MonitorHash.Add($MonitorProp.Name, $MonitorProp.Value)
                            }
                            $object = [pscustomobject]$MonitorHash
                            $MonitorObjectArray.Add($object)
                        } else {
                            $MonitorHash = [ordered]@{ }
                            $MonitorProperties = $GlpiMonitor.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($MonitorProp in $MonitorProperties) {

                                switch ($MonitorProp.Name) {
                                    entities_id { $MonitorPropNewValue = $MonitorProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id { $MonitorPropNewValue = $MonitorProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } }
                                    Default {
                                        $MonitorPropNewValue = $MonitorProp.Value
                                    }
                                }
                                
                                $MonitorHash.Add($MonitorProp.Name, $MonitorPropNewValue)
                            }
                            $object = [pscustomobject]$MonitorHash
                            $MonitorObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Monitor ID = $MId is not found"
                        
                    }
                    $MonitorObjectArray
                    $MonitorObjectArray = [System.Collections.ArrayList]::new()
                }
            }
            MonitorName { 
                Search-GlpiToolsItems -SearchFor Monitor -SearchType contains -SearchValue $MonitorName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}