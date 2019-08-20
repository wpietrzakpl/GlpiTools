<#
.SYNOPSIS
    Function to show Apps Structures Dbs from GLPI
.DESCRIPTION
    Function to show Apps Structures Dbs from GLPI. Function will show all Dbs from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps Db.
.PARAMETER AppsStructureComponentDbId
    Int parameter, you can provide here number of Apps Structure Db. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentDb -All
    Example will show All Apps Structures Dbs
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentDb -AppsStructureComponentDbId 2
    Example will show Apps Structure Db which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentDb -AppsStructureComponentDbId 2 -Raw
    Example will show Apps Structure Db which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentDb
    Example will show Apps Structure Db which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentDb -Raw
    Example will show Apps Structure Db which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsAppsStructuresComponentDb {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentDbId")]
        [alias('ASCDID')]
        [int[]]$AppsStructureComponentDbId
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

        $ComponentDbArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponentDb/?range=0-9999999999999"
                }
                
                $GlpiComponentDbAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentDb in $GlpiComponentDbAll) {
                    $ComponentDbHash = [ordered]@{ }
                    $ComponentDbProperties = $GlpiComponentDb.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentDbProp in $ComponentDbProperties) {
                        $ComponentDbHash.Add($ComponentDbProp.Name, $ComponentDbProp.Value)
                    }
                    $object = [pscustomobject]$ComponentDbHash
                    $ComponentDbArray.Add($object)
                }
                $ComponentDbArray
                $ComponentDbArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            AppsStructureComponentDbId {
                foreach ($ASCDid in $AppsStructureComponentDbId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponentDb/$($ASCDid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentDbAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentDb in $GlpiComponentDbAll) {
                            $ComponentDbHash = [ordered]@{ }
                            $ComponentDbProperties = $GlpiComponentDb.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentDbProp in $ComponentDbProperties) {
                                $ComponentDbHash.Add($ComponentDbProp.Name, $ComponentDbProp.Value)
                            }
                            $object = [pscustomobject]$ComponentDbHash
                            $ComponentDbArray.Add($object)
                        }
                        $ComponentDbArray
                        $ComponentDbArray = [System.Collections.Generic.List[PSObject]]::New()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component Db ID = $ASCDid is not found"
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