<#
.SYNOPSIS
    Function is getting Domain informations from GLPI
.DESCRIPTION
    Function is based on DomainID which you can find in GLPI website
    Returns object with property's of Domain
.PARAMETER All
    This parameter will return all Domain from GLPI
.PARAMETER DomainId
    This parameter can take pipline input, either, you can use this function with -DomainId keyword.
    Provide to this param Domain ID from GLPI Domain Bookmark
.PARAMETER Raw
    Parameter which you can use with DomainId Parameter.
    DomainId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER DomainName
    This parameter can take pipline input, either, you can use this function with -DomainName keyword.
    Provide to this param Domain Name from GLPI Domain Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDomains -All
    Example will return all Domain from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsDomains
    Function gets DomainId from GLPI from Pipline, and return Domain object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsDomains
    Function gets DomainId from GLPI from Pipline (u can pass many ID's like that), and return Domain object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDomains -DomainId 326
    Function gets DomainId from GLPI which is provided through -DomainId after Function type, and return Domain object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsDomains -DomainId 326, 321
    Function gets DomainId from GLPI which is provided through -DomainId keyword after Function type (u can provide many ID's like that), and return Domain object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsDomains -DomainName Fusion
    Example will return glpi Domain, but what is the most important, Domain will be shown exactly as you see in glpi dropdown Domain.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Domain ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Domain from GLPI
.NOTES
    PSP 06/2019
#>

function Get-GlpiToolsDropdownsDomains {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "DomainId")]
        [alias('DID')]
        [string[]]$DomainId,
        [parameter(Mandatory = $false,
            ParameterSetName = "DomainId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "DomainName")]
        [alias('DN')]
        [string]$DomainName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $DomainArray = [System.Collections.ArrayList]::new()
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
                    uri     = "$($PathToGlpi)/Domain/?range=0-9999999999999"
                }
                
                $GlpiDomainAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($DomainModel in $GlpiDomainAll) {
                    $DomainHash = [ordered]@{ }
                    $DomainProperties = $DomainModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($DomainProp in $DomainProperties) {
                        $DomainHash.Add($DomainProp.Name, $DomainProp.Value)
                    }
                    $object = [pscustomobject]$DomainHash
                    $DomainArray.Add($object)
                }
                $DomainArray
                $DomainArray = [System.Collections.ArrayList]::new()
            }
            DomainId { 
                foreach ( $DId in $DomainId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Domain/$($DId)"
                    }

                    Try {
                        $DomainModel = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $DomainHash = [ordered]@{ }
                            $DomainProperties = $DomainModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DomainProp in $DomainProperties) {
                                $DomainHash.Add($DomainProp.Name, $DomainProp.Value)
                            }
                            $object = [pscustomobject]$DomainHash
                            $DomainArray.Add($object)
                        } else {
                            $DomainHash = [ordered]@{ }
                            $DomainProperties = $DomainModel.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($DomainProp in $DomainProperties) {

                                switch ($DomainProp.Name) {
                                    Default { $DomainPropNewValue = $DomainProp.Value }
                                }

                                $DomainHash.Add($DomainProp.Name, $DomainPropNewValue)
                            }
                            $object = [pscustomobject]$DomainHash
                            $DomainArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Domain ID = $DId is not found"
                        
                    }
                    $DomainArray
                    $DomainArray = [System.Collections.ArrayList]::new()
                }
            }
            DomainName { 
                Search-GlpiToolsItems -SearchFor Domain -SearchType contains -SearchValue $DomainName 
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}