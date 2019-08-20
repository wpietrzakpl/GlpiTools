<#
.SYNOPSIS
    Function is getting Computer Software Version informations from GLPI
.DESCRIPTION
    Function is based on Computer Software Version ID which you can find in GLPI website
    Returns object with property's of Computer Software Version
.PARAMETER All
    This parameter will return all Computer Software Versions from GLPI
.PARAMETER ComputerSoftwareVersionId
    This parameter can take pipline input, either, you can use this function with -ComputerSoftwareVersionId keyword.
    Provide to this param Computer Software Version ID from GLPI
.PARAMETER Raw
    Parameter which you can use with ComputerSoftwareVersionId Parameter.
    ComputerSoftwareVersionId has converted parameters from default, parameter Raw allows not convert this parameters.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsComputerSoftwareVersions
    Function gets ComputerSoftwareVersionId from GLPI from Pipline, and return Computer Software Version object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsComputerSoftwareVersions
    Function gets ComputerSoftwareVersionId from GLPI from Pipline (u can pass many ID's like that), and return Computer Software Version object
.EXAMPLE
    PS C:\> Get-GlpiToolsComputerSoftwareVersions -ComputerSoftwareVersionId 326
    Function gets ComputerSoftwareVersionId from GLPI which is provided through -ComputerSoftwareVersionId after Function type, and return Computer Software Version object
.EXAMPLE 
    PS C:\> Get-GlpiToolsComputerSoftwareVersions -ComputerSoftwareVersionId 326, 321
    Function gets ComputerSoftwareVersionId from GLPI which is provided through -ComputerSoftwareVersionId keyword after Function type (u can provide many ID's like that), and return Computer Software Version object
.EXAMPLE
    PS C:\> Get-GlpiToolsComputerSoftwareVersions -ComputerSoftwareVersionId 234 -Raw
    Example will show Computer Software Version with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsComputerSoftwareVersions -Raw
    Example will show Computer Software Version with id 234, but without any parameter converted
.INPUTS
    Computer Software Version ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Computer Software Versions from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsComputerSoftwareVersions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,


        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ComputerSoftwareVersionId")]
        [alias('CSVID')]
        [string[]]$ComputerSoftwareVersionId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ComputerSoftwareVersionId")]
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

        $ComputerSoftwareVersionObjectArray = [System.Collections.Generic.List[PSObject]]::New()

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
                    uri     = "$($PathToGlpi)/Computer_SoftwareVersion/?range=0-9999999999999"
                }
                
                $GlpiComputerSoftwareVersionAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiComputerSoftwareVersion in $GlpiComputerSoftwareVersionAll) {
                    $ComputerSoftwareVersionHash = [ordered]@{ }
                            $ComputerSoftwareVersionProperties = $GlpiComputerSoftwareVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerSoftwareVersionProp in $ComputerSoftwareVersionProperties) {
                                $ComputerSoftwareVersionHash.Add($ComputerSoftwareVersionProp.Name, $ComputerSoftwareVersionProp.Value)
                            }
                            $object = [pscustomobject]$ComputerSoftwareVersionHash
                            $ComputerSoftwareVersionObjectArray.Add($object)
                }
                $ComputerSoftwareVersionObjectArray
                $ComputerSoftwareVersionObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                
            }
            ComputerSoftwareVersionId { 
                foreach ( $CSVid in $ComputerSoftwareVersionId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Computer_SoftwareVersion/$($CSVId)"
                    }

                    Try {
                        $GlpiComputerSoftwareVersion = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ComputerSoftwareVersionHash = [ordered]@{ }
                            $ComputerSoftwareVersionProperties = $GlpiComputerSoftwareVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerSoftwareVersionProp in $ComputerSoftwareVersionProperties) {
                                $ComputerSoftwareVersionHash.Add($ComputerSoftwareVersionProp.Name, $ComputerSoftwareVersionProp.Value)
                            }
                            $object = [pscustomobject]$ComputerSoftwareVersionHash
                            $ComputerSoftwareVersionObjectArray.Add($object)
                        } else {
                            $ComputerSoftwareVersionHash = [ordered]@{ }
                            $ComputerSoftwareVersionProperties = $GlpiComputerSoftwareVersion.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ComputerSoftwareVersionProp in $ComputerSoftwareVersionProperties) {
                                
                                $ComputerSoftwareVersionPropNewValue = Get-GlpiToolsParameters -Parameter $ComputerSoftwareVersionProp.Name -Value $ComputerSoftwareVersionProp.Value

                                $ComputerSoftwareVersionHash.Add($ComputerSoftwareVersionProp.Name, $ComputerSoftwareVersionPropNewValue)
                            }
                            $object = [pscustomobject]$ComputerSoftwareVersionHash
                            $ComputerSoftwareVersionObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Computer Software Version ID = $CSVId is not found"
                        
                    }
                    $ComputerSoftwareVersionObjectArray
                    $ComputerSoftwareVersionObjectArray = [System.Collections.Generic.List[PSObject]]::New()
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