<#
.SYNOPSIS
    Function is getting Group informations from GLPI
.DESCRIPTION
    Function is based on GroupID which you can find in GLPI website
    Returns object with property's of group
.PARAMETER All
    This parameter will return all Groups from GLPI
.PARAMETER GroupId
    This parameter can take pipline input, either, you can use this function with -GroupId keyword.
    Provide to this param Group ID from GLPI Group Bookmark
.PARAMETER Raw
    Parameter which you can use with GroupId Parameter.
    GroupId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER GroupName
    This parameter can take pipline input, either, you can use this function with -GroupName keyword.
    Provide to this param Group Name from GLPI Group Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsGroups -All
    Example will return all Groups from Groups. 
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsGroups
    Function gets GroupID from GLPI from Pipline, and return Group object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsGroups
    Function gets GroupID from GLPI from Pipline (u can pass many ID's like that), and return Group object
.EXAMPLE
    PS C:\> Get-GlpiToolsGroups -GroupId 326
    Function gets GroupID from GLPI which is provided through -GroupId after Function type, and return Group object
.EXAMPLE 
    PS C:\> Get-GlpiToolsGroups -GroupId 326, 321
    Function gets GroupID from GLPI which is provided through -GroupId keyword after Function type (u can provide many ID's like that), and return Group object
.EXAMPLE
    PS C:\> Get-GlpiToolsGroups -GroupId 234 -Raw
    Example will show Group with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsGroups -Raw
    Example will show Group with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsGroups -GroupName glpi
    Example will return glpi Group, but what is the most important, Group will be shown exactly as you see in glpi Groups tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Group ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Groups from GLPI
.NOTES
    PSP 03/2019
#>

function Get-GlpiToolsGroups {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "GroupId")]
        [alias('GID')]
        [string[]]$GroupId,
        [parameter(Mandatory = $false,
            ParameterSetName = "GroupId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "GroupName")]
        [alias('GN')]
        [string]$GroupName
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $GroupObjectArray = @()

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
                    uri     = "$($PathToGlpi)/Group/?range=0-9999999999999"
                }
                
                $GlpiGroupsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiGroup in $GlpiGroupsAll) {
                    $GroupHash = [ordered]@{ }
                            $GroupProperties = $GlpiGroup.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($GroupProp in $GroupProperties) {
                                $GroupHash.Add($GroupProp.Name, $GroupProp.Value)
                            }
                            $object = [pscustomobject]$GroupHash
                            $GroupObjectArray += $object 
                }
                $GroupObjectArray
                $GroupObjectArray = @()
            }
            GroupId { 
                foreach ( $GId in $GroupId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Group/$($GId)"
                    }

                    Try {
                        $GlpiGroup = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $GroupHash = [ordered]@{ }
                            $GroupProperties = $GlpiGroup.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($GroupProp in $GroupProperties) {
                                $GroupHash.Add($GroupProp.Name, $GroupProp.Value)
                            }
                            $object = [pscustomobject]$GroupHash
                            $GroupObjectArray += $object 
                        } else {
                            $GroupHash = [ordered]@{ }
                            $GroupProperties = $GlpiGroup.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($GroupProp in $GroupProperties) {

                                switch ($GroupProp.Name) {
                                    entities_id { $GroupPropNewValue = $GroupProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    Default {
                                        $GroupPropNewValue = $GroupProp.Value
                                    }
                                }

                                $GroupHash.Add($GroupProp.Name, $GroupPropNewValue)
                            }
                            $object = [pscustomobject]$GroupHash
                            $GroupObjectArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "Group ID = $GId is not found"
                        
                    }
                    $GroupObjectArray
                    $GroupObjectArray = @()
                }
            }
            GroupName { 
                Search-GlpiToolsItems -SearchFor Group -SearchType contains -SearchValue $GroupName 
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}