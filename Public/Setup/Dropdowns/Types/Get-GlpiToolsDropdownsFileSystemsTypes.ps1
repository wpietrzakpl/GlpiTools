<#
.SYNOPSIS
    Function is getting File Systems Types informations from GLPI
.DESCRIPTION
    Function is based on FileSystemTypeId which you can find in GLPI website
    Returns object with property's of File Systems Types
.PARAMETER All
    This parameter will return all File Systems Types from GLPI
.PARAMETER FileSystemTypeId
    This parameter can take pipline input, either, you can use this function with -FileSystemTypeId keyword.
    Provide to this param FileSystemTypeId from GLPI File Systems Types Bookmark
.PARAMETER Raw
    Parameter which you can use with FileSystemTypeId Parameter.
    FileSystemTypeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER FileSystemTypeName
    This parameter can take pipline input, either, you can use this function with -FileSystemTypeId keyword.
    Provide to this param File Systems Types Name from GLPI File Systems Types Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsFileSystemsTypes -All
    Example will return all File Systems Types from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsFileSystemsTypes
    Function gets FileSystemTypeId from GLPI from Pipline, and return File Systems Types object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsFileSystemsTypes
    Function gets FileSystemTypeId from GLPI from Pipline (u can pass many ID's like that), and return File Systems Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsFileSystemsTypes -FileSystemTypeId 326
    Function gets FileSystemTypeId from GLPI which is provided through -FileSystemTypeId after Function type, and return File Systems Types object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsFileSystemsTypes -FileSystemTypeId 326, 321
    Function gets File Systems Types Id from GLPI which is provided through -FileSystemTypeId keyword after Function type (u can provide many ID's like that), and return File Systems Types object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsFileSystemsTypes -FileSystemTypeName Fusion
    Example will return glpi File Systems Types, but what is the most important, File Systems Types will be shown exactly as you see in glpi dropdown File Systems Types.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    File Systems Types ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of File Systems Types from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsFileSystemsTypes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "FileSystemTypeId")]
        [alias('FSTID')]
        [string[]]$FileSystemTypeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "FileSystemTypeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "FileSystemTypeName")]
        [alias('FSTN')]
        [string]$FileSystemTypeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $FileSystemsTypesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/filesystem/?range=0-9999999999999"
                }
                
                $FileSystemsTypesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($FileSystemType in $FileSystemsTypesAll) {
                    $FileSystemTypeHash = [ordered]@{ }
                    $FileSystemTypeProperties = $FileSystemType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($FileSystemTypeProp in $FileSystemTypeProperties) {
                        $FileSystemTypeHash.Add($FileSystemTypeProp.Name, $FileSystemTypeProp.Value)
                    }
                    $object = [pscustomobject]$FileSystemTypeHash
                    $FileSystemsTypesArray.Add($object)
                }
                $FileSystemsTypesArray
                $FileSystemsTypesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            FileSystemTypeId { 
                foreach ( $FSTId in $FileSystemTypeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/filesystem/$($FSTId)"
                    }

                    Try {
                        $FileSystemType = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $FileSystemTypeHash = [ordered]@{ }
                            $FileSystemTypeProperties = $FileSystemType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($FileSystemTypeProp in $FileSystemTypeProperties) {
                                $FileSystemTypeHash.Add($FileSystemTypeProp.Name, $FileSystemTypeProp.Value)
                            }
                            $object = [pscustomobject]$FileSystemTypeHash
                            $FileSystemsTypesArray.Add($object)
                        } else {
                            $FileSystemTypeHash = [ordered]@{ }
                            $FileSystemTypeProperties = $FileSystemType.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($FileSystemTypeProp in $FileSystemTypeProperties) {

                                $FileSystemTypePropNewValue = Get-GlpiToolsParameters -Parameter $FileSystemTypeProp.Name -Value $FileSystemTypeProp.Value

                                $FileSystemTypeHash.Add($FileSystemTypeProp.Name, $FileSystemTypePropNewValue)
                            }
                            $object = [pscustomobject]$FileSystemTypeHash
                            $FileSystemsTypesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "File System Type ID = $FSTId is not found"
                        
                    }
                    $FileSystemsTypesArray
                    $FileSystemsTypesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            FileSystemTypeName { 
                Search-GlpiToolsItems -SearchFor filesystem -SearchType contains -SearchValue $FileSystemTypeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}