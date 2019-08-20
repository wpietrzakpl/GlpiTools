<#
.SYNOPSIS
    Function to show Fusion Agents from GLPI
.DESCRIPTION
    Function to show Fusion Agents from GLPI. Function will show Agents, which are in GLPI, not on Fusions
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

        $InvocationCommand = $MyInvocation.MyCommand.Name

        if (Check-GlpiToolsPluginExist -InvocationCommand $InvocationCommand) {

        } else {
            throw "You don't have this plugin Enabled in GLPI"
        }

        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
    
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $AgentArray = [System.Collections.Generic.List[PSObject]]::New()
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
        $AllFusionAgents = Invoke-RestMethod @params

        foreach ($FusionAgent in $AllFusionAgents) {
            $FusionHash = [ordered]@{ }
                    $FusionProperties = $FusionAgent.PSObject.Properties | Select-Object -Property Name, Value 
                        
                    foreach ($FusionProp in $FusionProperties) {
                        $FusionHash.Add($FusionProp.Name, $FusionProp.Value)
                    }
                    $object = [pscustomobject]$FusionHash
                    $AgentArray.Add($object)
        }
        $AgentArray
        $AgentArray = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}
