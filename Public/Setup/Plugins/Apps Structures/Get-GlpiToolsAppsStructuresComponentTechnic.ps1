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

        $ComponentTechnicArray = @()
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
                    $ComponentTechnicArray += $object 
                }
                $ComponentTechnicArray
                $ComponentTechnicArray = @()
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
                            $ComponentTechnicArray += $object 
                        }
                        $ComponentTechnicArray
                        $ComponentTechnicArray = @()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component State ID = $ASCTid is not found"
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