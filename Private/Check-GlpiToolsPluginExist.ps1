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
    PSP 04/2019
#>

function Check-GlpiToolsPluginExist {
    [CmdletBinding()]
    param (
        
    )
    
    begin {

        $GlpiAvailablePlugins = Get-GlpiToolsPlugins | Where-Object {$_.State -eq "Enabled"}

    }
    
    process {
    }
    
    end {
        
    }
}