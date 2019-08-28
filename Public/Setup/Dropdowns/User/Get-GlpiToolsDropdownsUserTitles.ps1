<#
.SYNOPSIS
    Function is getting User Titles informations from GLPI
.DESCRIPTION
    Function is based on UserTitleId which you can find in GLPI website
    Returns object with property's of User Titles
.PARAMETER All
    This parameter will return all User Titles from GLPI
.PARAMETER UserTitleId
    This parameter can take pipline input, either, you can use this function with -UserTitleId keyword.
    Provide to this param UserTitleId from GLPI User Titles Bookmark
.PARAMETER Raw
    Parameter which you can use with UserTitleId Parameter.
    UserTitleId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER UserTitleName
    This parameter can take pipline input, either, you can use this function with -UserTitleId keyword.
    Provide to this param User Titles Name from GLPI User Titles Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUserTitles -All
    Example will return all User Titles from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsUserTitles
    Function gets UserTitleId from GLPI from Pipline, and return User Titles object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsUserTitles
    Function gets UserTitleId from GLPI from Pipline (u can pass many ID's like that), and return User Titles object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUserTitles -UserTitleId 326
    Function gets UserTitleId from GLPI which is provided through -UserTitleId after Function type, and return User Titles object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsUserTitles -UserTitleId 326, 321
    Function gets User TitlesId from GLPI which is provided through -UserTitleId keyword after Function type (u can provide many ID's like that), and return User Titles object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsUserTitles -UserTitleName Fusion
    Example will return glpi User Titles, but what is the most important, User Titles will be shown exactly as you see in glpi dropdown User Titles.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    User Titles ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of User Titles from GLPI
.NOTES
    PSP 08/2019
#>

function Get-GlpiToolsDropdownsUserTitles {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "UserTitleId")]
        [alias('UTID')]
        [string[]]$UserTitleId,
        [parameter(Mandatory = $false,
            ParameterSetName = "UserTitleId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "UserTitleName")]
        [alias('UTN')]
        [string]$UserTitleName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $UserTitleArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/UserTitle/?range=0-9999999999999"
                }
                
                $UserTitlesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($UserTitle in $UserTitlesAll) {
                    $UserTitleHash = [ordered]@{ }
                    $UserTitleProperties = $UserTitle.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($UserTitleProp in $UserTitleProperties) {
                        $UserTitleHash.Add($UserTitleProp.Name, $UserTitleProp.Value)
                    }
                    $object = [pscustomobject]$UserTitleHash
                    $UserTitleArray.Add($object)
                }
                $UserTitleArray
                $UserTitleArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            UserTitleId { 
                foreach ( $UTId in $UserTitleId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/UserTitle/$($UTId)"
                    }

                    Try {
                        $UserTitle = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $UserTitleHash = [ordered]@{ }
                            $UserTitleProperties = $UserTitle.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($UserTitleProp in $UserTitleProperties) {
                                $UserTitleHash.Add($UserTitleProp.Name, $UserTitleProp.Value)
                            }
                            $object = [pscustomobject]$UserTitleHash
                            $UserTitleArray.Add($object)
                        } else {
                            $UserTitleHash = [ordered]@{ }
                            $UserTitleProperties = $UserTitle.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($UserTitleProp in $UserTitleProperties) {

                                $UserTitlePropNewValue = Get-GlpiToolsParameters -Parameter $UserTitleProp.Name -Value $UserTitleProp.Value

                                $UserTitleHash.Add($UserTitleProp.Name, $UserTitlePropNewValue)
                            }
                            $object = [pscustomobject]$UserTitleHash
                            $UserTitleArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "User Titles ID = $UTId is not found"
                        
                    }
                    $UserTitleArray
                    $UserTitleArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            UserTitleName { 
                Search-GlpiToolsItems -SearchFor Usertitle -SearchType contains -SearchValue $UserTitleName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}