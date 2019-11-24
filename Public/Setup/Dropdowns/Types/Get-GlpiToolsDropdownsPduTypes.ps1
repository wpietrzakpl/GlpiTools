<#
.SYNOPSIS
    Function is getting Pdu Types informations from GLPI
.DESCRIPTION
    Function is based on PduTypeId which you can find in GLPI website
    Returns object with property's of Pdu Types
.PARAMETER All
    This parameter will return all Pdu Types from GLPI
.PARAMETER PduTypeId
    This parameter can take pipline input, either, you can use this function with -PduTypeId keyword.
    Provide to this param PduTypeId from GLPI Pdu Types Bookmark
.PARAMETER Raw
    Parameter which you can use with PduTypeId Parameter.
    PduTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PduTypeName
    This parameter can take pipline input, either, you can use this function with -PduTypeId keyword.
    Provide to this param Pdu Types Name from GLPI Pdu Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPduTypes -All
    Example will return all Pdu Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsPduTypes
    Function gets PduTypeId from GLPI from Pipline, and return Pdu Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsPduTypes
    Function gets PduTypeId from GLPI from Pipline (u can pass many ID's like that), and return Pdu Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPduTypes -PduTypeId 326
    Function gets PduTypeId from GLPI which is provided through -PduTypeId after Function type, and return Pdu Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsPduTypes -PduTypeId 326, 321
    Function gets Pdu Types Id from GLPI which is provided through -PduTypeId keyword after Function type (u can provide many ID's like that), and return Pdu Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsPduTypes -PduTypeName Fusion
    Example will return glpi Pdu Types, but what is the most important, Pdu Types will be shown exactly as you see in glpi dropdown Pdu Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Pdu Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Pdu Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsPduTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PduTypeId")]
        [alias('PTID')]
        [string[]]$PduTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PduTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "PduTypeName")]
        [alias('PTN')]
        [string]$PduTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PduTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/pdutype/?range=0-9999999999999"
                }
                
                $PduTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($PduType in $PduTypesAll) {
                    $PduTypeHash = [ordered]@{ }
                    $PduTypeProperties = $PduType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($PduTypeProp in $PduTypeProperties) {
                        $PduTypeHash.Add($PduTypeProp.Name, $PduTypeProp.Value)
                    }
                    $object = [pscustomobject]$PduTypeHash
                    $PduTypesArray.Add($object)
                }
                $PduTypesArray
                $PduTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PduTypeId { 
                foreach ( $PTId in $PduTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/pdutype/$($PTId)"
                    }

                    Try {
                        $PduType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PduTypeHash = [ordered]@{ }
                            $PduTypeProperties = $PduType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PduTypeProp in $PduTypeProperties) {
                                $PduTypeHash.Add($PduTypeProp.Name, $PduTypeProp.Value)
                            }
                            $object = [pscustomobject]$PduTypeHash
                            $PduTypesArray.Add($object)
                        } else {
                            $PduTypeHash = [ordered]@{ }
                            $PduTypeProperties = $PduType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PduTypeProp in $PduTypeProperties) {

                                $PduTypePropNewValue = Get-GlpiToolsParameters -Parameter $PduTypeProp.Name -Value $PduTypeProp.Value

                                $PduTypeHash.Add($PduTypeProp.Name, $PduTypePropNewValue)
                            }
                            $object = [pscustomobject]$PduTypeHash
                            $PduTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Pdu Type ID = $PTId is not found"
                        
                    }
                    $PduTypesArray
                    $PduTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PduTypeName { 
                Search-GlpiToolsItems -SearchFor pdutype -SearchType contains -SearchValue $PduTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}