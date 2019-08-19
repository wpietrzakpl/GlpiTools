<#
.SYNOPSIS
    Function to show Apps Structures Technics from GLPI
.DESCRIPTION
    Function to show Apps Structures Technics from GLPI. Function will show all Technics from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps Technic.
.PARAMETER AppsStructureComponentTechnicId
    Int parameter, you can provide here number of Apps Structure Technic. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentTechnic -All
    Example will show All Apps Structures Technics
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentTechnic -AppsStructureComponentTechnicId 2
    Example will show Apps Structure Technic which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentTechnic -AppsStructureComponentTechnicId 2 -Raw
    Example will show Apps Structure Technic which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentTechnic
    Example will show Apps Structure Technic which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentTechnic -Raw
    Example will show Apps Structure Technic which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>
function Get-GlpiToolsAppsStructuresComponentTechnic {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentTechnicId")]
        [alias('ASCTID')]
        [int[]]$AppsStructureComponentTechnicId
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

        $ComponentTechnicArray = [System.Collections.ArrayList]::new()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponentTechnic/?range=0-9999999999999"
                }
                
                $GlpiComponentTechnicAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentTechnic in $GlpiComponentTechnicAll) {
                    $ComponentTechnicHash = [ordered]@{ }
                    $ComponentTechnicProperties = $GlpiComponentTechnic.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentTechnicProp in $ComponentTechnicProperties) {
                        $ComponentTechnicHash.Add($ComponentTechnicProp.Name, $ComponentTechnicProp.Value)
                    }
                    $object = [pscustomobject]$ComponentTechnicHash
                    $ComponentTechnicArray.Add($object)
                }
                $ComponentTechnicArray
                $ComponentTechnicArray = [System.Collections.ArrayList]::new()
            }
            AppsStructureComponentTechnicId {
                foreach ($ASCTid in $AppsStructureComponentTechnicId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponentTechnic/$($ASCTid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentTechnicAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentTechnic in $GlpiComponentTechnicAll) {
                            $ComponentTechnicHash = [ordered]@{ }
                            $ComponentTechnicProperties = $GlpiComponentTechnic.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentTechnicProp in $ComponentTechnicProperties) {
                                $ComponentTechnicHash.Add($ComponentTechnicProp.Name, $ComponentTechnicProp.Value)
                            }
                            $object = [pscustomobject]$ComponentTechnicHash
                            $ComponentTechnicArray.Add($object)
                        }
                        $ComponentTechnicArray
                        $ComponentTechnicArray = [System.Collections.ArrayList]::new()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component Technic ID = $ASCTid is not found"
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