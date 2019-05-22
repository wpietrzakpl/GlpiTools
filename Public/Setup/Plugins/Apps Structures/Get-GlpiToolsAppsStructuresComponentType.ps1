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

function Get-GlpiToolsAppsStructuresComponentType {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentTypeId")]
        [alias('ASCTID')]
        [int[]]$AppsStructureComponentTypeId
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

        $ComponentTypesArray = @()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponentType/?range=0-9999999999999"
                }
                
                $GlpiComponentTypeAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentType in $GlpiComponentTypeAll) {
                    $ComponentTypeHash = [ordered]@{ }
                    $ComponentTypeProperties = $GlpiComponentType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentTypeProp in $ComponentTypeProperties) {
                        $ComponentTypeHash.Add($ComponentTypeProp.Name, $ComponentTypeProp.Value)
                    }
                    $object = [pscustomobject]$ComponentTypeHash
                    $ComponentTypesArray += $object 
                }
                $ComponentTypesArray
                $ComponentTypesArray = @()
            }
            AppsStructureComponentTypeId {
                foreach ($ASCTid in $AppsStructureComponentTypeId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponentType/$($ASCTid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentTypeAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentType in $GlpiComponentTypeAll) {
                            $ComponentTypeHash = [ordered]@{ }
                            $ComponentTypeProperties = $GlpiComponentType.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentTypeProp in $ComponentTypeProperties) {
                                $ComponentTypeHash.Add($ComponentTypeProp.Name, $ComponentTypeProp.Value)
                            }
                            $object = [pscustomobject]$ComponentTypeHash
                            $ComponentTypesArray += $object 
                        }
                        $ComponentTypesArray
                        $ComponentTypesArray = @()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component Type ID = $ASCTid is not found"
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