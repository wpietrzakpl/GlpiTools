<#
.SYNOPSIS
    Function is getting Architectures informations from GLPI
.DESCRIPTION
    Function is based on OSArchitectureId which you can find in GLPI website
    Returns object with property's of Architectures Packs
.PARAMETER All
    This parameter will return all Architectures Packs from GLPI
.PARAMETER OSArchitectureId
    This parameter can take pipline input, either, you can use this function with -OSArchitectureId keyword.
    Provide to this param OSArchitectureId from GLPI Architectures Packs Bookmark
.PARAMETER Raw
    Parameter which you can use with OSArchitectureId Parameter.
    OSArchitectureId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER OSArchitectureName
    This parameter can take pipline input, either, you can use this function with -OSArchitectureId keyword.
    Provide to this param Architectures Packs Name from GLPI Architectures Packs Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSArchitectures -All
    Example will return all Architectures Packs from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsOSArchitectures
    Function gets OSArchitectureId from GLPI from Pipline, and return Architectures Packs object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsOSArchitectures
    Function gets OSArchitectureId from GLPI from Pipline (u can pass many ID's like that), and return Architectures Packs object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSArchitectures -OSArchitectureId 326
    Function gets OSArchitectureId from GLPI which is provided through -OSArchitectureId after Function type, and return Architectures Packs object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsOSArchitectures -OSArchitectureId 326, 321
    Function gets Architectures PacksId from GLPI which is provided through -OSArchitectureId keyword after Function type (u can provide many ID's like that), and return Architectures Packs object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsOSArchitectures -OSArchitectureName Fusion
    Example will return glpi Architectures Packs, but what is the most important, Architectures Packs will be shown exactly as you see in glpi dropdown Architectures Packs.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Architectures Packs ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Architectures Packs from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsOSArchitectures {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "OSArchitectureId")]
        [alias('OSAID')]
        [string[]]$OSArchitectureId,
        [parameter(Mandatory = $false,
            ParameterSetName = "OSArchitectureId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "OSArchitectureName")]
        [alias('OSAN')]
        [string]$OSArchitectureName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $OSArchitecturesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/operatingsystemarchitecture/?range=0-9999999999999"
                }
                
                $OSArchitectureAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($OSArchitecture in $OSArchitectureAll) {
                    $OSArchitectureHash = [ordered]@{ }
                    $OSArchitectureProperties = $OSArchitecture.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($OSArchitectureProp in $OSArchitectureProperties) {
                        $OSArchitectureHash.Add($OSArchitectureProp.Name, $OSArchitectureProp.Value)
                    }
                    $object = [pscustomobject]$OSArchitectureHash
                    $OSArchitecturesArray.Add($object)
                }
                $OSArchitecturesArray
                $OSArchitecturesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            OSArchitectureId { 
                foreach ( $OSAId in $OSArchitectureId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/operatingsystemarchitecture/$($OSAId)"
                    }

                    Try {
                        $OSArchitecture = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $OSArchitectureHash = [ordered]@{ }
                            $OSArchitectureProperties = $OSArchitecture.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSArchitectureProp in $OSArchitectureProperties) {
                                $OSArchitectureHash.Add($OSArchitectureProp.Name, $OSArchitectureProp.Value)
                            }
                            $object = [pscustomobject]$OSArchitectureHash
                            $OSArchitecturesArray.Add($object)
                        } else {
                            $OSArchitectureHash = [ordered]@{ }
                            $OSArchitectureProperties = $OSArchitecture.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($OSArchitectureProp in $OSArchitectureProperties) {

                                $OSArchitecturePropNewValue = Get-GlpiToolsParameters -Parameter $OSArchitectureProp.Name -Value $OSArchitectureProp.Value

                                $OSArchitectureHash.Add($OSArchitectureProp.Name, $OSArchitecturePropNewValue)
                            }
                            $object = [pscustomobject]$OSArchitectureHash
                            $OSArchitecturesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Architectures ID = $OSAId is not found"
                        
                    }
                    $OSArchitecturesArray
                    $OSArchitecturesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            OSArchitectureName { 
                Search-GlpiToolsItems -SearchFor Operatingsystemarchitecture -SearchType contains -SearchValue $OSArchitectureName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}