<#
.SYNOPSIS
    Function is getting ComputerType informations from GLPI
.DESCRIPTION
    Function is based on ComputerTypeID which you can find in GLPI website
    Returns object with property's of ComputerType
.PARAMETER All
    This parameter will return all ComputerType from GLPI
.PARAMETER ComputerTypeId
    This parameter can take pipline input, either, you can use this function with -ComputerTypeId keyword.
    Provide to this param ComputerType ID from GLPI ComputerType Bookmark
.PARAMETER Raw
    Parameter which you can use with ComputerTypeId Parameter.
    ComputerTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ComputerType
    This parameter can take pipline input, either, you can use this function with -ComputerType keyword.
    Provide to this param ComputerType Name from GLPI ComputerType Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsComputerTypes -All
    Example will return all ComputerType from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsComputerTypes
    Function gets ComputerTypeId from GLPI from Pipline, and return ComputerType object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsComputerTypes
    Function gets ComputerTypeId from GLPI from Pipline (u can pass many ID's like that), and return ComputerType object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsComputerTypes -ComputerTypeId 326
    Function gets ComputerTypeId from GLPI which is provided through -ComputerTypeId after Function type, and return ComputerType object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsComputerTypes -ComputerTypeId 326, 321
    Function gets ComputerTypeId from GLPI which is provided through -ComputerTypeId keyword after Function type (u can provide many ID's like that), and return ComputerType object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsComputerTypes -ComputerType Fusion
    Example will return glpi ComputerType, but what is the most important, ComputerType will be shown exactly as you see in glpi dropdown ComputerType.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    ComputerType ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of ComputerType from GLPI
.NOTES
    PSP 06/2019
#>

function Get-GlpiToolsDropdownsComputerTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ComputerTypeId")]
        [alias('CTID')]
        [string[]]$ComputerTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ComputerTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ComputerTypeName")]
        [alias('CTN')]
        [string]$ComputerTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ComputerTypeArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/ComputerType/?range=0-9999999999999"
                }
                
                $GlpiComputerTypeAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($ComputerTypeModel in $GlpiComputerTypeAll) {
                    $ComputerTypeHash = [ordered]@{ }
                    $ComputerTypeProperties = $ComputerTypeModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ComputerTypeProp in $ComputerTypeProperties) {
                        $ComputerTypeHash.Add($ComputerTypeProp.Name, $ComputerTypeProp.Value)
                    }
                    $object = [pscustomobject]$ComputerTypeHash
                    $ComputerTypeArray.Add($object)
                }
                $ComputerTypeArray
                $ComputerTypeArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ComputerTypeId { 
                foreach ( $CTId in $ComputerTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/ComputerType/$($CTId)"
                    }

                    Try {
                        $ComputerTypeModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ComputerTypeHash = [ordered]@{ }
                            $ComputerTypeProperties = $ComputerTypeModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerTypeProp in $ComputerTypeProperties) {
                                $ComputerTypeHash.Add($ComputerTypeProp.Name, $ComputerTypeProp.Value)
                            }
                            $object = [pscustomobject]$ComputerTypeHash
                            $ComputerTypeArray.Add($object)
                        } else {
                            $ComputerTypeHash = [ordered]@{ }
                            $ComputerTypeProperties = $ComputerTypeModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerTypeProp in $ComputerTypeProperties) {

                                switch ($ComputerTypeProp.Name) {
                                    Default { $ComputerTypePropNewValue = $ComputerTypeProp.Value }
                                }

                                $ComputerTypeHash.Add($ComputerTypeProp.Name, $ComputerTypePropNewValue)
                            }
                            $object = [pscustomobject]$ComputerTypeHash
                            $ComputerTypeArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "ComputerType ID = $CTId is not found"
                        
                    }
                    $ComputerTypeArray
                    $ComputerTypeArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ComputerTypeName { 
                Search-GlpiToolsItems -SearchFor ComputerType -SearchType contains -SearchValue $ComputerTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}