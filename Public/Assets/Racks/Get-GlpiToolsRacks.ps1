<#
.SYNOPSIS
    Function is getting Rack informations from GLPI
.DESCRIPTION
    Function is based on RackID which you can find in GLPI website
    Returns object with property's of Rack
.PARAMETER All
    This parameter will return all Racks from GLPI
.PARAMETER RackId
    This parameter can take pipline input, either, you can use this function with -RackId keyword.
    Provide to this param Rack ID from GLPI Racks Bookmark
.PARAMETER Raw
    Parameter which you can use with RackId Parameter.
    RackId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER RackName
    Provide to this param Rack Name from GLPI Racks Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with RackName Parameter.
    If you want Search for Rack name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with RackId Parameter. 
    If you want to get additional parameter of Rack object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsRacks
    Function gets RackID from GLPI from Pipline, and return Rack object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsRacks
    Function gets RackID from GLPI from Pipline (u can pass many ID's like that), and return Rack object
.EXAMPLE
    PS C:\> Get-GlpiToolsRacks -RackId 326
    Function gets RackID from GLPI which is provided through -RackId after Function type, and return Rack object
.EXAMPLE 
    PS C:\> Get-GlpiToolsRacks -RackId 326, 321
    Function gets RackID from GLPI which is provided through -RackId keyword after Function type (u can provide many ID's like that), and return Rack object
.EXAMPLE
    PS C:\> Get-GlpiToolsRacks -RackId 234 -Raw
    Example will show Rack with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsRacks -Raw
    Example will show Rack with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsRacks -RackName glpi
    Example will return glpi Rack, but what is the most important, Rack will be shown exacly as you see in glpi Racks tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsRacks -RackName glpi -SearchInTrash Yes
    Example will return glpi Rack, but from trash
.INPUTS
    Rack ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Racks from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsRacks {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "RackId")]
        [alias('RID')]
        [string[]]$RackId,
        [parameter(Mandatory = $false,
            ParameterSetName = "RackId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "RackName")]
        [alias('RN')]
        [string]$RackName,
        [parameter(Mandatory = $false,
            ParameterSetName = "RackName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "RackId")]
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

        $RackObjectArray = [System.Collections.Generic.List[PSObject]]::New()

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
                    uri     = "$($PathToGlpi)/Rack/?range=0-9999999999999"
                }
                
                $GlpiRackAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiRack in $GlpiRackAll) {
                    $RackHash = [ordered]@{ }
                            $RackProperties = $GlpiRack.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RackProp in $RackProperties) {
                                $RackHash.Add($RackProp.Name, $RackProp.Value)
                            }
                            $object = [pscustomobject]$RackHash
                            $RackObjectArray.Add($object)
                }
                $RackObjectArray
                $RackObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            RackId { 
                foreach ( $RId in $RackId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Rack/$($RId)$ParamValue"
                    }

                    Try {
                        $GlpiRack = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $RackHash = [ordered]@{ }
                            $RackProperties = $GlpiRack.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RackProp in $RackProperties) {
                                $RackHash.Add($RackProp.Name, $RackProp.Value)
                            }
                            $object = [pscustomobject]$RackHash
                            $RackObjectArray.Add($object)
                        } else {
                            $RackHash = [ordered]@{ }
                            $RackProperties = $GlpiRack.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RackProp in $RackProperties) {

                                $RackPropNewValue = Get-GlpiToolsParameters -Parameter $RackProp.Name -Value $RackProp.Value

                                $RackHash.Add($RackProp.Name, $RackPropNewValue)
                            }
                            $object = [pscustomobject]$RackHash
                            $RackObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Rack ID = $RId is not found"
                        
                    }
                    $RackObjectArray
                    $RackObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            RackName { 
                Search-GlpiToolsItems -SearchFor Rack -SearchType contains -SearchValue $RackName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}