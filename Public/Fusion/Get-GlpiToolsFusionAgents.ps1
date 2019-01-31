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

function Get-GlpiToolsFusionAgents {
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
            $Id = $fusion | Select-Object -ExpandProperty id
            $EntitiesId = $fusion | Select-Object -ExpandProperty entities_id
            $IsRecursive = $fusion | Select-Object -ExpandProperty is_recursive
            $Name = $fusion | Select-Object -ExpandProperty name
            $LastContact = $fusion | Select-Object -ExpandProperty last_contact 
            $Version = $fusion | Select-Object -ExpandProperty version
            $Lock = $fusion | Select-Object -ExpandProperty lock
            $DeviceId = $fusion | Select-Object -ExpandProperty device_id
            $ComputersId = $fusion | Select-Object -ExpandProperty computers_id
            $Token = $fusion | Select-Object -ExpandProperty token
            $UserAgent = $fusion | Select-Object -ExpandProperty useragent
            $Tag = $fusion | Select-Object -ExpandProperty tag
            $ThreadsNetworkDiscovery = $fusion | Select-Object -ExpandProperty threads_networkdiscovery
            $ThreadsNetworkInventory = $fusion | Select-Object -ExpandProperty threads_networkinventory
            $Senddico = $fusion | Select-Object -ExpandProperty senddico
            $TimeoutNetworkDiscovery = $fusion | Select-Object -ExpandProperty timeout_networkdiscovery
            $TimeoutNetworkInventory = $fusion | Select-Object -ExpandProperty timeout_networkinventory
            $AgentPort = $fusion | Select-Object -ExpandProperty agent_port

            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
            $object | Add-Member -Name 'EntitiesId' -MemberType NoteProperty -Value $EntitiesId
            $object | Add-Member -Name 'IsRecursive' -MemberType NoteProperty -Value $IsRecursive
            $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value $Name
            $object | Add-Member -Name 'LastContact' -MemberType NoteProperty -Value $LastContact
            $object | Add-Member -Name 'Version' -MemberType NoteProperty -Value $Version
            $object | Add-Member -Name 'Lock' -MemberType NoteProperty -Value $Lock
            $object | Add-Member -Name 'DeviceId' -MemberType NoteProperty -Value $DeviceId
            $object | Add-Member -Name 'ComputersId' -MemberType NoteProperty -Value $ComputersId
            $object | Add-Member -Name 'Token' -MemberType NoteProperty -Value $Token
            $object | Add-Member -Name 'UserAgent' -MemberType NoteProperty -Value $UserAgent
            $object | Add-Member -Name 'Tag' -MemberType NoteProperty -Value $Tag
            $object | Add-Member -Name 'ThreadsNetworkDiscovery' -MemberType NoteProperty -Value $ThreadsNetworkDiscovery
            $object | Add-Member -Name 'ThreadsNetworkInventory' -MemberType NoteProperty -Value $ThreadsNetworkInventory
            $object | Add-Member -Name 'Senddico' -MemberType NoteProperty -Value $Senddico
            $object | Add-Member -Name 'TimeoutNetworkDiscovery' -MemberType NoteProperty -Value $TimeoutNetworkDiscovery
            $object | Add-Member -Name 'TimeoutNetworkInventory' -MemberType NoteProperty -Value $TimeoutNetworkInventory
            $object | Add-Member -Name 'AgentPort' -MemberType NoteProperty -Value $AgentPort
            $AgentArray += $object 
        }
        $AgentArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}
