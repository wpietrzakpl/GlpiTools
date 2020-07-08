<#
.SYNOPSIS
    Function is getting Line Types informations from GLPI
.DESCRIPTION
    Function is based on LineTypeId which you can find in GLPI website
    Returns object with property's of Line Types
.PARAMETER All
    This parameter will return all Line Types from GLPI
.PARAMETER LineTypeId
    This parameter can take pipline input, either, you can use this function with -LineTypeId keyword.
    Provide to this param LineTypeId from GLPI Line Types Bookmark
.PARAMETER Raw
    Parameter which you can use with LineTypeId Parameter.
    LineTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER LineTypeName
    This parameter can take pipline input, either, you can use this function with -LineTypeId keyword.
    Provide to this param Line Types Name from GLPI Line Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLineTypes -All
    Example will return all Line Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsLineTypes
    Function gets LineTypeId from GLPI from Pipline, and return Line Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsLineTypes
    Function gets LineTypeId from GLPI from Pipline (u can pass many ID's like that), and return Line Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLineTypes -LineTypeId 326
    Function gets LineTypeId from GLPI which is provided through -LineTypeId after Function type, and return Line Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsLineTypes -LineTypeId 326, 321
    Function gets Line Types Id from GLPI which is provided through -LineTypeId keyword after Function type (u can provide many ID's like that), and return Line Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsLineTypes -LineTypeName Fusion
    Example will return glpi Line Types, but what is the most important, Line Types will be shown exactly as you see in glpi dropdown Line Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Line Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Line Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsLineTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "LineTypeId")]
        [alias('LTID')]
        [string[]]$LineTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "LineTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "LineTypeName")]
        [alias('LTN')]
        [string]$LineTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $LineTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Linetype/?range=0-9999999999999"
                }
                
                $LineTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($LineType in $LineTypesAll) {
                    $LineTypeHash = [ordered]@{ }
                    $LineTypeProperties = $LineType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($LineTypeProp in $LineTypeProperties) {
                        $LineTypeHash.Add($LineTypeProp.Name, $LineTypeProp.Value)
                    }
                    $object = [pscustomobject]$LineTypeHash
                    $LineTypesArray.Add($object)
                }
                $LineTypesArray
                $LineTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            LineTypeId { 
                foreach ( $LTId in $LineTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Linetype/$($LTId)"
                    }

                    Try {
                        $LineType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $LineTypeHash = [ordered]@{ }
                            $LineTypeProperties = $LineType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($LineTypeProp in $LineTypeProperties) {
                                $LineTypeHash.Add($LineTypeProp.Name, $LineTypeProp.Value)
                            }
                            $object = [pscustomobject]$LineTypeHash
                            $LineTypesArray.Add($object)
                        } else {
                            $LineTypeHash = [ordered]@{ }
                            $LineTypeProperties = $LineType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($LineTypeProp in $LineTypeProperties) {

                                $LineTypePropNewValue = Get-GlpiToolsParameters -Parameter $LineTypeProp.Name -Value $LineTypeProp.Value

                                $LineTypeHash.Add($LineTypeProp.Name, $LineTypePropNewValue)
                            }
                            $object = [pscustomobject]$LineTypeHash
                            $LineTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Line Type ID = $LTId is not found"
                        
                    }
                    $LineTypesArray
                    $LineTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            LineTypeName { 
                Search-GlpiToolsItems -SearchFor Linetype -SearchType contains -SearchValue $LineTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}