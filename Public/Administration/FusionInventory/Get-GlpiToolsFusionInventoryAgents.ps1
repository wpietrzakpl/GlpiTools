<#
.SYNOPSIS
    Function to show Fusion Agents from GLPI
.DESCRIPTION
    Function to show Fusion Agents from GLPI. Function will show Agents, which are in GLPI, not on Computers
.EXAMPLE
    PS C:\> Get-GlpiToolsFusionAgents
    Function will show all agents which are available in GLPI
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 01/2019
#>

function Get-GlpiToolsFusionInventoryAgents {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
    
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $AgentArray = @()
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/PluginFusioninventoryAgent/?range=0-999999999" 
        }
        $FusionAgents = Invoke-RestMethod @params

        foreach ($fusion in $FusionAgents) {
            $FusionHash = [ordered]@{
                'Id' = $fusion.id
                'EntitiesId' = $fusion.entities_id
                'IsRecursive' = $fusion.is_recursive
                'Name' = $fusion.name
                'LastContact' = $fusion.last_contact 
                'Version' = $fusion.version
                'Lock' = $fusion.lock
                'DeviceId' = $fusion.device_id
                'ComputersId' = $fusion.computers_id
                'Token' = $fusion.token
                'UserAgent' = $fusion.useragent
                'Tag' = $fusion.tag
                'ThreadsNetworkDiscovery' = $fusion.threads_networkdiscovery
                'ThreadsNetworkInventory' = $fusion.threads_networkinventory
                'Senddico' = $fusion.senddico
                'TimeoutNetworkDiscovery' = $fusion.timeout_networkdiscovery
                'TimeoutNetworkInventory' = $fusion.timeout_networkinventory
                'AgentPort' = $fusion.agent_port
            }
            $object = New-Object -TypeName PSCustomObject -Property $FusionHash
            $AgentArray += $object 
        }
        $AgentArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}
