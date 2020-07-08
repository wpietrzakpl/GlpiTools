<#
.SYNOPSIS
    Function is getting Contact informations from GLPI
.DESCRIPTION
    Function is based on ContactId which you can find in GLPI website
    Returns object with property's of Contact
.PARAMETER All
    This parameter will return all Contact from GLPI
.PARAMETER ContactId
    This parameter can take pipline input, either, you can use this function with -ContactId keyword.
    Provide to this param ContactId from GLPI Contact Bookmark
.PARAMETER Raw
    Parameter which you can use with ContactId Parameter.
    ContactId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ContactName
    This parameter can take pipline input, either, you can use this function with -ContactId keyword.
    Provide to this param Contact Name from GLPI Contact Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsContacts -All
    Example will return all Contact from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsContacts
    Function gets ContactId from GLPI from Pipline, and return Contact object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsContacts
    Function gets ContactId from GLPI from Pipline (u can pass many ID's like that), and return Contact object
.EXAMPLE
    PS C:\> Get-GlpiToolsContacts -ContactId 326
    Function gets ContactId from GLPI which is provided through -ContactId after Function type, and return Contact object
.EXAMPLE 
    PS C:\> Get-GlpiToolsContacts -ContactId 326, 321
    Function gets Contact Id from GLPI which is provided through -ContactId keyword after Function type (u can provide many ID's like that), and return Contact object
.EXAMPLE
    PS C:\> Get-GlpiToolsContacts -ContactName Fusion
    Example will return glpi Contact, but what is the most important, Contact will be shown exactly as you see in glpi dropdown Contact.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Contact ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Contact from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsContacts {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ContactId")]
        [alias('CID')]
        [string[]]$ContactId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ContactId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ContactName")]
        [alias('CN')]
        [string]$ContactName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ContactsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Contact/?range=0-9999999999999"
                }
                
                $ContactsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Contact in $ContactsAll) {
                    $ContactHash = [ordered]@{ }
                    $ContactProperties = $Contact.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ContactProp in $ContactProperties) {
                        $ContactHash.Add($ContactProp.Name, $ContactProp.Value)
                    }
                    $object = [pscustomobject]$ContactHash
                    $ContactsArray.Add($object)
                }
                $ContactsArray
                $ContactsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ContactId { 
                foreach ( $CId in $ContactId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Contact/$($CId)"
                    }

                    Try {
                        $Contact = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ContactHash = [ordered]@{ }
                            $ContactProperties = $Contact.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContactProp in $ContactProperties) {
                                $ContactHash.Add($ContactProp.Name, $ContactProp.Value)
                            }
                            $object = [pscustomobject]$ContactHash
                            $ContactsArray.Add($object)
                        } else {
                            $ContactHash = [ordered]@{ }
                            $ContactProperties = $Contact.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ContactProp in $ContactProperties) {

                                $ContactPropNewValue = Get-GlpiToolsParameters -Parameter $ContactProp.Name -Value $ContactProp.Value

                                $ContactHash.Add($ContactProp.Name, $ContactPropNewValue)
                            }
                            $object = [pscustomobject]$ContactHash
                            $ContactsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Contact ID = $CId is not found"
                        
                    }
                    $ContactsArray
                    $ContactsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ContactName { 
                Search-GlpiToolsItems -SearchFor Contact -SearchType contains -SearchValue $ContactName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}