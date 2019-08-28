<#
.SYNOPSIS
    Function is getting OS Editions informations from GLPI
.DESCRIPTION
    Function is based on OSEditionId which you can find in GLPI website
    Returns object with property's of OS Editions
.PARAMETER All
    This parameter will return all OS Editions from GLPI
.PARAMETER OSEditionId
    This parameter can take pipline input, either, you can use this function with -OSEditionId keyword.
    Provide to this param OSEditionId from GLPI OS Editions Bookmark
.PARAMETER Raw
    Parameter which you can use with OSEditionId Parameter.
    OSEditionId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OSEditionName
    This parameter can take pipline input, either, you can use this function with -OSEditionId keyword.
    Provide to this param OS Editions Name from GLPI OS Editions Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSEditions -All
    Example will return all OS Editions from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOSEditions
    Function gets OSEditionId from GLPI from Pipline, and return OS Editions object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOSEditions
    Function gets OSEditionId from GLPI from Pipline (u can pass many ID's like that), and return OS Editions object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSEditions -OSEditionId 326
    Function gets OSEditionId from GLPI which is provided through -OSEditionId after Function type, and return OS Editions object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOSEditions -OSEditionId 326, 321
    Function gets OS EditionsId from GLPI which is provided through -OSEditionId keyword after Function type (u can provide many ID's like that), and return OS Editions object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSEditions -OSEditionName Fusion
    Example will return glpi OS Editions, but what is the most important, OS Editions will be shown exactly as you see in glpi dropdown OS Editions.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    OS Editions ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of OS Editions from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsOSEditions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OSEditionId")]
        [alias('OSEID')]
        [string[]]$OSEditionId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OSEditionId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OSEditionName")]
        [alias('OSEN')]
        [string]$OSEditionName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OSEditionsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/operatingsystemedition/?range=0-9999999999999"
                }
                
                $OSEditionsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OSEdition in $OSEditionsAll) {
                    $OSEditionHash = [ordered]@{ }
                    $OSEditionProperties = $OSEdition.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OSEditionProp in $OSEditionProperties) {
                        $OSEditionHash.Add($OSEditionProp.Name, $OSEditionProp.Value)
                    }
                    $object = [pscustomobject]$OSEditionHash
                    $OSEditionsArray.Add($object)
                }
                $OSEditionsArray
                $OSEditionsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OSEditionId { 
                foreach ( $OSEId in $OSEditionId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/operatingsystemedition/$($OSEId)"
                    }

                    Try {
                        $OSEdition = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OSEditionHash = [ordered]@{ }
                            $OSEditionProperties = $OSEdition.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSEditionProp in $OSEditionProperties) {
                                $OSEditionHash.Add($OSEditionProp.Name, $OSEditionProp.Value)
                            }
                            $object = [pscustomobject]$OSEditionHash
                            $OSEditionsArray.Add($object)
                        } else {
                            $OSEditionHash = [ordered]@{ }
                            $OSEditionProperties = $OSEdition.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSEditionProp in $OSEditionProperties) {

                                $OSEditionPropNewValue = Get-GlpiToolsParameters -Parameter $OSEditionProp.Name -Value $OSEditionProp.Value

                                $OSEditionHash.Add($OSEditionProp.Name, $OSEditionPropNewValue)
                            }
                            $object = [pscustomobject]$OSEditionHash
                            $OSEditionsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "OS Edition ID = $OSEId is not found"
                        
                    }
                    $OSEditionsArray
                    $OSEditionsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OSEditionName { 
                Search-GlpiToolsItems -SearchFor Operatingsystemedition -SearchType contains -SearchValue $OSEditionName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}