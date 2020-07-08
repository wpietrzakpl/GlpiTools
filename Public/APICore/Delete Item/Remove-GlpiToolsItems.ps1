<#
.SYNOPSIS
    Function Remove an object existing in GLPI.
.DESCRIPTION
    Remove an object existing in GLPI. You can choose between every items in Asset Tab.
.PARAMETER RemoveFrom
    Parameter specify where you want to Remove object. 
    You can add your custom parameter options to Parameters.json file located in Private folder
.PARAMETER ItemId
    Paremter which indicate on item id to Remove. 
.PARAMETER HashtableToAdd
    Parameter specify a hashtable with fields of itemtype to be Removed.
.PARAMETER JsonPayload
    Parameter specify a hashtable with "input" parameter to be a JsonPayload.
.PARAMETER Purge
    Switch parameter boolean, if the itemtype have a trashbin, you can force purge (Remove finally). Optional.
.EXAMPLE
    PS C:\> Remove-GlpiToolsItems -RemoveFrom Computer -ItemId 1
    Command will Remove item with id 1, and put item into trashbin.
.EXAMPLE
    PS C:\> Remove-GlpiToolsItems -RemoveFrom Computer -ItemId 1 -Purge
    Command will Remove item with id 1. Command will Remove item from trashbin too.
.EXAMPLE
    PS C:\> $example =  @{id = "1"} 
    PS C:\> Remove-GlpiToolsItems -RemoveFrom Computer -HashtableToRemove $example
    Example will Remove item from Computers.
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
    PS C:\> Remove-GlpiToolsItems -RemoveFrom Computer -JsonPayload $example
    Example will Add items into Computers
.INPUTS
    Id of item, hashtable, JsonPayload. 
.OUTPUTS
    Information with id and message, which items were added.
.NOTES
    PSP 04/2019
#>

function Remove-GlpiToolsItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [alias('DF')]
        [string]$RemoveFrom,

        [parameter(Mandatory = $true,
            ParameterSetName = "ID")]
        [alias('IId')]
        [int]$ItemId,

        [parameter(Mandatory = $true,
            ParameterSetName = "HashtableToRemove")]
        [alias('HashToDel')]
        [hashtable]$HashtableToRemove,

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
                    uri     = "$($PathToGlpi)/$($RemoveFrom)/$($ItemId)$($PurgeValue)"
                }
                Invoke-RestMethod @params
            }
            HashtableToRemove {
                $GlpiRemove = $HashtableToRemove | ConvertTo-Json

                $Remove = '{ "input" : ' + $GlpiRemove + '}' 
                
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'delete'
                    uri     = "$($PathToGlpi)/$($RemoveFrom)/"
                    body    = ([System.Text.Encoding]::UTF8.GetBytes($Remove))
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
                    uri     = "$($PathToGlpi)/$($RemoveFrom)/"
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

$RemoveFromValidate = {
    param ($commandName, $parameterName, $stringMatch)
    $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
}
Register-ArgumentCompleter -CommandName Remove-GlpiToolsItems -ParameterName RemoveFrom -ScriptBlock $RemoveFromValidate