<#
.SYNOPSIS
    Function to show Apps Structures Slas from GLPI
.DESCRIPTION
    Function to show Apps Structures Slas from GLPI. Function will show all Slas from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps Sla.
.PARAMETER AppsStructureComponentSlaId
    Int parameter, you can provide here number of Apps Structure Sla. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentSla -All
    Example will show All Apps Structures Slas
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentSla -AppsStructureComponentSlaId 2
    Example will show Apps Structure Sla which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentSla -AppsStructureComponentSlaId 2 -Raw
    Example will show Apps Structure Sla which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentSla
    Example will show Apps Structure Sla which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentSla -Raw
    Example will show Apps Structure Sla which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsAppsStructuresComponentSla {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentSlaId")]
        [alias('ASCSID')]
        [int[]]$AppsStructureComponentSlaId
    )
    
    begin {
        $InvocationCommand = $MyInvocation.MyCommand.Name

        if (Check-GlpiToolsPluginExist -InvocationCommand $InvocationCommand) {

        }
        else {
            throw "You don't have this plugin Enabled in GLPI"
        }

        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
    
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ComponentSlaArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponentSla/?range=0-9999999999999"
                }
                
                $GlpiComponentSlaAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentSla in $GlpiComponentSlaAll) {
                    $ComponentSlaHash = [ordered]@{ }
                    $ComponentSlaProperties = $GlpiComponentSla.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentSlaProp in $ComponentSlaProperties) {
                        $ComponentSlaHash.Add($ComponentSlaProp.Name, $ComponentSlaProp.Value)
                    }
                    $object = [pscustomobject]$ComponentSlaHash
                    $ComponentSlaArray.Add($object)
                }
                $ComponentSlaArray
                $ComponentSlaArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            AppsStructureComponentSlaId {
                foreach ($ASCSid in $AppsStructureComponentSlaId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponentSla/$($ASCSid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentSlaAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentSla in $GlpiComponentSlaAll) {
                            $ComponentSlaHash = [ordered]@{ }
                            $ComponentSlaProperties = $GlpiComponentSla.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentSlaProp in $ComponentSlaProperties) {
                                $ComponentSlaHash.Add($ComponentSlaProp.Name, $ComponentSlaProp.Value)
                            }
                            $object = [pscustomobject]$ComponentSlaHash
                            $ComponentSlaArray.Add($object)
                        }
                        $ComponentSlaArray
                        $ComponentSlaArray = [System.Collections.Generic.List[PSObject]]::New()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component Sla ID = $ASCSid is not found"
                    }
                }
            }
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}