<#
.SYNOPSIS
    Function is getting Calendars informations from GLPI
.DESCRIPTION
    Function is based on CalendarId which you can find in GLPI website
    Returns object with property's of Calendars
.PARAMETER All
    This parameter will return all Calendars from GLPI
.PARAMETER CalendarId
    This parameter can take pipeline input, either, you can use this function with -CalendarId keyword.
    Provide to this param CalendarId from GLPI Calendars Bookmark
.PARAMETER Raw
    Parameter which you can use with CalendarId Parameter.
    CalendarId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER CalendarName
    This parameter can take pipeline input, either, you can use this function with -CalendarId keyword.
    Provide to this param Calendars Name from GLPI Calendars Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCalendars -All
    Example will return all Calendars from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsCalendars
    Function gets CalendarId from GLPI from pipeline, and return Calendars object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsCalendars
    Function gets CalendarId from GLPI from pipeline (u can pass many ID's like that), and return Calendars object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCalendars -CalendarId 326
    Function gets CalendarId from GLPI which is provided through -CalendarId after Function type, and return Calendars object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsCalendars -CalendarId 326, 321
    Function gets Calendars Id from GLPI which is provided through -CalendarId keyword after Function type (u can provide many ID's like that), and return Calendars object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsCalendars -CalendarName Fusion
    Example will return glpi Calendars, but what is the most important, Calendars will be shown exactly as you see in glpi dropdown Calendars.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Calendars ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Calendars from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsCalendars {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "CalendarId")]
        [alias('CID')]
        [string[]]$CalendarId,
        [parameter(Mandatory = $false,
            ParameterSetName = "CalendarId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "CalendarName")]
        [alias('CN')]
        [string]$CalendarName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $CalendarsArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/calendar/?range=0-9999999999999"
                }
                
                $CalendarsAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Calendar in $CalendarsAll) {
                    $CalendarHash = [ordered]@{ }
                    $CalendarProperties = $Calendar.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($CalendarProp in $CalendarProperties) {
                        $CalendarHash.Add($CalendarProp.Name, $CalendarProp.Value)
                    }
                    $object = [pscustomobject]$CalendarHash
                    $CalendarsArray.Add($object)
                }
                $CalendarsArray
                $CalendarsArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            CalendarId { 
                foreach ( $CId in $CalendarId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/calendar/$($CId)"
                    }

                    Try {
                        $Calendar = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $CalendarHash = [ordered]@{ }
                            $CalendarProperties = $Calendar.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CalendarProp in $CalendarProperties) {
                                $CalendarHash.Add($CalendarProp.Name, $CalendarProp.Value)
                            }
                            $object = [pscustomobject]$CalendarHash
                            $CalendarsArray.Add($object)
                        } else {
                            $CalendarHash = [ordered]@{ }
                            $CalendarProperties = $Calendar.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($CalendarProp in $CalendarProperties) {

                                $CalendarPropNewValue = Get-GlpiToolsParameters -Parameter $CalendarProp.Name -Value $CalendarProp.Value

                                $CalendarHash.Add($CalendarProp.Name, $CalendarPropNewValue)
                            }
                            $object = [pscustomobject]$CalendarHash
                            $CalendarsArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Calendar ID = $CId is not found"
                        
                    }
                    $CalendarsArray
                    $CalendarsArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            CalendarName { 
                Search-GlpiToolsItems -SearchFor calendar -SearchType contains -SearchValue $CalendarName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}