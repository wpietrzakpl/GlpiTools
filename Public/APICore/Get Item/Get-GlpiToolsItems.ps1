<#
.SYNOPSIS
    Function is getting all the items of a specific type in GLPI (also feature SearchText).
.DESCRIPTION
    Function is getting all the items of a specific type in GLPI.
    Can be filter with SearchText paramter
    Like https://github.com/glpi-project/glpi/blob/master/apirest.md#get-all-items
.PARAMETER ItemType
    Type of item wanted.
    Exemples : Computer, Monitor, User, Group_Ticket, Group_User, etc.
.PARAMETER SearchText
    SearchText (default NULL): hashtable of filters to pass on the query (with key = field and value = the text to search).
    By default it act as a '-like "*value*"'. Use ^ and $ to force an exact match. Eg. SearchText = @{"groups_id"="^10$" ; "type"="^2$"}
    This parameter can take pipeline input.
.PARAMETER Raw
    Raw is always ON if the return contain more that one object.
    If the return contain only one object and RAW is not use, parameters will be converted (expanded to show name instead of ID).
    Use the parameter RAW to force to show ID in ALL cases.
.PARAMETER OnlyId
    (default: false): keep only id keys in returned data. Optional.
.PARAMETER SearchInTrash
    (default: false): Return deleted element. Optional
.PARAMETER ExtraParameter
    String append to the query for extra option. Refer to apirest.php.
    Ex. "&only_id=true" or "&with_infocoms", etc..
.EXAMPLE
    PS C:\> Get-GlpiToolsItems -ItemType "Group_Ticket"
    Function gets all items from Group_Ticket
.EXAMPLE
    PS C:\> @{"groups_id"="^10$" ; "type"="^2$"} | Get-GlpiToolsItems -ItemType "Group_Ticket"
    Function gets SearchCriteria from Pipeline, and return GLPI object
.EXAMPLE
    PS C:\> @{"groups_id"="^10$" ; "type"="^2$"}  , @{"groups_id"="^15$" ; "type"="^2$"}  | Get-GlpiToolsItems -ItemType "Group_Ticket"
    Function gets multiple SearchCriteria from Pipeline, and return GLPI object
.EXAMPLE
    PS C:\> Get-GlpiToolsItems -ItemType "Group_Ticket" -SearchText @{"groups_id"="^10$" ; "type"="^2$"}
    Function gets GLPI object filter by SearchText.
.EXAMPLE
    PS C:\> Get-GlpiToolsItems -ItemType "Ticket" -SearchText @{"id"="^234$"}  -Raw
    Example will show Ticket with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> @{"id"="^234$"} | Get-GlpiToolsItems -ItemType "Ticket" -Raw
    Example will show Ticket with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsItems -ItemType "Ticket" -SearchInTrash $true
    Example will return glpi Ticket, but from trash
.INPUTS
    SearchText hashtable.
.OUTPUTS
    Function returns PSCustomObject with property's of Object from GLPI
.NOTES
    SilentBob999 10/2019
#>

function Get-GlpiToolsItems{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [alias('Type')]
        [string]$ItemType,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true)]
        [alias('Search')]
        [hashtable]$SearchText,

        [parameter(Mandatory = $false)]
        [bool]$Raw = $false,

        [parameter(Mandatory = $false)]
        [alias('SIT')]
        [bool]$SearchInTrash = $false,

        [parameter(Mandatory = $false)]
        [bool]$OnlyId = $false,

        [parameter(Mandatory = $false)]
        [alias('Param')]
        [string]$ExtraParameter

    )

    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $GlpiObjectArray = [System.Collections.Generic.List[PSObject]]::New()

        if ($SearchInTrash) { $IsDeletedString = "&is_deleted=true" }
        if ($OnlyId) { $OnlyIdString = "&only_id=true" }

    }

    process {

        $SearchTextString = ""
        foreach ($key in $SearchText.Keys) {
            $SearchTextString += "&searchText[$($key)]=$($SearchText[$key])"
        }

        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/$($ItemType)/?range=0-9999999999999$($SearchTextString)$($IsDeletedString)$($OnlyIdString)$($ExtraParameter)"
        }

        $GlpiObjectAll = Invoke-RestMethod @params -Verbose:$false
        if (-not $Raw -and (@($GlpiObjectAll).count -gt 1)) {Write-Warning "RAW forced because more than 1 result"}

        foreach ($GlpiObject in $GlpiObjectAll) {
            if ($Raw -or (@($GlpiObjectAll).count -gt 1) ) {
                $ObjectHash = [ordered]@{ }
                $ObjectProperties = $GlpiObject.PSObject.Properties | Select-Object -Property Name, Value

                foreach ($ObjectProp in $ObjectProperties) {
                    $ObjectHash.Add($ObjectProp.Name, $ObjectProp.Value)
                }
                $object = [pscustomobject]$ObjectHash
                $GlpiObjectArray.Add($object)
            } else {
                $ObjectHash = [ordered]@{ }
                $ObjectProperties = $GlpiObject.PSObject.Properties | Select-Object -Property Name, Value

                foreach ($ObjectProp in $ObjectProperties) {

                    $ObjectPropNewValue = Get-GlpiToolsParameters -Parameter $ObjectProp.Name -Value $ObjectProp.Value

                    $ObjectHash.Add($ObjectProp.Name, $ObjectPropNewValue)
                }
                $object = [pscustomobject]$ObjectHash
                $GlpiObjectArray.Add($object)
            }
        }

        $GlpiObjectArray
        $GlpiObjectArray = [System.Collections.Generic.List[PSObject]]::New()

    }

    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}

$ItemTypeValidate = {
    param ($commandName, $parameterName, $stringMatch)
    $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
}
Register-ArgumentCompleter -CommandName Get-GlpiToolsItems -ParameterName ItemType -ScriptBlock $ItemTypeValidate