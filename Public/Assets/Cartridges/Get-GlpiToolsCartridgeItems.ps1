<#
.SYNOPSIS
    Function is getting CartridgeItem informations from GLPI
.DESCRIPTION
    Function is based on CartridgeItemID which you can find in GLPI website
    Returns object with property's of CartridgeItem
.PARAMETER All
    This parameter will return all CartridgeItems from GLPI
.PARAMETER CartridgeItemId
    This parameter can take pipline input, either, you can use this function with -CartridgeItemId keyword.
    Provide to this param CartridgeItem ID from GLPI CartridgeItems Bookmark
.PARAMETER Raw
    Parameter which you can use with CartridgeItemId Parameter.
    CartridgeItemId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER CartridgeItemName
    Provide to this param CartridgeItem Name from GLPI CartridgeItems Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with CartridgeItemName Parameter.
    If you want Search for CartridgeItem name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with CartridgeItemId Parameter. 
    If you want to get additional parameter of CartridgeItem object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsCartridgeItems
    Function gets CartridgeItemID from GLPI from Pipline, and return CartridgeItem object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsCartridgeItems
    Function gets CartridgeItemID from GLPI from Pipline (u can pass many ID's like that), and return CartridgeItem object
.EXAMPLE
    PS C:\> Get-GlpiToolsCartridgeItems -CartridgeItemId 326
    Function gets CartridgeItemID from GLPI which is provided through -CartridgeItemId after Function type, and return CartridgeItem object
.EXAMPLE 
    PS C:\> Get-GlpiToolsCartridgeItems -CartridgeItemId 326, 321
    Function gets CartridgeItemID from GLPI which is provided through -CartridgeItemId keyword after Function type (u can provide many ID's like that), and return CartridgeItem object
.EXAMPLE
    PS C:\> Get-GlpiToolsCartridgeItems -CartridgeItemId 234 -Raw
    Example will show CartridgeItem with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsCartridgeItems -Raw
    Example will show CartridgeItem with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsCartridgeItems -CartridgeItemName glpi
    Example will return glpi CartridgeItem, but what is the most important, CartridgeItem will be shown exacly as you see in glpi CartridgeItems tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsCartridgeItems -CartridgeItemName glpi -SearchInTrash Yes
    Example will return glpi CartridgeItem, but from trash
.INPUTS
    CartridgeItem ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of CartridgeItems from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsCartridgeItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "CartridgeItemId")]
        [alias('CIID')]
        [string[]]$CartridgeItemId,
        [parameter(Mandatory = $false,
            ParameterSetName = "CartridgeItemId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "CartridgeItemName")]
        [alias('CIN')]
        [string]$CartridgeItemName,
        [parameter(Mandatory = $false,
            ParameterSetName = "CartridgeItemName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "CartridgeItemId")]
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

        $CartridgeItemObjectArray = [System.Collections.Generic.List[PSObject]]::New()

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
                    uri     = "$($PathToGlpi)/CartridgeItem/?range=0-9999999999999"
                }
                
                $GlpiCartridgeItemAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiCartridgeItem in $GlpiCartridgeItemAll) {
                    $CartridgeItemHash = [ordered]@{ }
                            $CartridgeItemProperties = $GlpiCartridgeItem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CartridgeItemProp in $CartridgeItemProperties) {
                                $CartridgeItemHash.Add($CartridgeItemProp.Name, $CartridgeItemProp.Value)
                            }
                            $object = [pscustomobject]$CartridgeItemHash
                            $CartridgeItemObjectArray.Add($object)
                }
                $CartridgeItemObjectArray
                $CartridgeItemObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            CartridgeItemId { 
                foreach ( $CIId in $CartridgeItemId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/CartridgeItem/$($CIId)$ParamValue"
                    }

                    Try {
                        $GlpiCartridgeItem = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $CartridgeItemHash = [ordered]@{ }
                            $CartridgeItemProperties = $GlpiCartridgeItem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CartridgeItemProp in $CartridgeItemProperties) {
                                $CartridgeItemHash.Add($CartridgeItemProp.Name, $CartridgeItemProp.Value)
                            }
                            $object = [pscustomobject]$CartridgeItemHash
                            $CartridgeItemObjectArray.Add($object)
                        } else {
                            $CartridgeItemHash = [ordered]@{ }
                            $CartridgeItemProperties = $GlpiCartridgeItem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CartridgeItemProp in $CartridgeItemProperties) {

                                $CartridgePropNewValue = Get-GlpiToolsParameters -Parameter $CartridgeItemProp.Name -Value $CartridgeItemProp.Value
                                $CartridgeItemHash.Add($CartridgeItemProp.Name, $CartridgePropNewValue)

                            }
                            $object = [pscustomobject]$CartridgeItemHash
                            $CartridgeItemObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "CartridgeItem ID = $CIId is not found"
                        
                    }
                    $CartridgeItemObjectArray
                    $CartridgeItemObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            CartridgeItemName { 
                Search-GlpiToolsItems -SearchFor CartridgeItem -SearchType contains -SearchValue $CartridgeItemName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}