<#
.SYNOPSIS
    Function gets list of Search Options for specific Search in GLPI
.DESCRIPTION
    Function gets list of Search Options for specific Search in GLPI
    Parameters are the names of options in GLPI
    Remember that, names used in cmdlet coming from glpi URL, and can be hard to understand, but most of them are intuitional.
    To get name you always have to look at the URL in GLPI, for example "http://glpi/front/computer.php" where "computer" is the name to use in parameter.
.PARAMETER ListOptionsFor
    You can use this function with -ListOptionsFor parameter.
    Using TAB button you can choose desired option.
    You can add your custom parameter options to Parameters.json file located in Private folder
.EXAMPLE
    PS C:\WINDOWS\system32> Get-GlpiToolsListSearchOptions -ListOptionsFor DeviceCase
    Example will return object which is list of Search Option for Setup -> Components Tab from GLPI
.INPUTS
    None
.OUTPUTS
    Function returns PSCustomObject with property's of List Options from GLPI
.NOTES
    PSP 03/2019
#>

function Get-GlpiToolsListSearchOptions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [String]$ListOptionsFor

    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        $SearchOptionsArray = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri = "$($PathToGlpi)/listSearchOptions/$($ListOptionsFor)"
        }
        $ListSearchOptions = Invoke-RestMethod @params
        $ListProperties = $ListSearchOptions.PSObject.Properties | Select-Object -Property Name,Value
        
        foreach ( $list in $ListProperties ) {
            $OptionsHash = [ordered]@{
                'Id' = $list.Name
                'Name' = $list.Value.name
                'Table' = $list.Value.table
                'Field' = $list.Value.field
                'DataType' = $list.Value.datatype
                'NoSearch' = $list.Value.nosearch
                'NoDisplay' = $list.Value.nodisplay
                'Available_Searchtypes' = $list.Value.available_searchtypes
                'Uid' = $list.Value.uid   
            }
            $object = New-Object -TypeName PSCustomObject -Property $OptionsHash
            $SearchOptionsArray.Add($object)
        }
        $SearchOptionsArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}

$ListOptionForValidate = {
    param ($commandName, $parameterName, $stringMatch)
    $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
}
Register-ArgumentCompleter -CommandName Get-GlpiToolsListSearchOptions -ParameterName ListOptionsFor -ScriptBlock $ListOptionForValidate