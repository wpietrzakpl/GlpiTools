<#
.SYNOPSIS
    Function is getting Group Members informations from GLPI
.DESCRIPTION
    Function is based on GroupMemberId which you can find in GLPI website
    Returns object with property's of Group Members
.PARAMETER All
    This parameter will return all Group Members from GLPI
.PARAMETER GroupMemberId
    This parameter can take pipeline input, either, you can use this function with -GroupMemberId keyword.
    Provide to this param GroupMemberId from GLPI Group Members Bookmark
.PARAMETER Raw
    Parameter which you can use with GroupMemberId Parameter.
    GroupMemberId has converted parameters from default, parameter Raw allows not convert this parameters.
.EXAMPLE
    PS C:\> Get-GlpiToolsGroupsMembers -All
    Example will return all Group Members from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsGroupsMembers
    Function gets GroupMemberId from GLPI from pipeline, and return Group Members object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsGroupsMembers
    Function gets GroupMemberId from GLPI from pipeline (u can pass many ID's like that), and return Group Members object
.EXAMPLE
    PS C:\> Get-GlpiToolsGroupsMembers -GroupMemberId 326
    Function gets GroupMemberId from GLPI which is provided through -GroupMemberId after Function type, and return Group Members object
.EXAMPLE 
    PS C:\> Get-GlpiToolsGroupsMembers -GroupMemberId 326, 321
    Function gets Group Members Id from GLPI which is provided through -GroupMemberId keyword after Function type (u can provide many ID's like that), and return Group Members object
.INPUTS
    Group Members ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Group Members from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsGroupsMembers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "GroupMemberId")]
        [alias('GMID')]
        [string[]]$GroupMemberId,
        [parameter(Mandatory = $false,
            ParameterSetName = "GroupMemberId")]
        [switch]$Raw
        
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $GroupMembersArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/Group_User/?range=0-9999999999999"
                }
                
                $GroupMembersAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GroupMember in $GroupMembersAll) {
                    $GroupMemberHash = [ordered]@{ }
                    $GroupMemberProperties = $GroupMember.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($GroupMemberProp in $GroupMemberProperties) {
                        $GroupMemberHash.Add($GroupMemberProp.Name, $GroupMemberProp.Value)
                    }
                    $object = [pscustomobject]$GroupMemberHash
                    $GroupMembersArray.Add($object)
                }
                $GroupMembersArray
                $GroupMembersArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            GroupMemberId { 
                foreach ( $GMId in $GroupMemberId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Group_User/$($GMId)"
                    }

                    Try {
                        $GroupMember = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $GroupMemberHash = [ordered]@{ }
                            $GroupMemberProperties = $GroupMember.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($GroupMemberProp in $GroupMemberProperties) {
                                $GroupMemberHash.Add($GroupMemberProp.Name, $GroupMemberProp.Value)
                            }
                            $object = [pscustomobject]$GroupMemberHash
                            $GroupMembersArray.Add($object)
                        } else {
                            $GroupMemberHash = [ordered]@{ }
                            $GroupMemberProperties = $GroupMember.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($GroupMemberProp in $GroupMemberProperties) {

                                $GroupMemberPropNewValue = Get-GlpiToolsParameters -Parameter $GroupMemberProp.Name -Value $GroupMemberProp.Value

                                $GroupMemberHash.Add($GroupMemberProp.Name, $GroupMemberPropNewValue)
                            }
                            $object = [pscustomobject]$GroupMemberHash
                            $GroupMembersArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Group Member ID = $GMId is not found"
                        
                    }
                    $GroupMembersArray
                    $GroupMembersArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}