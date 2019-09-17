<#
.SYNOPSIS
    Function is getting Contact Types informations from GLPI
.DESCRIPTION
    Function is based on ContactTypeId which you can find in GLPI website
    Returns object with property's of Contact Types
.PARAMETER All
    This parameter will return all Contact Types from GLPI
.PARAMETER ContactTypeId
    This parameter can take pipline input, either, you can use this function with -ContactTypeId keyword.
    Provide to this param ContactTypeId from GLPI Contact Types Bookmark
.PARAMETER Raw
    Parameter which you can use with ContactTypeId Parameter.
    ContactTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ContactTypeName
    This parameter can take pipline input, either, you can use this function with -ContactTypeId keyword.
    Provide to this param Contact Types Name from GLPI Contact Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsContactTypes -All
    Example will return all Contact Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsContactTypes
    Function gets ContactTypeId from GLPI from Pipline, and return Contact Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsContactTypes
    Function gets ContactTypeId from GLPI from Pipline (u can pass many ID's like that), and return Contact Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsContactTypes -ContactTypeId 326
    Function gets ContactTypeId from GLPI which is provided through -ContactTypeId after Function type, and return Contact Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsContactTypes -ContactTypeId 326, 321
    Function gets Contact Types Id from GLPI which is provided through -ContactTypeId keyword after Function type (u can provide many ID's like that), and return Contact Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsContactTypes -ContactTypeName Fusion
    Example will return glpi Contact Types, but what is the most important, Contact Types will be shown exactly as you see in glpi dropdown Contact Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Contact Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Contact Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsContactTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ContactTypeId")]
        [alias('CTID')]
        [string[]]$ContactTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ContactTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ContactTypeName")]
        [alias('CTN')]
        [string]$ContactTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ContactTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/contacttype/?range=0-9999999999999"
                }
                
                $ContactTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ContactType in $ContactTypesAll) {
                    $ContactTypeHash = [ordered]@{ }
                    $ContactTypeProperties = $ContactType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ContactTypeProp in $ContactTypeProperties) {
                        $ContactTypeHash.Add($ContactTypeProp.Name, $ContactTypeProp.Value)
                    }
                    $object = [pscustomobject]$ContactTypeHash
                    $ContactTypesArray.Add($object)
                }
                $ContactTypesArray
                $ContactTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ContactTypeId { 
                foreach ( $CTId in $ContactTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/contacttype/$($CTId)"
                    }

                    Try {
                        $ContactType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ContactTypeHash = [ordered]@{ }
                            $ContactTypeProperties = $ContactType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContactTypeProp in $ContactTypeProperties) {
                                $ContactTypeHash.Add($ContactTypeProp.Name, $ContactTypeProp.Value)
                            }
                            $object = [pscustomobject]$ContactTypeHash
                            $ContactTypesArray.Add($object)
                        } else {
                            $ContactTypeHash = [ordered]@{ }
                            $ContactTypeProperties = $ContactType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContactTypeProp in $ContactTypeProperties) {

                                $ContactTypePropNewValue = Get-GlpiToolsParameters -Parameter $ContactTypeProp.Name -Value $ContactTypeProp.Value

                                $ContactTypeHash.Add($ContactTypeProp.Name, $ContactTypePropNewValue)
                            }
                            $object = [pscustomobject]$ContactTypeHash
                            $ContactTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Contact Type ID = $CTId is not found"
                        
                    }
                    $ContactTypesArray
                    $ContactTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ContactTypeName { 
                Search-GlpiToolsItems -SearchFor contacttype -SearchType contains -SearchValue $ContactTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}