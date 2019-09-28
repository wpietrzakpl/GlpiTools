<#
.SYNOPSIS
    Function is getting Internet Domains informations from GLPI
.DESCRIPTION
    Function is based on InternetDomainId which you can find in GLPI website
    Returns object with property's of Internet Domains
.PARAMETER All
    This parameter will return all Internet Domains from GLPI
.PARAMETER InternetDomainId
    This parameter can take pipeline input, either, you can use this function with -InternetDomainId keyword.
    Provide to this param InternetDomainId from GLPI Internet Domains Bookmark
.PARAMETER Raw
    Parameter which you can use with InternetDomainId Parameter.
    InternetDomainId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER InternetDomainName
    This parameter can take pipeline input, either, you can use this function with -InternetDomainId keyword.
    Provide to this param Internet Domains Name from GLPI Internet Domains Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsInternetDomains -All
    Example will return all Internet Domains from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsInternetDomains
    Function gets InternetDomainId from GLPI from pipeline, and return Internet Domains object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsInternetDomains
    Function gets InternetDomainId from GLPI from pipeline (u can pass many ID's like that), and return Internet Domains object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsInternetDomains -InternetDomainId 326
    Function gets InternetDomainId from GLPI which is provided through -InternetDomainId after Function type, and return Internet Domains object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsInternetDomains -InternetDomainId 326, 321
    Function gets Internet Domains Id from GLPI which is provided through -InternetDomainId keyword after Function type (u can provide many ID's like that), and return Internet Domains object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsInternetDomains -InternetDomainName Fusion
    Example will return glpi Internet Domains, but what is the most important, Internet Domains will be shown exactly as you see in glpi dropdown Internet Domains.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Internet Domains ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Internet Domains from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsInternetDomains {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "InternetDomainId")]
        [alias('IDID')]
        [string[]]$InternetDomainId,
        [parameter(Mandatory = $false,
            ParameterSetName = "InternetDomainId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "InternetDomainName")]
        [alias('IDN')]
        [string]$InternetDomainName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $InternetDomainsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/fqdn/?range=0-9999999999999"
                }
                
                $InternetDomainsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($InternetDomain in $InternetDomainsAll) {
                    $InternetDomainHash = [ordered]@{ }
                    $InternetDomainProperties = $InternetDomain.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($InternetDomainProp in $InternetDomainProperties) {
                        $InternetDomainHash.Add($InternetDomainProp.Name, $InternetDomainProp.Value)
                    }
                    $object = [pscustomobject]$InternetDomainHash
                    $InternetDomainsArray.Add($object)
                }
                $InternetDomainsArray
                $InternetDomainsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            InternetDomainId { 
                foreach ( $IDId in $InternetDomainId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/fqdn/$($IDId)"
                    }

                    Try {
                        $InternetDomain = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $InternetDomainHash = [ordered]@{ }
                            $InternetDomainProperties = $InternetDomain.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($InternetDomainProp in $InternetDomainProperties) {
                                $InternetDomainHash.Add($InternetDomainProp.Name, $InternetDomainProp.Value)
                            }
                            $object = [pscustomobject]$InternetDomainHash
                            $InternetDomainsArray.Add($object)
                        } else {
                            $InternetDomainHash = [ordered]@{ }
                            $InternetDomainProperties = $InternetDomain.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($InternetDomainProp in $InternetDomainProperties) {

                                $InternetDomainPropNewValue = Get-GlpiToolsParameters -Parameter $InternetDomainProp.Name -Value $InternetDomainProp.Value

                                $InternetDomainHash.Add($InternetDomainProp.Name, $InternetDomainPropNewValue)
                            }
                            $object = [pscustomobject]$InternetDomainHash
                            $InternetDomainsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Internet Domain ID = $IDId is not found"
                        
                    }
                    $InternetDomainsArray
                    $InternetDomainsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            InternetDomainName { 
                Search-GlpiToolsItems -SearchFor fqdn -SearchType contains -SearchValue $InternetDomainName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}