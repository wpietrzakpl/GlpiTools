<#
.SYNOPSIS
    Function is getting Software informations from GLPI
.DESCRIPTION
    Function is based on SoftwareID which you can find in GLPI website
    Returns object with property's of Software
.PARAMETER All
    This parameter will return all Softwares from GLPI
.PARAMETER SoftwareId
    This parameter can take pipline input, either, you can use this function with -SoftwareId keyword.
    Provide to this param Software ID from GLPI Softwares Bookmark
.PARAMETER Raw
    Parameter which you can use with SoftwareId Parameter.
    SoftwareId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER Parameter
    Parameter which you can use with SoftwareId Parameter. 
    If you want to get additional parameter of Software object like, disks, or logs, use this parameter.
.PARAMETER SoftwareName
    This parameter can take pipline input, either, you can use this function with -SoftwareName keyword.
    Provide to this param Software Name from GLPI Softwares Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with SoftwareName Parameter.
    If you want Search for Software name in trash, that parameter allow you to do it.
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsSoftware
    Function gets SoftwareId from GLPI from Pipline, and return Software object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsSoftware
    Function gets SoftwareId from GLPI from Pipline (u can pass many ID's like that), and return Software object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsSoftware -SoftwareId 326
    Function gets SoftwareId from GLPI which is provided through -SoftwareId after Function type, and return Software object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsSoftware -SoftwareId 326, 321
    Function gets SoftwareId from GLPI which is provided through -SoftwareId keyword after Function type (u can provide many ID's like that), and return Software object
.INPUTS
    Software ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of software from GLPI
.NOTES
    PSP 04/2019
#>

function Get-GlpiToolsSoftware {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "SoftwareId")]
        [alias('SID')]
        [string[]]$SoftwareId,
        [parameter(Mandatory = $false,
            ParameterSetName = "SoftwareId")]
        [switch]$Raw,
        [parameter(Mandatory = $false,
            ParameterSetName = "SoftwareId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithNetworkports",
            "WithInfocoms",
            "WithContracts",
            "WithDocuments",
            "WithTickets",
            "WithProblems",
            "WithChanges",
            "WithNotes",
            "WithLogs")]
        [string]$Parameter,

        [parameter(Mandatory = $true,
            ParameterSetName = "SoftwareName")]
        [alias('SN')]
        [string]$SoftwareName,
        [parameter(Mandatory = $false,
            ParameterSetName = "SoftwareName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No"

    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $SoftwareObjectArray = @()

        switch ($Parameter) {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
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
                    uri     = "$($PathToGlpi)/Software/?range=0-99999999999"
                }
                
                $GlpiSoftwareAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiSoftware in $GlpiSoftwareAll) {
                    $SoftwareHash = [ordered]@{ }
                    $SoftwareProperties = $GlpiSoftware.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($SoftwareProp in $SoftwareProperties) {
                        $SoftwareHash.Add($SoftwareProp.Name, $SoftwareProp.Value)
                    }
                    $object = [pscustomobject]$SoftwareHash
                    $SoftwareObjectArray += $object 
                }
                $SoftwareObjectArray
                $SoftwareObjectArray = @()
            }
            SoftwareId {
                foreach ( $SId in $SoftwareId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Software/$($SId)$ParamValue"
                    }

                    Try {
                        $GlpiSoftware = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $SoftwareHash = [ordered]@{ }
                            $SoftwareProperties = $GlpiSoftware.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SoftwareProp in $SoftwareProperties) {
                                $SoftwareHash.Add($SoftwareProp.Name, $SoftwareProp.Value)
                            }
                            $object = [pscustomobject]$SoftwareHash
                            $SoftwareObjectArray += $object 
                        } else {
                            $SoftwareHash = [ordered]@{ }
                            $SoftwareProperties = $GlpiSoftware.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($SoftwareProp in $SoftwareProperties) {

                                switch ($SoftwareProp.Name) {
                                    entities_id { $SoftwarePropNewValue = $SoftwareProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id { $SoftwarePropNewValue = $SoftwareProp.Value | Get-GlpiToolsUsers | Select-Object -ExpandProperty User }
                                    Default {
                                        $SoftwarePropNewValue = $SoftwareProp.Value
                                    }
                                }

                                $SoftwareHash.Add($SoftwareProp.Name, $SoftwarePropNewValue)
                            }
                            $object = [pscustomobject]$SoftwareHash
                            $SoftwareObjectArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "Software ID = $SId is not found"
                        
                    }
                    $SoftwareObjectArray
                    $SoftwareObjectArray = @()
                }
            }
            SoftwareName {
                Search-GlpiToolsItems -SearchFor Software -SearchType contains -SearchValue $SoftwareName -SearchInTrash $SearchInTrash
            }
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}