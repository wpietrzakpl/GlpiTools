<#
.SYNOPSIS
    Function gets statuses of items
.DESCRIPTION
    Function gets statuses of items which can be defined in dropowns
.PARAMETER All
    This parameter will return all States from GLPI
.PARAMETER StatesId
    This parameter can take pipline input, either, you can use this function with -StatesId keyword.
    Provide to this param States ID from GLPI Statuses of items Bookmark
.PARAMETER Raw
    Parameter which you can use with StatesId Parameter.
    StatesId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER StatesName
    Provide to this param States Name from GLPI States Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatusesOfItems -All
    Example will return all States from States. 
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsStatusesOfItems
    Function gets StatesID from GLPI from Pipline, and return States object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsStatusesOfItems
    Function gets StatesID from GLPI from Pipline (u can pass many ID's like that), and return States object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatusesOfItems -StatesId 326
    Function gets StatesID from GLPI which is provided through -StatesId after Function type, and return States object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsStatusesOfItems -StatesId 326, 321
    Function gets StatesID from GLPI which is provided through -StatesId keyword after Function type (u can provide many ID's like that), and return States object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatusesOfItems -StatesId 234 -Raw
    Example will show States with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsDropdownsStatusesOfItems -Raw
    Example will show States with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatusesOfItems -StatesName glpi
    Example will return glpi States, but what is the most important, States will be shown exactly as you see in glpi Statuses of items tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    StateId, StateName
.OUTPUTS
    Function returns PSCustomObject with statuses of items from GLPI 
.NOTES
    PSP 01/2019
#>

function Get-GlpiToolsDropdownsStatusesOfItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "StatesId")]
        [alias('SID')]
        [string[]]$StatesId,
        [parameter(Mandatory = $false,
            ParameterSetName = "StatesId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "StatesName")]
        [alias('SN')]
        [string]$StatesName
    )
    
    begin {

        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $StatesArray = [System.Collections.ArrayList]::new()
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
                    uri     = "$($PathToGlpi)/State/?range=0-9999999999999"
                }
                
                $GlpiStatesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiStates in $GlpiStatesAll) {
                    $StatesHash = [ordered]@{ }
                            $StatesProperties = $GlpiStates.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($StatesProp in $StatesProperties) {
                                $StatesHash.Add($StatesProp.Name, $StatesProp.Value)
                            }
                            $object = [pscustomobject]$StatesHash
                            $StatesArray.Add($object)
                }
                $StatesArray
                $StatesArray = [System.Collections.ArrayList]::new()
            }
            StatesId {
                foreach ( $SId in $StatesId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/State/$($SId)"
                    }

                    Try {
                        $GlpiStates = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $StatesHash = [ordered]@{ }
                            $StatesProperties = $GlpiStates.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($StatesProp in $StatesProperties) {
                                $StatesHash.Add($StatesProp.Name, $StatesProp.Value)
                            }
                            $object = [pscustomobject]$StatesHash
                            $StatesArray.Add($object)
                        } else {
                            $StatesHash = [ordered]@{ }
                            $StatesProperties = $GlpiStates.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($StatesProp in $StatesProperties) {

                                switch ($StatesProp.Name) {
                                    entities_id { $StatesPropNewValue = $StatesProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    Default {
                                        $StatesPropNewValue = $StatesProp.Value
                                    }
                                }

                                $StatesHash.Add($StatesProp.Name, $StatesPropNewValue)
                            }
                            $object = [pscustomobject]$StatesHash
                            $StatesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "State ID = $SId is not found"
                        
                    }
                    $StatesArray
                    $StatesArray = [System.Collections.ArrayList]::new()
                }
            }
            StatesName {
                Search-GlpiToolsItems -SearchFor State -SearchType contains -SearchValue $StatesName
            }
            Default {}
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}