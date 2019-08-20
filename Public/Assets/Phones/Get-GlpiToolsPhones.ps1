<#
.SYNOPSIS
    Function is getting Phone informations from GLPI
.DESCRIPTION
    Function is based on PhoneID which you can find in GLPI website
    Returns object with property's of Phone
.PARAMETER All
    This parameter will return all Phones from GLPI
.PARAMETER PhoneId
    This parameter can take pipline input, either, you can use this function with -PhoneId keyword.
    Provide to this param Phone ID from GLPI Phones Bookmark
.PARAMETER Raw
    Parameter which you can use with PhoneId Parameter.
    PhoneId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER PhoneName
    Provide to this param Phone Name from GLPI Phones Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with PhoneName Parameter.
    If you want Search for Phone name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with PhoneId Parameter. 
    If you want to get additional parameter of Phone object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsPhones
    Function gets PhoneID from GLPI from Pipline, and return Phone object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsPhones
    Function gets PhoneID from GLPI from Pipline (u can pass many ID's like that), and return Phone object
.EXAMPLE
    PS C:\> Get-GlpiToolsPhones -PhoneId 326
    Function gets PhoneID from GLPI which is provided through -PhoneId after Function type, and return Phone object
.EXAMPLE 
    PS C:\> Get-GlpiToolsPhones -PhoneId 326, 321
    Function gets PhoneID from GLPI which is provided through -PhoneId keyword after Function type (u can provide many ID's like that), and return Phone object
.EXAMPLE
    PS C:\> Get-GlpiToolsPhones -PhoneId 234 -Raw
    Example will show Phone with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsPhones -Raw
    Example will show Phone with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsPhones -PhoneName glpi
    Example will return glpi Phone, but what is the most important, Phone will be shown exacly as you see in glpi Phones tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsPhones -PhoneName glpi -SearchInTrash Yes
    Example will return glpi Phone, but from trash
.INPUTS
    Phone ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Phones from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsPhones {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "PhoneId")]
        [alias('PID')]
        [string[]]$PhoneId,
        [parameter(Mandatory = $false,
            ParameterSetName = "PhoneId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "PhoneName")]
        [alias('PN')]
        [string]$PhoneName,
        [parameter(Mandatory = $false,
            ParameterSetName = "PhoneName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "PhoneId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithDevices",
            "WithDisks",
            "WithSoftwares",
            "WithConnections",
            "WithNetworkports",
            "WithInfocoms",
            "WithContracts",
            "WithDocuments",
            "WithTickets",
            "WithProblems",
            "WithChanges",
            "WithNotes",
            "WithLogs")]
        [string]$Parameter
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $PhoneObjectArray = [System.Collections.Generic.List[PSObject]]::New()

        switch ($Parameter) {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
            WithDevices { $ParamValue = "?with_devices=true" }
            WithDisks { $ParamValue = "?with_disks=true" }
            WithSoftwares { $ParamValue = "?with_softwares=true" }
            WithConnections { $ParamValue = "?with_connections=true" }
            WithNetworkports { $ParamValue = "?with_networkports=true" }
            WithInfocoms { $ParamValue = "?with_infocoms=true" }
            WithContracts { $ParamValue = "?with_contracts=true" }
            WithDocuments { $ParamValue = "?with_documents=true" }
            WithTickets { $ParamValue = "?with_tickets=true" } 
            WithProblems { $ParamValue = "?with_problems=true" }
            WithChanges { $ParamValue = "?with_changes=true" }
            WithNotes { $ParamValue = "?with_notes=true" } 
            WithLogs { $ParamValue = "?with_logs=true" }
            Default { $ParamValue = "" }
        }

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
                    uri     = "$($PathToGlpi)/Phone/?range=0-9999999999999"
                }
                
                $GlpiPhoneAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiPhone in $GlpiPhoneAll) {
                    $PhoneHash = [ordered]@{ }
                            $PhoneProperties = $GlpiPhone.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhoneProp in $PhoneProperties) {
                                $PhoneHash.Add($PhoneProp.Name, $PhoneProp.Value)
                            }
                            $object = [pscustomobject]$PhoneHash
                            $PhoneObjectArray.Add($object)
                }
                $PhoneObjectArray
                $PhoneObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            PhoneId { 
                foreach ( $PId in $PhoneId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Phone/$($PId)$ParamValue"
                    }

                    Try {
                        $GlpiPhone = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $PhoneHash = [ordered]@{ }
                            $PhoneProperties = $GlpiPhone.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhoneProp in $PhoneProperties) {
                                $PhoneHash.Add($PhoneProp.Name, $PhoneProp.Value)
                            }
                            $object = [pscustomobject]$PhoneHash
                            $PhoneObjectArray.Add($object)
                        } else {
                            $PhoneHash = [ordered]@{ }
                            $PhoneProperties = $GlpiPhone.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($PhoneProp in $PhoneProperties) {

                                switch ($PhoneProp.Name) {
                                    entities_id { $PhonePropNewValue = $PhoneProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id { $PhonePropNewValue = $PhoneProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } }
                                    Default {
                                        $PhonePropNewValue = $PhoneProp.Value
                                    }
                                }
                                
                                $PhoneHash.Add($PhoneProp.Name, $PhonePropNewValue)
                            }
                            $object = [pscustomobject]$PhoneHash
                            $PhoneObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Phone ID = $PId is not found"
                        
                    }
                    $PhoneObjectArray
                    $PhoneObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            PhoneName { 
                Search-GlpiToolsItems -SearchFor Phone -SearchType contains -SearchValue $PhoneName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}