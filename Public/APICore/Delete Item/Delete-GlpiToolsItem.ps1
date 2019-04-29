<#
.SYNOPSIS
    Function Delete an object existing in GLPI.
.DESCRIPTION
    Delete an object existing in GLPI. You can choose between every items in Asset Tab.
.PARAMETER DeleteFrom
    Parameter specify where you want to delete object. 
.PARAMETER ItemId
    Paremter which indicate on item id to delete. 
.PARAMETER HashtableToAdd
    Parameter specify a hashtable with fields of itemtype to be deleted.
.PARAMETER JsonPayload
    Parameter specify a hashtable with "input" parameter to be a JsonPayload.
.PARAMETER Purge
    Switch parameter boolean, if the itemtype have a trashbin, you can force purge (delete finally). Optional.
.EXAMPLE
    PS C:\> Delete-GlpiToolsItem -DeleteFrom Computer -ItemId 1
    Command will delete item with id 1, and put item into trashbin.
.EXAMPLE
    PS C:\> Delete-GlpiToolsItem -DeleteFrom Computer -ItemId 1 -Purge
    Command will delete item with id 1. Command will delete item from trashbin too.
.EXAMPLE
    PS C:\> $example =  @{id = "1"} 
    PS C:\> Delete-GlpiToolsItem -DeleteFrom Computer -HashtableToDelete $example
    Example will Delete item from Computers.
.EXAMPLE
    PS C:\> $example = "@
    {
	"input" : [
		{
			"id" : "1"
		},
		{
			"id" : "2"
		}
	]
}
@"
    PS C:\> Delete-GlpiToolsItem -DeleteFrom Computer -JsonPayload $example
    Example will Add items into Computers
.INPUTS
    Id of item, hashtable, JsonPayload. 
.OUTPUTS
    Information with id and message, which items were added.
.NOTES
    PSP 04/2019
#>

function Delete-GlpiToolsItem {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [alias('DF')]
        [ValidateSet("Computer",
            "Monitor",
            "Software",
            "NetworkEquipment",
            "Peripherial",
            "Printer",
            "CartridgeItem",
            "ConsumableItem",
            "Phone",
            "Rack",
            "Enclosure",
            "Pdu",
            "Allassets")]
        [string]$DeleteFrom,

        [parameter(Mandatory = $true,
            ParameterSetName = "ID")]
        [alias('IId')]
        [int]$ItemId,

        [parameter(Mandatory = $true,
            ParameterSetName = "HashtableToDelete")]
        [alias('HashToDel')]
        [hashtable]$HashtableToDelete,

        [parameter(Mandatory = $false,
            ParameterSetName = "JsonPayload")]
        [alias('JsPa')]
        [array]$JsonPayload,

        [parameter(Mandatory = $false)]
        [switch]$Purge
    )
    
    begin {
        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        if ($Purge) {
            $PurgeValue = '?force_purge=true'
        }
    }
    
    process {
        switch ($ChoosenParam) {
            ItemId {
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'delete'
                    uri     = "$($PathToGlpi)/$($DeleteFrom)/$($ItemId)$($PurgeValue)"
                }
                Invoke-RestMethod @params
            }
            HashtableToDelete {
                $GlpiDelete = $HashtableToDelete | ConvertTo-Json

                $Delete = '{ "input" : ' + $GlpiDelete + '}' 
                
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'delete'
                    uri     = "$($PathToGlpi)/$($DeleteFrom)/"
                    body    = ([System.Text.Encoding]::UTF8.GetBytes($Delete))
                }
                Invoke-RestMethod @params
            }
            JsonPayload {
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'delete'
                    uri     = "$($PathToGlpi)/$($DeleteFrom)/"
                    body    = ([System.Text.Encoding]::UTF8.GetBytes($JsonPayload))
                }
                Invoke-RestMethod @params
            }
            Default { Write-Verbose "You didn't specified any parameter, choose from one available" }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}