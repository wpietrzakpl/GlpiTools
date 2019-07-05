<#
.SYNOPSIS
    Function based on GLPI User ID, returns Name and Surname of desired user.
.DESCRIPTION
    Function based on GLPI User ID, returns Name and Surname of desired user.
.PARAMETER All
    This parameter will return all users from GLPI
.PARAMETER UserId
    This parameter can take pipline input, either, you can use this function with -UserId keyword.
    Provide to this param User ID from GLPI Users Bookmark
.PARAMETER Raw
    Parameter which you can use with UserId Parameter.
    UserId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER UserName
    Provide to this param User Name from GLPI Users Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with UserName Parameter.
    If you want Search for user name in trash, that parameter allow you to do it.
.EXAMPLE
    PS C:\> Get-GlpiToolsUsers -All
    Example will return all users from Users. 
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsUsers
    Function gets UserID from GLPI from Pipline, and return User object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsUsers
    Function gets UserID from GLPI from Pipline (u can pass many ID's like that), and return User object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsUsers -UserId 326
    Function gets UserID from GLPI which is provided through -UserId after Function type, and return User object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsUsers -UserId 326, 321
    Function gets UserID from GLPI which is provided through -UserId keyword after Function type (u can provide many ID's like that), and return User object
.EXAMPLE
    PS C:\> Get-GlpiToolsUsers -UserId 234 -Raw
    Example will show user with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsUsers -Raw
    Example will show user with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsUsers -UserName glpi
    Example will return glpi user, but what is the most important, user will be shown exactly as you see in glpi users tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsUsers -UserName glpi -SearchInTrash Yes
    Example will return glpi user, but from trash
.INPUTS
    User ID which you can find in GLPI, or use this Function to convert ID returned from other Functions.
.OUTPUTS
    Function returns PSCustomObject with users data from GLPI.
.NOTES
    PSP 12/2018
#>

function Get-GlpiToolsUsers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "UserId")]
        [alias('UID')]
        [string[]]$UserId,
        [parameter(Mandatory = $false,
            ParameterSetName = "UserId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "UserName")]
        [alias('UN')]
        [string]$UserName,
        [parameter(Mandatory = $false,
            ParameterSetName = "UserName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No"
    )
    begin {

        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $UserObjectArray = @()
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
                    uri     = "$($PathToGlpi)/User/?range=0-9999999999999"
                }
                
                $GlpiUsersAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiUser in $GlpiUsersAll) {
                    $UserHash = [ordered]@{ }
                            $UserProperties = $GlpiUser.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($UserProp in $UserProperties) {
                                $UserHash.Add($UserProp.Name, $UserProp.Value)
                            }
                            $object = [pscustomobject]$UserHash
                            $UserObjectArray += $object 
                }
                $UserObjectArray
                $UserObjectArray = @()
            }
            UserId {
                foreach ( $UId in $UserId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/User/$($UId)"
                    }

                    Try {
                        $GlpiUser = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $UserHash = [ordered]@{ }
                            $UserProperties = $GlpiUser.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($UserProp in $UserProperties) {
                                $UserHash.Add($UserProp.Name, $UserProp.Value)
                            }
                            $object = [pscustomobject]$UserHash
                            $UserObjectArray += $object 
                        } else {
                            $UserHash = [ordered]@{ }
                            $UserProperties = $GlpiUser.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($UserProp in $UserProperties) {

                                $UserPropNewValue = Get-GlpiToolsParameters -Parameter $UserProp.Name -Value $UserProp.Value

                                $UserHash.Add($UserProp.Name, $UserPropNewValue)
                            }
                            $object = [pscustomobject]$UserHash
                            $UserObjectArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "User ID = $UId is not found"
                        
                    }
                    $UserObjectArray
                    $UserObjectArray = @()
                }
            }
            UserName {
                Search-GlpiToolsItems -SearchFor User -SearchType contains -SearchValue $UserName -SearchInTrash $SearchInTrash
            }
            Default {}
        }
    }
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}