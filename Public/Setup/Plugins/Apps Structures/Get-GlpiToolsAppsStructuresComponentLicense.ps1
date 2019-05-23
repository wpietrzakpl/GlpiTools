<#
.SYNOPSIS
    Function to show Apps Structures Licenses from GLPI
.DESCRIPTION
    Function to show Apps Structures Licenses from GLPI. Function will show all Licenses from Apps Structures.
.PARAMETER All
    Switch parameter, if you will choose, you will get All available Apps License.
.PARAMETER AppsStructureComponentLicenseId
    Int parameter, you can provide here number of Apps Structure License. It is ID which you can find in GLPI or with parameter -All.
    Can take pipeline input.
.PARAMETER Raw
    Switch parameter. In default output has converted id to humanreadable format, that parameter can disable it and return raw object with id's.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentLicense -All
    Example will show All Apps Structures Licenses
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentLicense -AppsStructureComponentLicenseId 2
    Example will show Apps Structure License which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> Get-GlpiToolsAppsStructuresComponentLicense -AppsStructureComponentLicenseId 2 -Raw
    Example will show Apps Structure License which id is 2. Object will not have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentLicense
    Example will show Apps Structure License which id is 2. Object will have converted values.
.EXAMPLE
    PS C:\> 2 | Get-GlpiToolsAppsStructuresComponentLicense -Raw
    Example will show Apps Structure License which id is 2. Object will not have converted values.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Function returns PSCustomObject
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsAppsStructuresComponentLicense {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ParameterSetName = "AppsStructureComponentLicenseId")]
        [alias('ASCLID')]
        [int[]]$AppsStructureComponentLicenseId
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

        $ComponentLicenseArray = @()
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
                    uri     = "$($PathToGlpi)/PluginArchiswSwcomponentLicense/?range=0-9999999999999"
                }
                
                $GlpiComponentLicenseAll = Invoke-RestMethod @params -Verbose:$false
        
                foreach ($GlpiComponentLicense in $GlpiComponentLicenseAll) {
                    $ComponentLicenseHash = [ordered]@{ }
                    $ComponentLicenseProperties = $GlpiComponentLicense.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComponentLicenseProp in $ComponentLicenseProperties) {
                        $ComponentLicenseHash.Add($ComponentLicenseProp.Name, $ComponentLicenseProp.Value)
                    }
                    $object = [pscustomobject]$ComponentLicenseHash
                    $ComponentLicenseArray += $object 
                }
                $ComponentLicenseArray
                $ComponentLicenseArray = @()
            }
            AppsStructureComponentLicenseId {
                foreach ($ASCLid in $AppsStructureComponentLicenseId) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/PluginArchiswSwcomponentLicense/$($ASCLid)/?range=0-9999999999999"
                    }
                    
                    try {
                        $GlpiComponentLicenseAll = Invoke-RestMethod @params -Verbose:$false
            
                        foreach ($GlpiComponentLicense in $GlpiComponentLicenseAll) {
                            $ComponentLicenseHash = [ordered]@{ }
                            $ComponentLicenseProperties = $GlpiComponentLicense.PSObject.Properties | Select-Object -Property Name, Value 
                                        
                            foreach ($ComponentLicenseProp in $ComponentLicenseProperties) {
                                $ComponentLicenseHash.Add($ComponentLicenseProp.Name, $ComponentLicenseProp.Value)
                            }
                            $object = [pscustomobject]$ComponentLicenseHash
                            $ComponentLicenseArray += $object 
                        }
                        $ComponentLicenseArray
                        $ComponentLicenseArray = @()
                    
                    }
                    catch {
                        Write-Verbose -Message "Component License ID = $ASCLid is not found"
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