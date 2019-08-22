<#
.SYNOPSIS
    Function is getting FinancialAndAdminstrativeId informations from GLPI
.DESCRIPTION
    Function is based on FinancialAndAdminstrativeId which you can find in GLPI website
    Returns object with property's of FinancialAndAdminstrativeId Tab
.PARAMETER All
    This parameter will return all FinancialAndAdminstrativeId informations for All Assets from GLPI
.PARAMETER FinancialAndAdminstrativeId
    This parameter can take pipline input, either, you can use this function with -FinancialAndAdminstrativeId keyword.
    Provide to this param FinancialAndAdminstrativeId ID running this function before with parameter All to retrieve id's 
.PARAMETER Raw
    Parameter which you can use with FinancialAndAdminstrativeId Parameter.
    FinancialAndAdminstrativeId has converted parameters from default, parameter Raw allows not convert this parameters.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsFinancialAndAdministrativeInformations
    Function gets FinancialAndAdminstrativeId from GLPI from Pipline, and return FinancialAndAdminstrative object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsFinancialAndAdministrativeInformations
    Function gets FinancialAndAdminstrativeId from GLPI from Pipline (u can pass many ID's like that), and return FinancialAndAdminstrative object
.EXAMPLE
    PS C:\> Get-GlpiToolsFinancialAndAdministrativeInformations -FinancialAndAdminstrativeId 326
    Function gets FinancialAndAdminstrativeId from GLPI which is provided through -FinancialAndAdminstrativeId after Function type, and return FinancialAndAdminstrative object
.EXAMPLE 
    PS C:\> Get-GlpiToolsFinancialAndAdministrativeInformations -FinancialAndAdminstrativeId 326, 321
    Function gets FinancialAndAdminstrativeId from GLPI which is provided through -FinancialAndAdminstrativeId keyword after Function type (u can provide many ID's like that), and return FinancialAndAdminstrative object
.EXAMPLE
    PS C:\> Get-GlpiToolsFinancialAndAdministrativeInformations -FinancialAndAdminstrativeId 234 -Raw
    Example will show FinancialAndAdminstrativeId with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsFinancialAndAdministrativeInformations -Raw
    Example will show FinancialAndAdminstrativeId with id 234, but without any parameter converted
.INPUTS
    FinancialAndAdminstrativeIdID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Financial And Adminstrative Tab from GLPI
.NOTES
    PSP 08/2018
#>

function Get-GlpiToolsFinancialAndAdministrativeInformations {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "FinancialAndAdminstrativeId")]
        [alias('FAAID')]
        [string[]]$FinancialAndAdminstrativeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "FinancialAndAdminstrativeId")]
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

        $FinancialAndAdminstrativeArray = [System.Collections.Generic.List[PSObject]]::New()

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
                    uri     = "$($PathToGlpi)/infocom/?range=0-9999999999999"
                }
                
                $GlpiFinancialAndAdminstrativeAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiFinancialAndAdminstrative in $GlpiFinancialAndAdminstrativeAll) {
                    $FinancialAndAdminstrativeHash = [ordered]@{ }
                            $FinancialAndAdminstrativeProperties = $GlpiFinancialAndAdminstrative.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($FinancialAndAdminstrativeProp in $FinancialAndAdminstrativeProperties) {
                                $FinancialAndAdminstrativeHash.Add($FinancialAndAdminstrativeProp.Name, $FinancialAndAdminstrativeProp.Value)
                            }
                            $object = [pscustomobject]$FinancialAndAdminstrativeHash
                            $FinancialAndAdminstrativeArray.Add($object) 
                }
                $FinancialAndAdminstrativeArray
                $FinancialAndAdminstrativeArray = [System.Collections.Generic.List[PSObject]]::New()
                
            }
            FinancialAndAdminstrativeId { 
                foreach ( $FAAId in $FinancialAndAdminstrativeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/infocom/$($FAAId)"
                    }

                    Try {
                        $GlpiFinancialAndAdminstrative = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $FinancialAndAdminstrativeHash = [ordered]@{ }
                            $FinancialAndAdminstrativeProperties = $GlpiFinancialAndAdminstrative.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($FinancialAndAdminstrativeProp in $FinancialAndAdminstrativeProperties) {
                                $FinancialAndAdminstrativeHash.Add($FinancialAndAdminstrativeProp.Name, $FinancialAndAdminstrativeProp.Value)
                            }
                            $object = [pscustomobject]$FinancialAndAdminstrativeHash
                            $FinancialAndAdminstrativeArray.Add($object)
                        } else {
                            $FinancialAndAdminstrativeHash = [ordered]@{ }
                            $FinancialAndAdminstrativeProperties = $GlpiFinancialAndAdminstrative.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($FinancialAndAdminstrativeProp in $FinancialAndAdminstrativeProperties) {
                                
                                $FinancialAndAdminstrativePropNewValue = Get-GlpiToolsParameters -Parameter $FinancialAndAdminstrativeProp.Name -Value $FinancialAndAdminstrativeProp.Value

                                $FinancialAndAdminstrativeHash.Add($FinancialAndAdminstrativeProp.Name, $FinancialAndAdminstrativePropNewValue)
                            }
                            $object = [pscustomobject]$FinancialAndAdminstrativeHash
                            $FinancialAndAdminstrativeArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "FinancialAndAdminstrativeId ID = $FAAId is not found"
                        
                    }
                    $FinancialAndAdminstrativeArray
                    $FinancialAndAdminstrativeArray = [System.Collections.Generic.List[PSObject]]::New()
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