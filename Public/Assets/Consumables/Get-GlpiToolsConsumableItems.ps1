<#
.SYNOPSIS
    Function is getting ConsumableItem informations from GLPI
.DESCRIPTION
    Function is based on ConsumableItemID which you can find in GLPI website
    Returns object with property's of ConsumableItem
.PARAMETER All
    This parameter will return all ConsumableItems from GLPI
.PARAMETER ConsumableItemId
    This parameter can take pipline input, either, you can use this function with -ConsumableItemId keyword.
    Provide to this param ConsumableItem ID from GLPI ConsumableItems Bookmark
.PARAMETER Raw
    Parameter which you can use with ConsumableItemId Parameter.
    ConsumableItemId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ConsumableItemName
    Provide to this param ConsumableItem Name from GLPI ConsumableItems Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with ConsumableItemName Parameter.
    If you want Search for ConsumableItem name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with ConsumableItemId Parameter. 
    If you want to get additional parameter of ConsumableItem object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsConsumableItems
    Function gets ConsumableItemID from GLPI from Pipline, and return ConsumableItem object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsConsumableItems
    Function gets ConsumableItemID from GLPI from Pipline (u can pass many ID's like that), and return ConsumableItem object
.EXAMPLE
    PS C:\> Get-GlpiToolsConsumableItems -ConsumableItemId 326
    Function gets ConsumableItemID from GLPI which is provided through -ConsumableItemId after Function type, and return ConsumableItem object
.EXAMPLE 
    PS C:\> Get-GlpiToolsConsumableItems -ConsumableItemId 326, 321
    Function gets ConsumableItemID from GLPI which is provided through -ConsumableItemId keyword after Function type (u can provide many ID's like that), and return ConsumableItem object
.EXAMPLE
    PS C:\> Get-GlpiToolsConsumableItems -ConsumableItemId 234 -Raw
    Example will show ConsumableItem with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsConsumableItems -Raw
    Example will show ConsumableItem with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsConsumableItems -ConsumableItemName glpi
    Example will return glpi ConsumableItem, but what is the most important, ConsumableItem will be shown exacly as you see in glpi ConsumableItems tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsConsumableItems -ConsumableItemName glpi -SearchInTrash Yes
    Example will return glpi ConsumableItem, but from trash
.INPUTS
    ConsumableItem ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of ConsumableItems from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsConsumableItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ConsumableItemId")]
        [alias('CIID')]
        [string[]]$ConsumableItemId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ConsumableItemId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "ConsumableItemName")]
        [alias('CIN')]
        [string]$ConsumableItemName,
        [parameter(Mandatory = $false,
            ParameterSetName = "ConsumableItemName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "ConsumableItemId")]
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

        $ConsumableItemObjectArray = @()

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
                    uri     = "$($PathToGlpi)/ConsumableItem/?range=0-9999999999999"
                }
                
                $GlpiConsumableItemAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiConsumableItem in $GlpiConsumableItemAll) {
                    $ConsumableItemHash = [ordered]@{ }
                            $ConsumableItemProperties = $GlpiConsumableItem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ConsumableItemProp in $ConsumableItemProperties) {
                                $ConsumableItemHash.Add($ConsumableItemProp.Name, $ConsumableItemProp.Value)
                            }
                            $object = [pscustomobject]$ConsumableItemHash
                            $ConsumableItemObjectArray += $object 
                }
                $ConsumableItemObjectArray
                $ConsumableItemObjectArray = @()
            }
            ConsumableItemId { 
                foreach ( $CIId in $ConsumableItemId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/ConsumableItem/$($CIId)$ParamValue"
                    }

                    Try {
                        $GlpiConsumableItem = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ConsumableItemHash = [ordered]@{ }
                            $ConsumableItemProperties = $GlpiConsumableItem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ConsumableItemProp in $ConsumableItemProperties) {
                                $ConsumableItemHash.Add($ConsumableItemProp.Name, $ConsumableItemProp.Value)
                            }
                            $object = [pscustomobject]$ConsumableItemHash
                            $ConsumableItemObjectArray += $object 
                        } else {
                            $ConsumableItemHash = [ordered]@{ }
                            $ConsumableItemProperties = $GlpiConsumableItem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ConsumableItemProp in $ConsumableItemProperties) {

                                switch ($ConsumableItemProp.Name) {
                                    entities_id { $ConsumableItemPropNewValue = $ConsumableItemProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id { $ConsumableItemPropNewValue = $ConsumableItemProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } }
                                    Default {
                                        $ConsumableItemPropNewValue = $ConsumableItemProp.Value
                                    }
                                }
                                
                                $ConsumableItemHash.Add($ConsumableItemProp.Name, $ConsumableItemPropNewValue)
                            }
                            $object = [pscustomobject]$ConsumableItemHash
                            $ConsumableItemObjectArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "ConsumableItem ID = $CIId is not found"
                        
                    }
                    $ConsumableItemObjectArray
                    $ConsumableItemObjectArray = @()
                }
            }
            ConsumableItemName { 
                Search-GlpiToolsItems -SearchFor ConsumableItem -SearchType contains -SearchValue $ConsumableItemName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}