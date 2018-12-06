<#
.SYNOPSIS
    Function is getting Computer informations from GLPI
.DESCRIPTION
    Function is based on ComputerID which you can find in GLPI website
    Returns object with property's of computer
.PARAMETER ComputerId
    This parameter can take pipline input, either, you can use this function with -ComputerId keyword.
    Provide to this param Computer ID from GLPI Computers Bookmark
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsComputers
    Function gets ComputerId from GLPI from Pipline, and return Computer object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsComputers
    Function gets ComputerId from GLPI from Pipline (u can pass many ID's like that), and return Computer object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsComputers -ComputerId 326
    Function gets ComputerId from GLPI which is provided through -ComputerId after Function type, and return Computer object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsComputers -ComputerId 326, 321
    Function gets ComputerId from GLPI which is provided through -ComputerId keyword after Function type (u can provide many ID's like that), and return Computer object
.INPUTS
    Computer ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of computers from GLPI
.NOTES
    PSP 12/2018
#>

function Get-GlpiToolsComputers {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ValueFromPipeline = $true)]
        [string[]]$ComputerId
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
    }
    
    process {
        $ComputerObjectArray = @()
        foreach ( $Id in $ComputerId ) {
            $params = @{
                headers = @{
                    'Content-Type'  = 'application/json'
                    'App-Token'     = $AppToken
                    'Session-Token' = $SessionToken
                }
                method  = 'get'
                uri     = "$($PathToGlpi)/Computer/$($Id)"
            }
            
            try {
                $GlpiComputer = Invoke-RestMethod @params -ErrorAction Stop
            
                $GlpiId = $GlpiComputer | Select-Object -ExpandProperty id
                $EntityId = $GlpiComputer | Select-Object -ExpandProperty entities_id
                $Name = $GlpiComputer | Select-Object -ExpandProperty name
                $User = $GlpiComputer | Select-Object -ExpandProperty users_id | Get-GlpiToolsUsers | Select-Object -ExpandProperty User # HERE DELETE THIS
                $Serial = $GlpiComputer | Select-Object -ExpandProperty serial
                $OtherSerial = $GlpiComputer | Select-Object -ExpandProperty otherserial
                $Contact = $GlpiComputer | Select-Object -ExpandProperty contact
                $LocationId = $GlpiComputer | Select-Object -ExpandProperty locations_id
                $ComputerModelId = $GlpiComputer | Select-Object -ExpandProperty computermodels_id
                $ComputerTypeId = $GlpiComputer | Select-Object -ExpandProperty computertypes_id

                $object = New-Object -TypeName PSCustomObject
                $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $GlpiId
                $object | Add-Member -Name 'EntityId' -MemberType NoteProperty -Value $EntityId 
                $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value $Name
                $object | Add-Member -Name 'User' -MemberType NoteProperty -Value $User
                $object | Add-Member -Name 'Serial' -MemberType NoteProperty -Value $Serial
                $object | Add-Member -Name 'OtherSerial' -MemberType NoteProperty -Value $OtherSerial
                $object | Add-Member -Name 'Contact' -MemberType NoteProperty -Value $Contact
                $object | Add-Member -Name 'LocationId' -MemberType NoteProperty -Value $LocationId
                $object | Add-Member -Name 'ComputerModelId' -MemberType NoteProperty -Value $ComputerModelId
                $object | Add-Member -Name 'ComputerTypeId' -MemberType NoteProperty -Value $ComputerTypeId
                $ComputerObjectArray += $object 
            }
            catch {

                $object = New-Object -TypeName PSCustomObject
                $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
                $object | Add-Member -Name 'EntityId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'User' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Serial' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'OtherSerial' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Contact' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'LocationId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'ComputerModelId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'ComputerTypeId' -MemberType NoteProperty -Value ''
                $ComputerObjectArray += $object 
            }
        }
        $ComputerObjectArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}