<#
.SYNOPSIS
    Function is getting Software Version informations from GLPI
.DESCRIPTION
    Function is based on Software Version ID which you can find in GLPI website
    Returns object with property's of Software Version
.PARAMETER All
    This parameter will return all Software Versions from GLPI
.PARAMETER SoftwareVersionId
    This parameter can take pipline input, either, you can use this function with -SoftwareVersionId keyword.
    Provide to this param Software Version ID from GLPI
.PARAMETER Raw
    Parameter which you can use with SoftwareVersionId Parameter.
    SoftwareVersionId has converted parameters from default, parameter Raw allows not convert this parameters.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsSoftwareVersions
    Function gets SoftwareVersionID from GLPI from Pipline, and return Software Version object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsSoftwareVersions
    Function gets SoftwareVersionID from GLPI from Pipline (u can pass many ID's like that), and return Software Version object
.EXAMPLE
    PS C:\> Get-GlpiToolsSoftwareVersions -SoftwareVersionId 326
    Function gets SoftwareVersionID from GLPI which is provided through -SoftwareVersionId after Function type, and return Software Version object
.EXAMPLE 
    PS C:\> Get-GlpiToolsSoftwareVersions -SoftwareVersionId 326, 321
    Function gets SoftwareVersionID from GLPI which is provided through -SoftwareVersionId keyword after Function type (u can provide many ID's like that), and return Software Version object
.EXAMPLE
    PS C:\> Get-GlpiToolsSoftwareVersions -SoftwareVersionId 234 -Raw
    Example will show Software Version with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsSoftwareVersions -Raw
    Example will show Software Version with id 234, but without any parameter converted
.INPUTS
    Software Version ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Software Versions from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsSoftwareVersions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,


        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SoftwareVersionId")]
        [alias('SVID')]
        [string[]]$SoftwareVersionId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SoftwareVersionId")]
        [switch]$Raw
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SoftwareVersionObjectArray = @()

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
                    uri     = "$($PathToGlpi)/SoftwareVersion/?range=0-9999999999999"
                }
                
                $GlpiSoftwareVersionAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiSoftwareVersion in $GlpiSoftwareVersionAll) {
                    $SoftwareVersionHash = [ordered]@{ }
                            $SoftwareVersionProperties = $GlpiSoftwareVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SoftwareVersionProp in $SoftwareVersionProperties) {
                                $SoftwareVersionHash.Add($SoftwareVersionProp.Name, $SoftwareVersionProp.Value)
                            }
                            $object = [pscustomobject]$SoftwareVersionHash
                            $SoftwareVersionObjectArray += $object 
                }
                $SoftwareVersionObjectArray
                $SoftwareVersionObjectArray = @()
                
            }
            SoftwareVersionId { 
                foreach ( $SVid in $SoftwareVersionId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/SoftwareVersion/$($SVId)"
                    }

                    Try {
                        $GlpiSoftwareVersion = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SoftwareVersionHash = [ordered]@{ }
                            $SoftwareVersionProperties = $GlpiSoftwareVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SoftwareVersionProp in $SoftwareVersionProperties) {
                                $SoftwareVersionHash.Add($SoftwareVersionProp.Name, $SoftwareVersionProp.Value)
                            }
                            $object = [pscustomobject]$SoftwareVersionHash
                            $SoftwareVersionObjectArray += $object 
                        } else {
                            $SoftwareVersionHash = [ordered]@{ }
                            $SoftwareVersionProperties = $GlpiSoftwareVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SoftwareVersionProp in $SoftwareVersionProperties) {
                                
                                $SoftwareVersionPropNewValue = Get-GlpiToolsParameters -Parameter $SoftwareVersionProp.Name -Value $SoftwareVersionProp.Value

                                $SoftwareVersionHash.Add($SoftwareVersionProp.Name, $SoftwareVersionPropNewValue)
                            }
                            $object = [pscustomobject]$SoftwareVersionHash
                            $SoftwareVersionObjectArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "Software Version ID = $SVId is not found"
                        
                    }
                    $SoftwareVersionObjectArray
                    $SoftwareVersionObjectArray = @()
                }
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}