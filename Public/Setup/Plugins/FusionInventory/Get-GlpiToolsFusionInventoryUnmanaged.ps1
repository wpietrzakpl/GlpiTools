<#
.SYNOPSIS
    Function to show Fusion Unmanaged Devices from GLPI
.DESCRIPTION
    Function to show Fusion Unmanaged Devices from GLPI. Function will show Unmanaged Devices, which are in GLPI, not on Fusions
.EXAMPLE
    PS C:\> Get-GlpiToolsFusionUnmanaged Devices
    Function will show all Unmanaged Devices which are available in GLPI
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 01/2019
#>

function Get-GlpiToolsFusionInventoryUnmanaged {
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

        $UnmanagedArray = @()
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/PluginFusioninventoryUnmanaged/?range=0-999999999" 
        }
        $AllFusionUnmanaged = Invoke-RestMethod @params

        foreach ($FusionUnmanaged in $AllFusionUnmanaged) {
            $FusionHash = [ordered]@{ }
                    $FusionProperties = $FusionUnmanaged.PSObject.Properties | Select-Object -Property Name, Value 
                        
                    foreach ($FusionProp in $FusionProperties) {
                        $FusionHash.Add($FusionProp.Name, $FusionProp.Value)
                    }
                    $object = [pscustomobject]$FusionHash
                    $UnmanagedArray += $object 
        }
        $UnmanagedArray
        $UnmanagedArray = @()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}
