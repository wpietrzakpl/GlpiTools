<#
.SYNOPSIS
    Function to show Apps Structures Targets from GLPI
.DESCRIPTION
    Function to show Apps Structures Targets from GLPI. Function will show all Targets from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps Target.
.PARAMETER AppsStructureComponentTargetId
    Int parameter, you can provide here number of Apps Structure Target. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentTarget -All
    Example will show All Apps Structures Targets
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentTarget -AppsStructureComponentTargetId 2
    Example will show Apps Structure Target which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentTarget -AppsStructureComponentTargetId 2 -Raw
    Example will show Apps Structure Target which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentTarget
    Example will show Apps Structure Target which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentTarget -Raw
    Example will show Apps Structure Target which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsAppsStructuresComponentTarget {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentTargetId")]
        [alias('ASID')]
        [int[]]$AppsStructureComponentTargetId
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

        $ComponentTargetsArray = @()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponenttarget/?range=0-9999999999999"
                }
                
                $GlpiComponentTargetAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentTarget in $GlpiComponentTargetAll) {
                    $ComponentTargetHash = [ordered]@{ }
                    $ComponentTargetProperties = $GlpiComponentTarget.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentTargetProp in $ComponentTargetProperties) {
                        $ComponentTargetHash.Add($ComponentTargetProp.Name, $ComponentTargetProp.Value)
                    }
                    $object = [pscustomobject]$ComponentTargetHash
                    $ComponentTargetsArray += $object 
                }
                $ComponentTargetsArray
                $ComponentTargetsArray = @()
            }
            AppsStructureComponentTargetId {
                foreach ($ASCTid in $AppsStructureComponentTargetId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponenttarget/$($ASCTid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentTargetAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentTarget in $GlpiComponentTargetAll) {
                            $ComponentTargetHash = [ordered]@{ }
                            $ComponentTargetProperties = $GlpiComponentTarget.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentTargetProp in $ComponentTargetProperties) {
                                $ComponentTargetHash.Add($ComponentTargetProp.Name, $ComponentTargetProp.Value)
                            }
                            $object = [pscustomobject]$ComponentTargetHash
                            $ComponentTargetsArray += $object 
                        }
                        $ComponentTargetsArray
                        $ComponentTargetsArray = @()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component Target ID = $ASCTid is not found"
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