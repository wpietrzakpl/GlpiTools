<#
.SYNOPSIS
    Function to show Apps Structures Components from GLPI
.DESCRIPTION
    Function to show Apps Structures Components from GLPI. Function will show all Components from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps Component.
.PARAMETER AppsStructureId
    Int parameter, you can provide here number of Apps Structure. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> GlpiToolsAppsStructuresComponent -All
    Example will show All Apps Structures Items
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponent -AppsStructureId 2
    Example will show Apps Structure Item which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponent -AppsStructureId 2 -Raw
    Example will show Apps Structure Item which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponent
    Example will show Apps Structure Item which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponent -Raw
    Example will show Apps Structure Item which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsAppsStructuresComponent {
    [CmdletBinding()]
    param (

        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureId")]
        [alias('ASID')]
        [int[]]$AppsStructureId,
        [parameter(Mandatory = $false,
            ParameterSetName = "AppsStructureId")]
        [switch]$Raw
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

        $ComponentArray = @()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponent/?range=0-999999999" 
                }
                $AllComponents = Invoke-RestMethod @params
 
                foreach ($Component in $AllComponents) {
                    $Hash = [ordered]@{ }
                    $Properties = $Component.PSObject.Properties | Select-Object -Property Name, Value 
                                    
                    foreach ($Prop in $Properties) {
                        $Hash.Add($Prop.Name, $Prop.Value)
                    }
                    $object = [pscustomobject]$Hash
                    $ComponentArray += $object 
                }
                $ComponentArray
                $ComponentArray = @()
            }
            AppsStructureId {
                foreach ( $ASId in $AppsStructureId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponent/$($ASId)"
                    }

                    Try {
                        $GlpiComponent = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ComponentHash = [ordered]@{ }
                            $ComponentProperties = $GlpiComponent.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComponentProp in $ComponentProperties) {
                                $ComponentHash.Add($ComponentProp.Name, $ComponentProp.Value)
                            }
                            $object = [pscustomobject]$ComponentHash
                            $ComponentArray += $object 
                        } else {
                            $ComponentHash = [ordered]@{ }
                            $ComponentProperties = $GlpiComponent.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComponentProp in $ComponentProperties) {

                                switch ($ComponentProp.Name) {
                                    entities_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } }
                                    groups_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsGroups | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponenttargets_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentTarget | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponenttypes_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentType | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponentstates_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentState | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponenttechnics_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentTechnic | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponentusers_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentUser | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponentslas_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentSla | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponentdbs_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentDb | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponentinstances_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentInstance | Select-Object -ExpandProperty Name }
                                    plugin_archisw_swcomponentlicenses_id { $ComponentPropNewValue = $ComponentProp.Value | Get-GlpiToolsAppsStructuresComponentLicense | Select-Object -ExpandProperty Name }
                                    Default {
                                        $ComponentPropNewValue = $ComponentProp.Value
                                    }
                                }
                                
                                $ComponentHash.Add($ComponentProp.Name, $ComponentPropNewValue)
                            }
                            $object = [pscustomobject]$ComponentHash
                            $ComponentArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "Component ID = $ASId is not found"
                        
                    }
                    $ComponentArray
                    $ComponentArray = @()
                }
            }
            Default {

            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}