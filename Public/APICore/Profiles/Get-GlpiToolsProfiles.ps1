<#
.SYNOPSIS
    Function is getting Profile informations from GLPI
.DESCRIPTION
    Function is based on ProfileID which you can find in GLPI website
    Returns object with property's of Profile
.PARAMETER All
    This parameter will return all Profiles from GLPI
.PARAMETER ProfileId
    This parameter can take pipline input, either, you can use this function with -ProfileId keyword.
    Provide to this param Profile ID from GLPI Profiles Bookmark
.PARAMETER ProfileName
    This parameter can take pipline input, either, you can use this function with -ProfileName keyword.
    Provide to this param Profile Name from GLPI Profiles Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with ProfileName Parameter.
    If you want Search for Profile name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with ProfileId Parameter. 
    If you want to get additional parameter of Profile object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsProfiles
    Function gets ProfileId from GLPI from Pipline, and return Profile object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsProfiles
    Function gets ProfileId from GLPI from Pipline (u can pass many ID's like that), and return Profile object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsProfiles -ProfileId 326
    Function gets ProfileId from GLPI which is provided through -ProfileId after Function type, and return Profile object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsProfiles -ProfileId 326, 321
    Function gets ProfileId from GLPI which is provided through -ProfileId keyword after Function type (u can provide many ID's like that), and return Profile object
.INPUTS
    Profile ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Profiles from GLPI
.NOTES
    PSP 04/2019
#>

function Get-GlpiToolsProfiles {
    [CmdletBinding()]
    param (

        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProfileId")]
        [alias('PID')]
        [int[]]$ProfileId,

        [parameter(Mandatory = $true,
            ParameterSetName = "ProfileName")]
        [alias('PN')]
        [string]$ProfileName,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProfileName")]
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
        
        $ProfileObjectArray = @()

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
                    uri     = "$($PathToGlpi)/Profile/?range=0-9999999999999"
                }
                
                $GlpiProfileAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiProfile in $GlpiProfileAll) {
                    $ProfileHash = [ordered]@{ }
                    $ProfileProperties = $GlpiProfile.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ProfileProp in $ProfileProperties) {
                        $ProfileHash.Add($ProfileProp.Name, $ProfileProp.Value)
                    }
                    $object = [pscustomobject]$ProfileHash
                    $ProfileObjectArray += $object 
                }
                $ProfileObjectArray
                $ProfileObjectArray = @()
            }
            ProfileId { 
                foreach ( $CId in $ProfileId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Profile/$($CId)$ParamValue"
                    }

                    Try {
                        $GlpiProfile = Invoke-RestMethod @params -ErrorAction Stop

                        $ProfileHash = [ordered]@{ }
                        $ProfileProperties = $GlpiProfile.PSObject.Properties | Select-Object -Property Name, Value 
                                
                        foreach ($ProfileProp in $ProfileProperties) {
                            $ProfileHash.Add($ProfileProp.Name, $ProfileProp.Value)
                        }
                        $object = [pscustomobject]$ProfileHash
                        $ProfileObjectArray += $object 

                    }
                    Catch {

                        Write-Verbose -Message "Profile ID = $CId is not found"
                        
                    }
                    $ProfileObjectArray
                    $ProfileObjectArray = @()
                }
            }
            ProfileName { 
                Search-GlpiToolsItems -SearchFor Profile -SearchType contains -SearchValue $ProfileName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }


    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}