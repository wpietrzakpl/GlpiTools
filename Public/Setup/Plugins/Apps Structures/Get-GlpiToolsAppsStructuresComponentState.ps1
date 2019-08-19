<#
.SYNOPSIS
    Function to show Apps Structures States from GLPI
.DESCRIPTION
    Function to show Apps Structures States from GLPI. Function will show all States from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps State.
.PARAMETER AppsStructureComponentStateId
    Int parameter, you can provide here number of Apps Structure State. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentState -All
    Example will show All Apps Structures States
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentState -AppsStructureComponentStateId 2
    Example will show Apps Structure State which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentState -AppsStructureComponentStateId 2 -Raw
    Example will show Apps Structure State which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentState
    Example will show Apps Structure State which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentState -Raw
    Example will show Apps Structure State which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsAppsStructuresComponentState {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentStateId")]
        [alias('ASCSID')]
        [int[]]$AppsStructureComponentStateId
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

        $ComponentStatesArray = [System.Collections.ArrayList]::new()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponentState/?range=0-9999999999999"
                }
                
                $GlpiComponentStateAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentState in $GlpiComponentStateAll) {
                    $ComponentStateHash = [ordered]@{ }
                    $ComponentStateProperties = $GlpiComponentState.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentStateProp in $ComponentStateProperties) {
                        $ComponentStateHash.Add($ComponentStateProp.Name, $ComponentStateProp.Value)
                    }
                    $object = [pscustomobject]$ComponentStateHash
                    $ComponentStatesArray.Add($object)
                }
                $ComponentStatesArray
                $ComponentStatesArray = [System.Collections.ArrayList]::new()
            }
            AppsStructureComponentStateId {
                foreach ($ASCSid in $AppsStructureComponentStateId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponentState/$($ASCSid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentStateAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentState in $GlpiComponentStateAll) {
                            $ComponentStateHash = [ordered]@{ }
                            $ComponentStateProperties = $GlpiComponentState.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentStateProp in $ComponentStateProperties) {
                                $ComponentStateHash.Add($ComponentStateProp.Name, $ComponentStateProp.Value)
                            }
                            $object = [pscustomobject]$ComponentStateHash
                            $ComponentStatesArray.Add($object)
                        }
                        $ComponentStatesArray
                        $ComponentStatesArray = [System.Collections.ArrayList]::new()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component State ID = $ASCSid is not found"
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