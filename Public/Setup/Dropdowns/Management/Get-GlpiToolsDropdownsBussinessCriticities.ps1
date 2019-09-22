<#
.SYNOPSIS
    Function is getting Bussiness Criticities informations from GLPI
.DESCRIPTION
    Function is based on BussinessCriticityId which you can find in GLPI website
    Returns object with property's of Bussiness Criticities
.PARAMETER All
    This parameter will return all Bussiness Criticities from GLPI
.PARAMETER BussinessCriticityId
    This parameter can take pipeline input, either, you can use this function with -BussinessCriticityId keyword.
    Provide to this param BussinessCriticityId from GLPI Bussiness Criticities Bookmark
.PARAMETER Raw
    Parameter which you can use with BussinessCriticityId Parameter.
    BussinessCriticityId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER BussinessCriticityName
    This parameter can take pipeline input, either, you can use this function with -BussinessCriticityId keyword.
    Provide to this param Bussiness Criticities Name from GLPI Bussiness Criticities Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBussinessCriticities -All
    Example will return all Bussiness Criticities from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsBussinessCriticities
    Function gets BussinessCriticityId from GLPI from pipeline, and return Bussiness Criticities object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsBussinessCriticities
    Function gets BussinessCriticityId from GLPI from pipeline (u can pass many ID's like that), and return Bussiness Criticities object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBussinessCriticities -BussinessCriticityId 326
    Function gets BussinessCriticityId from GLPI which is provided through -BussinessCriticityId after Function type, and return Bussiness Criticities object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsBussinessCriticities -BussinessCriticityId 326, 321
    Function gets Bussiness Criticities Id from GLPI which is provided through -BussinessCriticityId keyword after Function type (u can provide many ID's like that), and return Bussiness Criticities object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsBussinessCriticities -BussinessCriticityName Fusion
    Example will return glpi Bussiness Criticities, but what is the most important, Bussiness Criticities will be shown exactly as you see in glpi dropdown Bussiness Criticities.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Bussiness Criticities ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Bussiness Criticities from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsBussinessCriticities {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "BussinessCriticityId")]
        [alias('BCID')]
        [string[]]$BussinessCriticityId,
        [parameter(Mandatory = $false,
            ParameterSetName = "BussinessCriticityId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "BussinessCriticityName")]
        [alias('BCN')]
        [string]$BussinessCriticityName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $BussinessCriticitiesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/businesscriticity/?range=0-9999999999999"
                }
                
                $BussinessCriticitiesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($BussinessCriticity in $BussinessCriticitiesAll) {
                    $BussinessCriticityHash = [ordered]@{ }
                    $BussinessCriticityProperties = $BussinessCriticity.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($BussinessCriticityProp in $BussinessCriticityProperties) {
                        $BussinessCriticityHash.Add($BussinessCriticityProp.Name, $BussinessCriticityProp.Value)
                    }
                    $object = [pscustomobject]$BussinessCriticityHash
                    $BussinessCriticitiesArray.Add($object)
                }
                $BussinessCriticitiesArray
                $BussinessCriticitiesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            BussinessCriticityId { 
                foreach ( $BCId in $BussinessCriticityId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/businesscriticity/$($BCId)"
                    }

                    Try {
                        $BussinessCriticity = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $BussinessCriticityHash = [ordered]@{ }
                            $BussinessCriticityProperties = $BussinessCriticity.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($BussinessCriticityProp in $BussinessCriticityProperties) {
                                $BussinessCriticityHash.Add($BussinessCriticityProp.Name, $BussinessCriticityProp.Value)
                            }
                            $object = [pscustomobject]$BussinessCriticityHash
                            $BussinessCriticitiesArray.Add($object)
                        } else {
                            $BussinessCriticityHash = [ordered]@{ }
                            $BussinessCriticityProperties = $BussinessCriticity.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($BussinessCriticityProp in $BussinessCriticityProperties) {

                                $BussinessCriticityPropNewValue = Get-GlpiToolsParameters -Parameter $BussinessCriticityProp.Name -Value $BussinessCriticityProp.Value

                                $BussinessCriticityHash.Add($BussinessCriticityProp.Name, $BussinessCriticityPropNewValue)
                            }
                            $object = [pscustomobject]$BussinessCriticityHash
                            $BussinessCriticitiesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Bussiness Criticity ID = $BCId is not found"
                        
                    }
                    $BussinessCriticitiesArray
                    $BussinessCriticitiesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            BussinessCriticityName { 
                Search-GlpiToolsItems -SearchFor businesscriticity -SearchType contains -SearchValue $BussinessCriticityName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}