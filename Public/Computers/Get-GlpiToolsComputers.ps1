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
            
                $Id = $GlpiComputer | Select-Object -ExpandProperty id
                $EntitiesId = $GlpiComputer | Select-Object -ExpandProperty entities_id
                $Name = $GlpiComputer | Select-Object -ExpandProperty name
                $Serial = $GlpiComputer | Select-Object -ExpandProperty serial
                $OtherSerial = $GlpiComputer | Select-Object -ExpandProperty otherserial
                $Contact = $GlpiComputer | Select-Object -ExpandProperty contact
                $ContactNum = $GlpiComputer | Select-Object -ExpandProperty contact_num
                $UsersIdTech = $GlpiComputer | Select-Object -ExpandProperty users_id_tech
                $GroupsIdTech = $GlpiComputer | Select-Object -ExpandProperty groups_id_tech
                $Comment = $GlpiComputer | Select-Object -ExpandProperty comment
                $DateMod = $GlpiComputer | Select-Object -ExpandProperty date_mod
                $Autoupdatesystems_id = $GlpiComputer | Select-Object -ExpandProperty autoupdatesystems_id
                $LocationsId = $GlpiComputer | Select-Object -ExpandProperty locations_id
                $DomainsId = $GlpiComputer | Select-Object -ExpandProperty domains_id
                $Networks_id = $GlpiComputer | Select-Object -ExpandProperty networks_id 
                $ComputerModelsId = $GlpiComputer | Select-Object -ExpandProperty computermodels_id
                $ComputerTypesId = $GlpiComputer | Select-Object -ExpandProperty computertypes_id
                $IsTemplate = $GlpiComputer | Select-Object -ExpandProperty is_template
                $TemplateName = $GlpiComputer | Select-Object -ExpandProperty template_name
                $Manufacturers_id = $GlpiComputer | Select-Object -ExpandProperty manufacturers_id
                $IsDeleted = $GlpiComputer | Select-Object -ExpandProperty is_deleted
                $IsDynamic = $GlpiComputer | Select-Object -ExpandProperty is_dynamic
                $UsersId = $GlpiComputer | Select-Object -ExpandProperty users_id
                $User = $GlpiComputer | Select-Object -ExpandProperty users_id | Get-GlpiToolsUsers | Select-Object -ExpandProperty User
                $GroupsIs = $GlpiComputer | Select-Object -ExpandProperty groups_id
                $StatesId = $GlpiComputer | Select-Object -ExpandProperty states_id
                $TicketTco = $GlpiComputer | Select-Object -ExpandProperty ticket_tco
                $UUID = $GlpiComputer | Select-Object -ExpandProperty uuid
                $DateCreation = $GlpiComputer | Select-Object -ExpandProperty date_creation
                $IsRecursive = $GlpiComputer | Select-Object -ExpandProperty is_recursive


                $object = New-Object -TypeName PSCustomObject
                $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
                $object | Add-Member -Name 'EntitiesId' -MemberType NoteProperty -Value $EntitiesId 
                $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value $Name
                $object | Add-Member -Name 'Serial' -MemberType NoteProperty -Value $Serial
                $object | Add-Member -Name 'OtherSerial' -MemberType NoteProperty -Value $OtherSerial
                $object | Add-Member -Name 'Contact' -MemberType NoteProperty -Value $Contact
                $object | Add-Member -Name 'ContactNum' -MemberType NoteProperty -Value $ContactNum
                $object | Add-Member -Name 'UsersIdTech' -MemberType NoteProperty -Value $UsersIdTech
                $object | Add-Member -Name 'GroupsIdTech' -MemberType NoteProperty -Value $GroupsIdTech
                $object | Add-Member -Name 'Comment' -MemberType NoteProperty -Value $Comment
                $object | Add-Member -Name 'DateMod' -MemberType NoteProperty -Value $DateMod
                $object | Add-Member -Name 'Autoupdatesystems_id' -MemberType NoteProperty -Value $Autoupdatesystems_id
                $object | Add-Member -Name 'LocationsId' -MemberType NoteProperty -Value $LocationsId
                $object | Add-Member -Name 'DomainsId' -MemberType NoteProperty -Value $DomainsId
                $object | Add-Member -Name 'Networks_id' -MemberType NoteProperty -Value $Networks_id
                $object | Add-Member -Name 'ComputerModelsId' -MemberType NoteProperty -Value $ComputerModelsId
                $object | Add-Member -Name 'ComputerTypesId' -MemberType NoteProperty -Value $ComputerTypesId
                $object | Add-Member -Name 'IsTemplate' -MemberType NoteProperty -Value $IsTemplate
                $object | Add-Member -Name 'TemplateName' -MemberType NoteProperty -Value $TemplateName
                $object | Add-Member -Name 'Manufacturers_id' -MemberType NoteProperty -Value $Manufacturers_id
                $object | Add-Member -Name 'IsDeleted' -MemberType NoteProperty -Value $IsDeleted
                $object | Add-Member -Name 'IsDynamic' -MemberType NoteProperty -Value $IsDynamic
                $object | Add-Member -Name 'UsersId' -MemberType NoteProperty -Value $UsersId
                $object | Add-Member -Name 'User' -MemberType NoteProperty -Value $User
                $object | Add-Member -Name 'GroupsIs' -MemberType NoteProperty -Value $GroupsIs
                $object | Add-Member -Name 'StatesId' -MemberType NoteProperty -Value $StatesId
                $object | Add-Member -Name 'TicketTco' -MemberType NoteProperty -Value $TicketTco
                $object | Add-Member -Name 'UUID' -MemberType NoteProperty -Value $UUID
                $object | Add-Member -Name 'DateCreation' -MemberType NoteProperty -Value $DateCreation
                $object | Add-Member -Name 'IsRecursive' -MemberType NoteProperty -Value $IsRecursive
                $ComputerObjectArray += $object 
            }
            catch {

                $object = New-Object -TypeName PSCustomObject
                $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
                $object | Add-Member -Name 'EntitiesId' -MemberType NoteProperty -Value '' 
                $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Serial' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'OtherSerial' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Contact' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'ContactNum' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'UsersIdTech' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'GroupsIdTech' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Comment' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'DateMod' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Autoupdatesystems_id' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'LocationsId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'DomainsId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Networks_id' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'ComputerModelsId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'ComputerTypesId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'IsTemplate' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'TemplateName' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'Manufacturers_id' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'IsDeleted' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'IsDynamic' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'UsersId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'User' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'GroupsIs' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'StatesId' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'TicketTco' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'UUID' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'DateCreation' -MemberType NoteProperty -Value ''
                $object | Add-Member -Name 'IsRecursive' -MemberType NoteProperty -Value ''
                $ComputerObjectArray += $object 
            }
        }
        $ComputerObjectArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}