<#
.SYNOPSIS
    Function is getting Ticket informations from GLPI
.DESCRIPTION
    Function is based on TicketID which you can find in GLPI website
    Returns object with property's of Ticket
.PARAMETER All
    This parameter will return all Tickets from GLPI
.PARAMETER TicketId
    This parameter can take pipline input, either, you can use this function with -TicketId keyword.
    Provide to this param Ticket ID from GLPI Tickets Bookmark
.PARAMETER Raw
    Parameter which you can use with TicketId Parameter.
    TicketId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER TicketName
    Provide to this param Ticket Name from GLPI Tickets Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with TicketName Parameter.
    If you want Search for Ticket name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with TicketId Parameter. 
    If you want to get additional parameter of Ticket object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsTickets
    Function gets TicketID from GLPI from Pipline, and return Ticket object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsTickets
    Function gets TicketID from GLPI from Pipline (u can pass many ID's like that), and return Ticket object
.EXAMPLE
    PS C:\> Get-GlpiToolsTickets -TicketId 326
    Function gets TicketID from GLPI which is provided through -TicketId after Function type, and return Ticket object
.EXAMPLE 
    PS C:\> Get-GlpiToolsTickets -TicketId 326, 321
    Function gets TicketID from GLPI which is provided through -TicketId keyword after Function type (u can provide many ID's like that), and return Ticket object
.EXAMPLE
    PS C:\> Get-GlpiToolsTickets -TicketId 234 -Raw
    Example will show Ticket with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsTickets -Raw
    Example will show Ticket with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsTickets -TicketName glpi
    Example will return glpi Ticket, but what is the most important, Ticket will be shown exacly as you see in glpi Tickets tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsTickets -TicketName glpi -SearchInTrash Yes
    Example will return glpi Ticket, but from trash
.INPUTS
    Ticket ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Tickets from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsTickets {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "TicketId")]
        [alias('TID')]
        [string[]]$TicketId,
        [parameter(Mandatory = $false,
            ParameterSetName = "TicketId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "TicketName")]
        [alias('TN')]
        [string]$TicketName,
        [parameter(Mandatory = $false,
            ParameterSetName = "TicketName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "TicketId")]
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

        $TicketObjectArray = [System.Collections.ArrayList]::new()

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
                    uri     = "$($PathToGlpi)/Ticket/?range=0-9999999999999"
                }
                
                $GlpiTicketAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiTicket in $GlpiTicketAll) {
                    $TicketHash = [ordered]@{ }
                            $TicketProperties = $GlpiTicket.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TicketProp in $TicketProperties) {
                                $TicketHash.Add($TicketProp.Name, $TicketProp.Value)
                            }
                            $object = [pscustomobject]$TicketHash
                            $TicketObjectArray.Add($object)
                }
                $TicketObjectArray
                $TicketObjectArray = [System.Collections.ArrayList]::new()
            }
            TicketId { 
                foreach ( $TId in $TicketId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Ticket/$($TId)$ParamValue"
                    }

                    Try {
                        $GlpiTicket = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $TicketHash = [ordered]@{ }
                            $TicketProperties = $GlpiTicket.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TicketProp in $TicketProperties) {
                                $TicketHash.Add($TicketProp.Name, $TicketProp.Value)
                            }
                            $object = [pscustomobject]$TicketHash
                            $TicketObjectArray.Add($object)
                        } else {
                            $TicketHash = [ordered]@{ }
                            $TicketProperties = $GlpiTicket.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TicketProp in $TicketProperties) {

                                switch ($TicketProp.Name) {
                                    entities_id { $TicketPropNewValue = $TicketProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id_recipient { $TicketPropNewValue = $TicketProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } }
                                    users_id_lastupdater { $TicketPropNewValue = $TicketProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } }
                                    Default {
                                        $TicketPropNewValue = $TicketProp.Value
                                    }
                                }
                                
                                $TicketHash.Add($TicketProp.Name, $TicketPropNewValue)
                            }
                            $object = [pscustomobject]$TicketHash
                            $TicketObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Ticket ID = $TId is not found"
                        
                    }
                    $TicketObjectArray
                    $TicketObjectArray = [System.Collections.ArrayList]::new()
                }
            }
            TicketName { 
                Search-GlpiToolsItems -SearchFor Ticket -SearchType contains -SearchValue $TicketName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}