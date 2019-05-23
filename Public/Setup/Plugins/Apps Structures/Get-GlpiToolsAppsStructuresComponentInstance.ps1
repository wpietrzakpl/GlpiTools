<#
.SYNOPSIS
    Function to show Apps Structures Instances from GLPI
.DESCRIPTION
    Function to show Apps Structures Instances from GLPI. Function will show all Instances from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps Instance.
.PARAMETER AppsStructureComponentInstanceId
    Int parameter, you can provide here number of Apps Structure Instance. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentInstance -All
    Example will show All Apps Structures Instances
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentInstance -AppsStructureComponentInstanceId 2
    Example will show Apps Structure Instance which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentInstance -AppsStructureComponentInstanceId 2 -Raw
    Example will show Apps Structure Instance which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentInstance
    Example will show Apps Structure Instance which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentInstance -Raw
    Example will show Apps Structure Instance which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsAppsStructuresComponentInstance {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentInstanceId")]
        [alias('ASCIID')]
        [int[]]$AppsStructureComponentInstanceId
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

        $ComponentInstanceArray = @()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponentInstance/?range=0-9999999999999"
                }
                
                $GlpiComponentInstanceAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentInstance in $GlpiComponentInstanceAll) {
                    $ComponentInstanceHash = [ordered]@{ }
                    $ComponentInstanceProperties = $GlpiComponentInstance.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentInstanceProp in $ComponentInstanceProperties) {
                        $ComponentInstanceHash.Add($ComponentInstanceProp.Name, $ComponentInstanceProp.Value)
                    }
                    $object = [pscustomobject]$ComponentInstanceHash
                    $ComponentInstanceArray += $object 
                }
                $ComponentInstanceArray
                $ComponentInstanceArray = @()
            }
            AppsStructureComponentInstanceId {
                foreach ($ASCIid in $AppsStructureComponentInstanceId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponentInstance/$($ASCIid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentInstanceAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentInstance in $GlpiComponentInstanceAll) {
                            $ComponentInstanceHash = [ordered]@{ }
                            $ComponentInstanceProperties = $GlpiComponentInstance.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentInstanceProp in $ComponentInstanceProperties) {
                                $ComponentInstanceHash.Add($ComponentInstanceProp.Name, $ComponentInstanceProp.Value)
                            }
                            $object = [pscustomobject]$ComponentInstanceHash
                            $ComponentInstanceArray += $object 
                        }
                        $ComponentInstanceArray
                        $ComponentInstanceArray = @()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component Instance ID = $ASCIid is not found"
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