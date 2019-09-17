<#
.SYNOPSIS
    Function is getting Interface Hard Drive Types informations from GLPI
.DESCRIPTION
    Function is based on InterfaceHardDriveTypeId which you can find in GLPI website
    Returns object with property's of Interface Hard Drive Types
.PARAMETER All
    This parameter will return all Interface Hard Drive Types from GLPI
.PARAMETER InterfaceHardDriveTypeId
    This parameter can take pipline input, either, you can use this function with -InterfaceHardDriveTypeId keyword.
    Provide to this param InterfaceHardDriveTypeId from GLPI Interface Hard Drive Types Bookmark
.PARAMETER Raw
    Parameter which you can use with InterfaceHardDriveTypeId Parameter.
    InterfaceHardDriveTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER InterfaceHardDriveTypeName
    This parameter can take pipline input, either, you can use this function with -InterfaceHardDriveTypeId keyword.
    Provide to this param Interface Hard Drive Types Name from GLPI Interface Hard Drive Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsInterfaceHardDriveTypes -All
    Example will return all Interface Hard Drive Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsInterfaceHardDriveTypes
    Function gets InterfaceHardDriveTypeId from GLPI from Pipline, and return Interface Hard Drive Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsInterfaceHardDriveTypes
    Function gets InterfaceHardDriveTypeId from GLPI from Pipline (u can pass many ID's like that), and return Interface Hard Drive Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsInterfaceHardDriveTypes -InterfaceHardDriveTypeId 326
    Function gets InterfaceHardDriveTypeId from GLPI which is provided through -InterfaceHardDriveTypeId after Function type, and return Interface Hard Drive Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsInterfaceHardDriveTypes -InterfaceHardDriveTypeId 326, 321
    Function gets Interface Hard Drive Types Id from GLPI which is provided through -InterfaceHardDriveTypeId keyword after Function type (u can provide many ID's like that), and return Interface Hard Drive Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsInterfaceHardDriveTypes -InterfaceHardDriveTypeName Fusion
    Example will return glpi Interface Hard Drive Types, but what is the most important, Interface Hard Drive Types will be shown exactly as you see in glpi dropdown Interface Hard Drive Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Interface Hard Drive Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Interface Hard Drive Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsInterfaceHardDriveTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "InterfaceHardDriveTypeId")]
        [alias('IHDTID')]
        [string[]]$InterfaceHardDriveTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "InterfaceHardDriveTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "InterfaceHardDriveTypeName")]
        [alias('IHDTN')]
        [string]$InterfaceHardDriveTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $InterfaceHardDriveTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/interfacetype/?range=0-9999999999999"
                }
                
                $InterfaceHardDriveTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($InterfaceHardDriveType in $InterfaceHardDriveTypesAll) {
                    $InterfaceHardDriveTypeHash = [ordered]@{ }
                    $InterfaceHardDriveTypeProperties = $InterfaceHardDriveType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($InterfaceHardDriveTypeProp in $InterfaceHardDriveTypeProperties) {
                        $InterfaceHardDriveTypeHash.Add($InterfaceHardDriveTypeProp.Name, $InterfaceHardDriveTypeProp.Value)
                    }
                    $object = [pscustomobject]$InterfaceHardDriveTypeHash
                    $InterfaceHardDriveTypesArray.Add($object)
                }
                $InterfaceHardDriveTypesArray
                $InterfaceHardDriveTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            InterfaceHardDriveTypeId { 
                foreach ( $IHDTId in $InterfaceHardDriveTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/interfacetype/$($IHDTId)"
                    }

                    Try {
                        $InterfaceHardDriveType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $InterfaceHardDriveTypeHash = [ordered]@{ }
                            $InterfaceHardDriveTypeProperties = $InterfaceHardDriveType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($InterfaceHardDriveTypeProp in $InterfaceHardDriveTypeProperties) {
                                $InterfaceHardDriveTypeHash.Add($InterfaceHardDriveTypeProp.Name, $InterfaceHardDriveTypeProp.Value)
                            }
                            $object = [pscustomobject]$InterfaceHardDriveTypeHash
                            $InterfaceHardDriveTypesArray.Add($object)
                        } else {
                            $InterfaceHardDriveTypeHash = [ordered]@{ }
                            $InterfaceHardDriveTypeProperties = $InterfaceHardDriveType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($InterfaceHardDriveTypeProp in $InterfaceHardDriveTypeProperties) {

                                $InterfaceHardDriveTypePropNewValue = Get-GlpiToolsParameters -Parameter $InterfaceHardDriveTypeProp.Name -Value $InterfaceHardDriveTypeProp.Value

                                $InterfaceHardDriveTypeHash.Add($InterfaceHardDriveTypeProp.Name, $InterfaceHardDriveTypePropNewValue)
                            }
                            $object = [pscustomobject]$InterfaceHardDriveTypeHash
                            $InterfaceHardDriveTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Interface Hard Drive Type ID = $IHDTId is not found"
                        
                    }
                    $InterfaceHardDriveTypesArray
                    $InterfaceHardDriveTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            InterfaceHardDriveTypeName { 
                Search-GlpiToolsItems -SearchFor interfacetype -SearchType contains -SearchValue $InterfaceHardDriveTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}