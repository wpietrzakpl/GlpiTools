<#
.SYNOPSIS
    Function is getting RecurrentTicket informations from GLPI
.DESCRIPTION
    Function is based on RecurrentTicketID which you can find in GLPI website
    Returns object with property's of RecurrentTicket
.PARAMETER All
    This parameter will return all RecurrentTickets from GLPI
.PARAMETER RecurrentTicketId
    This parameter can take pipline input, either, you can use this function with -RecurrentTicketId keyword.
    Provide to this param RecurrentTicket ID from GLPI RecurrentTickets Bookmark
.PARAMETER Raw
    Parameter which you can use with RecurrentTicketId Parameter.
    RecurrentTicketId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER RecurrentTicketName
    Provide to this param RecurrentTicket Name from GLPI RecurrentTickets Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with RecurrentTicketName Parameter.
    If you want Search for RecurrentTicket name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with RecurrentTicketId Parameter. 
    If you want to get additional parameter of RecurrentTicket object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsRecurrentTickets
    Function gets RecurrentTicketID from GLPI from Pipline, and return RecurrentTicket object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsRecurrentTickets
    Function gets RecurrentTicketID from GLPI from Pipline (u can pass many ID's like that), and return RecurrentTicket object
.EXAMPLE
    PS C:\> Get-GlpiToolsRecurrentTickets -RecurrentTicketId 326
    Function gets RecurrentTicketID from GLPI which is provided through -RecurrentTicketId after Function type, and return RecurrentTicket object
.EXAMPLE 
    PS C:\> Get-GlpiToolsRecurrentTickets -RecurrentTicketId 326, 321
    Function gets RecurrentTicketID from GLPI which is provided through -RecurrentTicketId keyword after Function type (u can provide many ID's like that), and return RecurrentTicket object
.EXAMPLE
    PS C:\> Get-GlpiToolsRecurrentTickets -RecurrentTicketId 234 -Raw
    Example will show RecurrentTicket with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsRecurrentTickets -Raw
    Example will show RecurrentTicket with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsRecurrentTickets -RecurrentTicketName glpi
    Example will return glpi RecurrentTicket, but what is the most important, RecurrentTicket will be shown exacly as you see in glpi RecurrentTickets tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsRecurrentTickets -RecurrentTicketName glpi -SearchInTrash Yes
    Example will return glpi RecurrentTicket, but from trash
.INPUTS
    RecurrentTicket ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of RecurrentTickets from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsRecurrentTickets {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "RecurrentTicketId")]
        [alias('RTID')]
        [string[]]$RecurrentTicketId,
        [parameter(Mandatory = $false,
            ParameterSetName = "RecurrentTicketId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "RecurrentTicketName")]
        [alias('RTN')]
        [string]$RecurrentTicketName,
        [parameter(Mandatory = $false,
            ParameterSetName = "RecurrentTicketName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "RecurrentTicketId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithDevices",
            "WithInfocoms",
            "WithContracts",
            "WithDocuments",
            "WithRecurrentTickets",
            "WithRecurrentTickets",
            "WithRecurrentTickets",
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

        $RecurrentTicketObjectArray = [System.Collections.Generic.List[PSObject]]::New()

        switch ($Parameter) {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
            WithDevices { $ParamValue = "?with_devices=true" }
            WithInfocoms { $ParamValue = "?with_infocoms=true" }
            WithContracts { $ParamValue = "?with_contracts=true" }
            WithDocuments { $ParamValue = "?with_documents=true" }
            WithRecurrentTickets { $ParamValue = "?with_RecurrentTickets=true" } 
            WithRecurrentTickets { $ParamValue = "?with_RecurrentTickets=true" }
            WithRecurrentTickets { $ParamValue = "?with_RecurrentTickets=true" }
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
                    uri     = "$($PathToGlpi)/ticketrecurrent/?range=0-9999999999999"
                }
                
                $GlpiRecurrentTicketAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiRecurrentTicket in $GlpiRecurrentTicketAll) {
                    $RecurrentTicketHash = [ordered]@{ }
                            $RecurrentTicketProperties = $GlpiRecurrentTicket.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RecurrentTicketProp in $RecurrentTicketProperties) {
                                $RecurrentTicketHash.Add($RecurrentTicketProp.Name, $RecurrentTicketProp.Value)
                            }
                            $object = [pscustomobject]$RecurrentTicketHash
                            $RecurrentTicketObjectArray.Add($object)
                }
                $RecurrentTicketObjectArray
                $RecurrentTicketObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            RecurrentTicketId { 
                foreach ( $RTId in $RecurrentTicketId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/ticketrecurrent/$($RTId)$ParamValue"
                    }

                    Try {
                        $GlpiRecurrentTicket = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $RecurrentTicketHash = [ordered]@{ }
                            $RecurrentTicketProperties = $GlpiRecurrentTicket.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RecurrentTicketProp in $RecurrentTicketProperties) {
                                $RecurrentTicketHash.Add($RecurrentTicketProp.Name, $RecurrentTicketProp.Value)
                            }
                            $object = [pscustomobject]$RecurrentTicketHash
                            $RecurrentTicketObjectArray.Add($object)
                        } else {
                            $RecurrentTicketHash = [ordered]@{ }
                            $RecurrentTicketProperties = $GlpiRecurrentTicket.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($RecurrentTicketProp in $RecurrentTicketProperties) {

                                $RecurrentTicketPropNewValue = Get-GlpiToolsParameters -Parameter $RecurrentTicketProp.Name -Value $RecurrentTicketProp.Value

                                $RecurrentTicketHash.Add($RecurrentTicketProp.Name, $RecurrentTicketPropNewValue)
                            }
                            $object = [pscustomobject]$RecurrentTicketHash
                            $RecurrentTicketObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "RecurrentTicket ID = $RTId is not found"
                        
                    }
                    $RecurrentTicketObjectArray
                    $RecurrentTicketObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            RecurrentTicketName { 
                Search-GlpiToolsItems -SearchFor ticketrecurrent -SearchType contains -SearchValue $RecurrentTicketName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}