<#
.SYNOPSIS
    Function is getting Computer informations from GLPI
.DESCRIPTION
    Function is based on ComputerID which you can find in GLPI website
    Returns object with property's of computer
.PARAMETER All
    This parameter will return all computers from GLPI
.PARAMETER ComputerId
    This parameter can take pipline input, either, you can use this function with -ComputerId keyword.
    Provide to this param Computer ID from GLPI Computers Bookmark
.PARAMETER Raw
    Parameter which you can use with ComputerId Parameter.
    ComputerId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ComputerName
    Provide to this param Computer Name from GLPI Computers Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with ComputerName Parameter.
    If you want Search for computer name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with ComputerId Parameter. 
    If you want to get additional parameter of computer object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsComputers
    Function gets ComputerID from GLPI from Pipline, and return Computer object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsComputers
    Function gets ComputerID from GLPI from Pipline (u can pass many ID's like that), and return Computer object
.EXAMPLE
    PS C:\> Get-GlpiToolsComputers -ComputerId 326
    Function gets ComputerID from GLPI which is provided through -ComputerId after Function type, and return Computer object
.EXAMPLE 
    PS C:\> Get-GlpiToolsComputers -ComputerId 326, 321
    Function gets ComputerID from GLPI which is provided through -ComputerId keyword after Function type (u can provide many ID's like that), and return Computer object
.EXAMPLE
    PS C:\> Get-GlpiToolsComputers -ComputerId 234 -Raw
    Example will show Computer with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsComputers -Raw
    Example will show Computer with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsComputers -ComputerName glpi
    Example will return glpi Computer, but what is the most important, Computer will be shown exacly as you see in glpi Computers tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsComputers -ComputerName glpi -SearchInTrash Yes
    Example will return glpi Computer, but from trash
.INPUTS
    Computer ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of computers from GLPI
.NOTES
    PSP 12/2018
#>

function Get-GlpiToolsComputers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,


        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ComputerId")]
        [alias('CID')]
        [string[]]$ComputerId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ComputerId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "ComputerName")]
        [alias('CN')]
        [string]$ComputerName,
        [parameter(Mandatory = $false,
            ParameterSetName = "ComputerName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "ComputerId")]
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

        $ComputerObjectArray = [System.Collections.Generic.List[PSObject]]::New()

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
                    uri     = "$($PathToGlpi)/Computer/?range=0-9999999999999"
                }
                
                $GlpiComputerAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiComputer in $GlpiComputerAll) {
                    $ComputerHash = [ordered]@{ }
                            $ComputerProperties = $GlpiComputer.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerProp in $ComputerProperties) {
                                $ComputerHash.Add($ComputerProp.Name, $ComputerProp.Value)
                            }
                            $object = [pscustomobject]$ComputerHash
                            $ComputerObjectArray.Add($object) 
                }
                $ComputerObjectArray
                $ComputerObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                
            }
            ComputerId { 
                foreach ( $CId in $ComputerId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Computer/$($CId)$ParamValue"
                    }

                    Try {
                        $GlpiComputer = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ComputerHash = [ordered]@{ }
                            $ComputerProperties = $GlpiComputer.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerProp in $ComputerProperties) {
                                $ComputerHash.Add($ComputerProp.Name, $ComputerProp.Value)
                            }
                            $object = [pscustomobject]$ComputerHash
                            $ComputerObjectArray.Add($object)
                        } else {
                            $ComputerHash = [ordered]@{ }
                            $ComputerProperties = $GlpiComputer.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerProp in $ComputerProperties) {
                                
                                $ComputerPropNewValue = Get-GlpiToolsParameters -Parameter $ComputerProp.Name -Value $ComputerProp.Value

                                $ComputerHash.Add($ComputerProp.Name, $ComputerPropNewValue)
                            }
                            $object = [pscustomobject]$ComputerHash
                            $ComputerObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Computer ID = $CId is not found"
                        
                    }
                    $ComputerObjectArray
                    $ComputerObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ComputerName { 
                Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue $ComputerName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}