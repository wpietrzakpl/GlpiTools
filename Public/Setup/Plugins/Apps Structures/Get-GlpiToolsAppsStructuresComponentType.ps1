<#
.SYNOPSIS
    Function to show Apps Structures Types from GLPI
.DESCRIPTION
    Function to show Apps Structures Types from GLPI. Function will show all Types from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps Type.
.PARAMETER AppsStructureComponentTypeId
    Int parameter, you can provide here number of Apps Structure Type. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentType -All
    Example will show All Apps Structures Types
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentType -AppsStructureComponentTypeId 2
    Example will show Apps Structure Type which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentType -AppsStructureComponentTypeId 2 -Raw
    Example will show Apps Structure Type which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentType
    Example will show Apps Structure Type which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentType -Raw
    Example will show Apps Structure Type which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
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

        $ComponentTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    $ComponentTypesArray.Add($object)
                }
                $ComponentTypesArray
                $ComponentTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                            $ComponentTypesArray.Add($object)
                        }
                        $ComponentTypesArray
                        $ComponentTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                    
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