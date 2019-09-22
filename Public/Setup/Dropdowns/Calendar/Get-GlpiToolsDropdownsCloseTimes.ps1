<#
.SYNOPSIS
    Function is getting Close Times informations from GLPI
.DESCRIPTION
    Function is based on CloseTimeId which you can find in GLPI website
    Returns object with property's of Close Times
.PARAMETER All
    This parameter will return all Close Times from GLPI
.PARAMETER CloseTimeId
    This parameter can take pipeline input, either, you can use this function with -CloseTimeId keyword.
    Provide to this param CloseTimeId from GLPI Close Times Bookmark
.PARAMETER Raw
    Parameter which you can use with CloseTimeId Parameter.
    CloseTimeId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER CloseTimeName
    This parameter can take pipeline input, either, you can use this function with -CloseTimeId keyword.
    Provide to this param Close Times Name from GLPI Close Times Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCloseTimes -All
    Example will return all Close Times from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsCloseTimes
    Function gets CloseTimeId from GLPI from pipeline, and return Close Times object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsCloseTimes
    Function gets CloseTimeId from GLPI from pipeline (u can pass many ID's like that), and return Close Times object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCloseTimes -CloseTimeId 326
    Function gets CloseTimeId from GLPI which is provided through -CloseTimeId after Function type, and return Close Times object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsCloseTimes -CloseTimeId 326, 321
    Function gets Close Times Id from GLPI which is provided through -CloseTimeId keyword after Function type (u can provide many ID's like that), and return Close Times object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCloseTimes -CloseTimeName Fusion
    Example will return glpi Close Times, but what is the most important, Close Times will be shown exactly as you see in glpi dropdown Close Times.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Close Times ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Close Times from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsCloseTimes {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "CloseTimeId")]
        [alias('CTID')]
        [string[]]$CloseTimeId,
        [parameter(Mandatory = $false,
            ParameterSetName = "CloseTimeId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "CloseTimeName")]
        [alias('CTN')]
        [string]$CloseTimeName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $CloseTimesArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/holiday/?range=0-9999999999999"
                }
                
                $CloseTimesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($CloseTime in $CloseTimesAll) {
                    $CloseTimeHash = [ordered]@{ }
                    $CloseTimeProperties = $CloseTime.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($CloseTimeProp in $CloseTimeProperties) {
                        $CloseTimeHash.Add($CloseTimeProp.Name, $CloseTimeProp.Value)
                    }
                    $object = [pscustomobject]$CloseTimeHash
                    $CloseTimesArray.Add($object)
                }
                $CloseTimesArray
                $CloseTimesArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            CloseTimeId { 
                foreach ( $CTId in $CloseTimeId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/holiday/$($CTId)"
                    }

                    Try {
                        $CloseTime = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $CloseTimeHash = [ordered]@{ }
                            $CloseTimeProperties = $CloseTime.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CloseTimeProp in $CloseTimeProperties) {
                                $CloseTimeHash.Add($CloseTimeProp.Name, $CloseTimeProp.Value)
                            }
                            $object = [pscustomobject]$CloseTimeHash
                            $CloseTimesArray.Add($object)
                        } else {
                            $CloseTimeHash = [ordered]@{ }
                            $CloseTimeProperties = $CloseTime.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CloseTimeProp in $CloseTimeProperties) {

                                $CloseTimePropNewValue = Get-GlpiToolsParameters -Parameter $CloseTimeProp.Name -Value $CloseTimeProp.Value

                                $CloseTimeHash.Add($CloseTimeProp.Name, $CloseTimePropNewValue)
                            }
                            $object = [pscustomobject]$CloseTimeHash
                            $CloseTimesArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Close Time ID = $CTId is not found"
                        
                    }
                    $CloseTimesArray
                    $CloseTimesArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            CloseTimeName { 
                Search-GlpiToolsItems -SearchFor holiday -SearchType contains -SearchValue $CloseTimeName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}