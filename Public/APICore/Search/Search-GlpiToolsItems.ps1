<#
.SYNOPSIS
    Function is using GLPI Search Engine to get informations.
.DESCRIPTION
    Function Search for specific component in GLPI
    Parameters are the names of options in GLPI
    Remember that, names used in cmdlet coming from glpi URL, and can be hard to understand, but most of them are intuitional.
    To get name you always have to look at the URL in GLPI, for example "http://glpi/front/computer.php" where "computer" is the name to use in parameter.
.PARAMETER SearchFor
    You can use this function with -SearchFor parameter.
    Using TAB button you can choose desired option.
    You can add your custom parameter options to Parameters.json file located in Private folder
.PARAMETER SearchType
    You can use this function with -SearchType parameter.
    Using TAB button you can choose desired option.
.PARAMETER SearchField
    You can use this function with -SearchField parameter.
    This is an optional parameter, default value is 1 which is called Name in GLPI.
    This parameter can take pipeline input, even from Get-GlpiToolsListSearchOptions cmdlet.
.PARAMETER SearchValue
    You can use this function with -SearchValue parameter.
    This parameter can take pipeline input.
    Provide value to the function, which is used to search for. 
.PARAMETER SearchTrash
    You can use this function with -SearchTrash parameter.
    This is an optional switch parameter.
.EXAMPLE
    PS C:\> Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue DC
    Example will show every asset which contains value "DC" in the Name from Asset->Computers.
.EXAMPLE
    PS C:\> Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue DC -SearchField 1 
    Example will show every asset which contains value "DC" in the Name from Asset->Computers.
    SearchFiled can be retrieved from Get-GlpiToolsListSearchOptions cmdlet, you can provide it throught pipeline.
.EXAMPLE
    PS C:\> Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue DC -SearchField 1 -SearchInTrash
    Example will show every asset which contains value "DC" in the Name from Asset->Computers.
    SearchFiled can be retrieved from Get-GlpiToolsListSearchOptions cmdlet, you can provide it throught pipeline.
    SearchInTrash will allow you to search for assets from trash.
.EXAMPLE
    PS C:\>  Search-GlpiToolsItems -SearchFor Computer -SearchType contains, contains -SearchField 1, 40 -SearchValue c, virtual -SearchLink AND+NOT
    Example will get 2 or more fields and filter them with the conditions.
    Allow to put more options for search, regarding Links (AND. AND+NOT...)
.INPUTS
    Only for -SearchValue, and -SearchField.
.OUTPUTS
    Function returns PSCustomObject with property's of Search results from GLPI
.NOTES
    PSP 02/2019
#>

function Search-GlpiToolsItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [String]$SearchFor,

        [parameter(Mandatory = $true)]
        [ValidateSet("contains",
            "equals",
            "notequals")]
        [String[]]$SearchType,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true)]
        [String[]]$SearchField = 1,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [String[]]$SearchValue,

        [parameter(Mandatory = $false,
        ValueFromPipeline = $true)]
        [ValidateScript({$_ -ge 2})]
        [ValidateSet("AND",
            "OR",
            "AND+NOT",
            "OR+NOT")]
        [String[]]$SearchLink = 'AND',

        [parameter(Mandatory = $false)]
        [ValidateSet("Yes", "No")]
        [String]$SearchInTrash = "No"
    )
    
    begin {
        $SearchArray = [System.Collections.Generic.List[PSObject]]::New()

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        if ($SearchInTrash -eq "Yes") {
            $Trash = 1
        }
        else {
            $Trash = 0
        }
        
        $ListSearchOptions = Get-GlpiToolsListSearchOptions -ListOptionsFor $SearchFor
    }
    
    process {
        $SearchCounter = $SearchField.Count   
        for ($counter = 0; $counter -lt $SearchCounter; $counter++) {
            if ($counter -eq ($SearchCounter - 1)) {
                $Link = "&criteria[$counter][field]=$($SearchField[$counter])&criteria[$counter][searchtype]=$($SearchType[$counter])&criteria[$counter][value]=$($SearchValue[$counter])"
            } else {
                $Link = "&criteria[$counter][field]=$($SearchField[$counter])&criteria[$counter][searchtype]=$($SearchType[$counter])&criteria[$counter][value]=$($SearchValue[$counter])&criteria[$($counter+1)][link]=$($SearchLink[$counter])"
            }   
            $SearchPath = $SearchPath + $Link
        }
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/search/$($SearchFor)?is_deleted=$($Trash)&as_map=0$SearchPath&search=Search&itemtype=$($SearchFor)&range=0-9999999999999"
        }
            
        $SearchResult = Invoke-RestMethod @params
        
        try {
            $SearchResults = $SearchResult | Select-Object -ExpandProperty data -ErrorAction Stop
        } catch {

        }
        
        foreach ($SearchItem in $SearchResults) {
            $SearchHash = [ordered]@{}
            $DataResult = $SearchItem.PSObject.Properties | Select-Object -Property Name, Value 

            foreach ($Data in $DataResult) {
                    
                $Property = $ListSearchOptions | Where-Object {$_.Id -eq $Data.Name } | Select-Object -ExpandProperty Name
                $Table = $ListSearchOptions | Where-Object {$_.Id -eq $Data.Name } | Select-Object -ExpandProperty Table
                $Value = $Data.Value

                if ($SearchHash.Keys -contains $Property) {
                    $NewProperty = $Property + "_" + $Table
                    $SearchHash.Add($NewProperty, $Value)
                } else {
                    $SearchHash.Add($Property, $Value)
                }
                
            }

            $object = [pscustomobject]$SearchHash
            $SearchArray.Add($object)
        }

        $SearchArray
        $SearchArray = [System.Collections.Generic.List[PSObject]]::New()
        
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}

$SearchForValidate = {
    param ($commandName, $parameterName, $stringMatch)
    $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
}
$SearchTypeValidate = {
    param ($commandName, $parameterName, $stringMatch)
    $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).SearchType | Where-Object {$_ -match "$stringMatch"}
}
Register-ArgumentCompleter -CommandName Search-GlpiToolsItems -ParameterName SearchFor -ScriptBlock $SearchForValidate
Register-ArgumentCompleter -CommandName Search-GlpiToolsItems -ParameterName SearchType -ScriptBlock $SearchTypeValidate