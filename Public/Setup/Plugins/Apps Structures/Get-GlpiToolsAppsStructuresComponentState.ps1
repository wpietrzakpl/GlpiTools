<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
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

        $ComponentStatesArray = @()
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
                    $ComponentStatesArray += $object 
                }
                $ComponentStatesArray
                $ComponentStatesArray = @()
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
                            $ComponentStatesArray += $object 
                        }
                        $ComponentStatesArray
                        $ComponentStatesArray = @()
                    
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