<#
.SYNOPSIS
    Function Add an object (or multiple objects) into GLPI.
.DESCRIPTION
    Function Add an object (or multiple objects) into GLPI. You can choose between every items in Asset Tab.
.PARAMETER AddTo
    Parameter specify where you want to add new object. 
.PARAMETER HashtableToAdd
    Parameter specify a hashtable with fields of itemtype to be inserted.
.PARAMETER JsonPayload
    Parameter specify a hashtable with "input" parameter to be a JsonPayload.
.EXAMPLE
    PS C:\> Add-GlpiToolsItem -AddTo Computer -HashtableToAdd @{name = "test"} | ConvertTo-Json
    Example will add item into Computers
.EXAMPLE
    PS C:\> $example =  @{name = "test"} | ConvertTo-Json
    PS C:\> Add-GlpiToolsItem -AddTo Computer -HashtableToAdd $example
    Example will add item into Computers
.EXAMPLE
    PS C:\> $example = @{ name = "test" } | ConvertTo-Json
    PS C:\> $upload = '{ "input" : ' + $example + '}'
    PS C:\> Add-GlpiToolsItem -AddTo Computer -JsonPayload $upload
.EXAMPLE
    PS C:\> $example = "@
    {
	"input" : [
		{
			"name" : "test1",
			"comment" : "updated from script"
		},
		{
			"name" : "test2",
			"comment" : "updated from script"
		}
	]
}
@"
    PS C:\> Add-GlpiToolsItem -AddTo Computer -JsonPayload $example
    Example will Add items into Computers
.INPUTS
    Hashtable with "input" parameter, or JsonPayload    .
.OUTPUTS
    Information with id and message, which items were added.
.NOTES
    PSP 04/2019
#>

function Add-GlpiToolsItem {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [alias('AT')]
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
        [string]$AddTo,

        [parameter(Mandatory = $true,
            ParameterSetName = "HashtableToAdd")]
        [alias('HashToAdd')]
        [hashtable]$HashtableToAdd,

        [parameter(Mandatory = $false,
            ParameterSetName = "JsonPayload")]
        [alias('JsPa')]
        [array]$JsonPayload
        
    )
    
    begin {
        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys
    }
    
    process {

        switch ($ChoosenParam) {
            HashtableToAdd {
                $GlpiUpload = $HashtableToAdd | ConvertTo-Json

                $Upload = '{ "input" : ' + $GlpiUpload + '}' 
                
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'post'
                    uri     = "$($PathToGlpi)/$($AddTo)/"
                    body    = ([System.Text.Encoding]::UTF8.GetBytes($Upload))
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
                    method  = 'post'
                    uri     = "$($PathToGlpi)/$($AddTo)/"
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