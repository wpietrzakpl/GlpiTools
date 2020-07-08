<#
.SYNOPSIS
    Function is getting Enclosure informations from GLPI
.DESCRIPTION
    Function is based on EnclosureID which you can find in GLPI website
    Returns object with property's of Enclosure
.PARAMETER All
    This parameter will return all Enclosures from GLPI
.PARAMETER EnclosureId
    This parameter can take pipline input, either, you can use this function with -EnclosureId keyword.
    Provide to this param Enclosure ID from GLPI Enclosures Bookmark
.PARAMETER Raw
    Parameter which you can use with EnclosureId Parameter.
    EnclosureId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER EnclosureName
    Provide to this param Enclosure Name from GLPI Enclosures Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with EnclosureName Parameter.
    If you want Search for Enclosure name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with EnclosureId Parameter. 
    If you want to get additional parameter of Enclosure object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsEnclosures
    Function gets EnclosureID from GLPI from Pipline, and return Enclosure object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsEnclosures
    Function gets EnclosureID from GLPI from Pipline (u can pass many ID's like that), and return Enclosure object
.EXAMPLE
    PS C:\> Get-GlpiToolsEnclosures -EnclosureId 326
    Function gets EnclosureID from GLPI which is provided through -EnclosureId after Function type, and return Enclosure object
.EXAMPLE 
    PS C:\> Get-GlpiToolsEnclosures -EnclosureId 326, 321
    Function gets EnclosureID from GLPI which is provided through -EnclosureId keyword after Function type (u can provide many ID's like that), and return Enclosure object
.EXAMPLE
    PS C:\> Get-GlpiToolsEnclosures -EnclosureId 234 -Raw
    Example will show Enclosure with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsEnclosures -Raw
    Example will show Enclosure with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsEnclosures -EnclosureName glpi
    Example will return glpi Enclosure, but what is the most important, Enclosure will be shown exacly as you see in glpi Enclosures tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsEnclosures -EnclosureName glpi -SearchInTrash Yes
    Example will return glpi Enclosure, but from trash
.INPUTS
    Enclosure ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Enclosures from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsEnclosures {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "EnclosureId")]
        [alias('EID')]
        [string[]]$EnclosureId,
        [parameter(Mandatory = $false,
            ParameterSetName = "EnclosureId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "EnclosureName")]
        [alias('EN')]
        [string]$EnclosureName,
        [parameter(Mandatory = $false,
            ParameterSetName = "EnclosureName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "EnclosureId")]
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

        $EnclosureObjectArray = [System.Collections.Generic.List[PSObject]]::New()

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
                    uri     = "$($PathToGlpi)/Enclosure/?range=0-9999999999999"
                }
                
                $GlpiEnclosureAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiEnclosure in $GlpiEnclosureAll) {
                    $EnclosureHash = [ordered]@{ }
                            $EnclosureProperties = $GlpiEnclosure.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EnclosureProp in $EnclosureProperties) {
                                $EnclosureHash.Add($EnclosureProp.Name, $EnclosureProp.Value)
                            }
                            $object = [pscustomobject]$EnclosureHash
                            $EnclosureObjectArray.Add($object)
                }
                $EnclosureObjectArray
                $EnclosureObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            EnclosureId { 
                foreach ( $EId in $EnclosureId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Enclosure/$($EId)$ParamValue"
                    }

                    Try {
                        $GlpiEnclosure = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $EnclosureHash = [ordered]@{ }
                            $EnclosureProperties = $GlpiEnclosure.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EnclosureProp in $EnclosureProperties) {
                                $EnclosureHash.Add($EnclosureProp.Name, $EnclosureProp.Value)
                            }
                            $object = [pscustomobject]$EnclosureHash
                            $EnclosureObjectArray.Add($object)
                        } else {
                            $EnclosureHash = [ordered]@{ }
                            $EnclosureProperties = $GlpiEnclosure.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EnclosureProp in $EnclosureProperties) {

                                $EnclosurePropNewValue = Get-GlpiToolsParameters -Parameter $EnclosureProp.Name -Value $EnclosureProp.Value

                                $EnclosureHash.Add($EnclosureProp.Name, $EnclosurePropNewValue)
                            }
                            $object = [pscustomobject]$EnclosureHash
                            $EnclosureObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Enclosure ID = $EId is not found"
                        
                    }
                    $EnclosureObjectArray
                    $EnclosureObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            EnclosureName { 
                Search-GlpiToolsItems -SearchFor Enclosure -SearchType contains -SearchValue $EnclosureName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}