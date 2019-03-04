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
.PARAMETER GroupName
    This parameter can take pipline input, either, you can use this function with -GroupName keyword.
    Provide to this param Group Name from GLPI Group Bookmark
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsGroup
    Function gets GroupId from GLPI from Pipline, and return Group object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsGroup
    Function gets GroupId from GLPI from Pipline (u can pass many ID's like that), and return Group object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsGroup -GroupId 326
    Function gets GroupId from GLPI which is provided through -GroupId after Function type, and return Group object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsGroup -GroupId 326, 321
    Function gets GroupId from GLPI which is provided through -GroupId keyword after Function type (u can provide many ID's like that), and return Group object
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
        [parameter(Mandatory = $true,
            ParameterSetName = "GroupName")]
        [alias('GN')]
        [string[]]$GroupName
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
                    uri     = "$($PathToGlpi)/Group/?range=0-99999999999"
                }
                
                $GlpiGroupAll = Invoke-RestMethod @params

                foreach ($GlpiGroup in $GlpiGroupAll) {
                    $GroupHash = [ordered]@{
                        'Id'                   = $GlpiGroup.id
                        'EntitiesId'           = $GlpiGroup.entities_id
                        'EntityName'           = $GlpiGroup.entities_id | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName
                        'IsRecursive'          = $GlpiGroup.is_recursive
                        'Name'                 = $GlpiGroup.name 
                        'Comment'              = $GlpiGroup.comment
                        'LdapField'            = $GlpiGroup.ldap_field
                        'LdapValue'            = $GlpiGroup.ldap_value
                        'LdapGroupDn'          = $GlpiGroup.ldap_group_dn
                        'DateMod'              = $GlpiGroup.date_mod
                        'GroupsId'             = $GlpiGroup.groups_id
                        'CompleteName'         = $GlpiGroup.completename
                        'Level'                = $GlpiGroup.level
                        'AncestorsCache'       = $GlpiGroup.ancestors_cache
                        'SonsCache'            = $GlpiGroup.sons_cache
                        'IsRequester'          = $GlpiGroup.is_requester
                        'IsAssign'             = $GlpiGroup.is_assign
                        'IsTask'               = $GlpiGroup.is_task
                        'IsNotify'             = $GlpiGroup.is_notify
                        'IsItemgroup'          = $GlpiGroup.is_itemgroup
                        'IsUsergroup'          = $GlpiGroup.is_usergroup
                        'IsManager'            = $GlpiGroup.is_manager
                        'DateCreation'         = $GlpiGroup.date_creation
                    }
                    $object = New-Object -TypeName PSCustomObject -Property $GroupHash
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
                
                    try {
                        $GlpiGroup = Invoke-RestMethod @params -ErrorAction Stop
                        $GroupHash = [ordered]@{
                            'Id'                   = $GlpiGroup.id
                            'EntitiesId'           = $GlpiGroup.entities_id
                            'EntityName'           = $GlpiGroup.entities_id | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName
                            'IsRecursive'          = $GlpiGroup.is_recursive
                            'Name'                 = $GlpiGroup.name 
                            'Comment'              = $GlpiGroup.comment
                            'LdapField'            = $GlpiGroup.ldap_field
                            'LdapValue'            = $GlpiGroup.ldap_value
                            'LdapGroupDn'          = $GlpiGroup.ldap_group_dn
                            'DateMod'              = $GlpiGroup.date_mod
                            'GroupsId'             = $GlpiGroup.groups_id
                            'CompleteName'         = $GlpiGroup.completename
                            'Level'                = $GlpiGroup.level
                            'AncestorsCache'       = $GlpiGroup.ancestors_cache
                            'SonsCache'            = $GlpiGroup.sons_cache
                            'IsRequester'          = $GlpiGroup.is_requester
                            'IsAssign'             = $GlpiGroup.is_assign
                            'IsTask'               = $GlpiGroup.is_task
                            'IsNotify'             = $GlpiGroup.is_notify
                            'IsItemgroup'          = $GlpiGroup.is_itemgroup
                            'IsUsergroup'          = $GlpiGroup.is_usergroup
                            'IsManager'            = $GlpiGroup.is_manager
                            'DateCreation'         = $GlpiGroup.date_creation
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $GroupHash
                        $GroupObjectArray += $object
                    }
                    catch {
                        $GroupHash = [ordered]@{
                            'Id'                   = $GId
                            'EntitiesId'           = ' '
                            'EntityName'           = ' '
                            'IsRecursive'          = ' '
                            'Name'                 = ' ' 
                            'Comment'              = ' '
                            'LdapField'            = ' '
                            'LdapValue'            = ' '
                            'LdapGroupDn'          = ' '
                            'DateMod'              = ' '
                            'GroupsId'             = ' '
                            'CompleteName'         = ' '
                            'Level'                = ' '
                            'AncestorsCache'       = ' '
                            'SonsCache'            = ' '
                            'IsRequester'          = ' '
                            'IsAssign'             = ' '
                            'IsTask'               = ' '
                            'IsNotify'             = ' '
                            'IsItemgroup'          = ' '
                            'IsUsergroup'          = ' '
                            'IsManager'            = ' '
                            'DateCreation'         = ' '
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $GroupHash
                        $GroupObjectArray += $object  
                    }
                }
                $GroupObjectArray
                $GroupObjectArray = @()
            }
            GroupName { 
                # here search function 
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}