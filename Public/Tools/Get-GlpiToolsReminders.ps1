<#
.SYNOPSIS
    Function is getting Reminders informations from GLPI
.DESCRIPTION
    Function is based on ReminderId which you can find in GLPI website
    Returns object with property's of Reminders
.PARAMETER All
    This parameter will return all Reminders from GLPI
.PARAMETER ReminderId
    This parameter can take pipline input, either, you can use this function with -ReminderId keyword.
    Provide to this param ReminderId from GLPI Reminders Bookmark
.PARAMETER Raw
    Parameter which you can use with ReminderId Parameter.
    ReminderId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ReminderName
    This parameter can take pipline input, either, you can use this function with -ReminderId keyword.
    Provide to this param Reminders Name from GLPI Reminders Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsReminders -All
    Example will return all Reminders from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsReminders
    Function gets ReminderId from GLPI from Pipline, and return Reminders object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsReminders
    Function gets ReminderId from GLPI from Pipline (u can pass many ID's like that), and return Reminders object
.EXAMPLE
    PS C:\> Get-GlpiToolsReminders -ReminderId 326
    Function gets ReminderId from GLPI which is provided through -ReminderId after Function type, and return Reminders object
.EXAMPLE 
    PS C:\> Get-GlpiToolsReminders -ReminderId 326, 321
    Function gets Reminders Id from GLPI which is provided through -ReminderId keyword after Function type (u can provide many ID's like that), and return Reminders object
.EXAMPLE
    PS C:\> Get-GlpiToolsReminders -ReminderName Fusion
    Example will return glpi Reminders, but what is the most important, Reminders will be shown exactly as you see in glpi dropdown Reminders.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    Reminders ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Reminders from GLPI
.NOTES
    PSP 11/2019
#>

function Get-GlpiToolsReminders {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ReminderId")]
        [alias('RID')]
        [string[]]$ReminderId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ReminderId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "ReminderName")]
        [alias('RN')]
        [string]$ReminderName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $RemindersArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/reminder/?range=0-9999999999999"
                }
                
                $RemindersAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($Reminder in $RemindersAll) {
                    $ReminderHash = [ordered]@{ }
                    $ReminderProperties = $Reminder.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ReminderProp in $ReminderProperties) {
                        $ReminderHash.Add($ReminderProp.Name, $ReminderProp.Value)
                    }
                    $object = [pscustomobject]$ReminderHash
                    $RemindersArray.Add($object)
                }
                $RemindersArray
                $RemindersArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ReminderId { 
                foreach ( $RId in $ReminderId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/reminder/$($RId)"
                    }

                    Try {
                        $Reminder = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ReminderHash = [ordered]@{ }
                            $ReminderProperties = $Reminder.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ReminderProp in $ReminderProperties) {
                                $ReminderHash.Add($ReminderProp.Name, $ReminderProp.Value)
                            }
                            $object = [pscustomobject]$ReminderHash
                            $RemindersArray.Add($object)
                        } else {
                            $ReminderHash = [ordered]@{ }
                            $ReminderProperties = $Reminder.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ReminderProp in $ReminderProperties) {

                                $ReminderPropNewValue = Get-GlpiToolsParameters -Parameter $ReminderProp.Name -Value $ReminderProp.Value

                                $ReminderHash.Add($ReminderProp.Name, $ReminderPropNewValue)
                            }
                            $object = [pscustomobject]$ReminderHash
                            $RemindersArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Reminder ID = $RId is not found"
                        
                    }
                    $RemindersArray
                    $RemindersArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ReminderName { 
                Search-GlpiToolsItems -SearchFor reminder -SearchType contains -SearchValue $ReminderName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}