<#
.SYNOPSIS
    Function is getting Computer informations from GLPI
.DESCRIPTION
    Function is based on ComputerID which you can find in GLPI website
    Returns object with property's of computer
.PARAMETER All
    This parameter will return all computers from GLPI
.PARAMETER ComputerId
    This parameter can take pipline input, either, you can use this function with -ComputerId keyword.
    Provide to this param Computer ID from GLPI Computers Bookmark
.PARAMETER ComputerName
    This parameter can take pipline input, either, you can use this function with -ComputerName keyword.
    Provide to this param Computer Name from GLPI Computers Bookmark
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
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ComputerId")]
        [alias('CID')]
        [string[]]$ComputerId,
        [parameter(Mandatory = $true,
            ParameterSetName = "ComputerName")]
        [alias('CN')]
        [string]$ComputerName,
        [parameter(Mandatory = $false,
            ParameterSetName = "ComputerName")]
        [alias('SIT')]
        [ValidateSet("Yes","No")]
        [string]$SearchInTrash = "No"
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ComputerObjectArray = @()

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
                    uri     = "$($PathToGlpi)/Computer/?range=0-99999999999"
                }
                
                $GlpiComputerAll = Invoke-RestMethod @params

                foreach ($GlpiComputer in $GlpiComputerAll) {
                    $ComputerHash = [ordered]@{
                        'Id'                   = $GlpiComputer.id
                        'Entities_id'          = $GlpiComputer.entities_id
                        'EntityName'           = $GlpiComputer.entities_id | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName
                        'Name'                 = $GlpiComputer.name
                        'Serial'               = $GlpiComputer.serial
                        'OtherSerial'          = $GlpiComputer.otherserial
                        'Contact'              = $GlpiComputer.contact
                        'Contact_num'          = $GlpiComputer.contact_num
                        'Users_id_tech'        = $GlpiComputer.users_id_tech
                        'Groups_id_tech'       = $GlpiComputer.groups_id_tech
                        'Comment'              = $GlpiComputer.comment
                        'Date_mod'             = $GlpiComputer.date_mod
                        'Autoupdatesystems_id' = $GlpiComputer.autoupdatesystems_id
                        'Locations_id'         = $GlpiComputer.locations_id
                        'Domains_id'           = $GlpiComputer.domains_id
                        'Networks_id'          = $GlpiComputer.networks_id 
                        'ComputerModels_id'    = $GlpiComputer.computermodels_id
                        'ComputerModel'        = $GlpiComputer.computermodels_id | Get-GlpiToolsDropdownsComputerModels | Select-Object -ExpandProperty Name
                        'ComputerTypes_id'     = $GlpiComputer.computertypes_id
                        'Is_template'          = $GlpiComputer.is_template
                        'Template_name'        = $GlpiComputer.template_name
                        'Manufacturers_id'     = $GlpiComputer.manufacturers_id
                        'Is_deleted'           = $GlpiComputer.is_deleted
                        'Is_dynamic'           = $GlpiComputer.is_dynamic
                        'Users_id'             = $GlpiComputer.users_id
                        'User'                 = $GlpiComputer.users_id | Get-GlpiToolsUsers | Select-Object -ExpandProperty User
                        'Groups_id'            = $GlpiComputer.groups_id
                        'States_id'            = $GlpiComputer.states_id
                        'Ticket_tco'           = $GlpiComputer.ticket_tco
                        'UUID'                 = $GlpiComputer.uuid
                        'Date_creation'        = $GlpiComputer.date_creation
                        'Is_recursive'         = $GlpiComputer.is_recursive
                    }
                    $object = New-Object -TypeName PSCustomObject -Property $ComputerHash
                    $ComputerObjectArray += $object
                }
                $ComputerObjectArray
                $ComputerObjectArray = @()
            }
            ComputerId { 
                foreach ( $CId in $ComputerId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Computer/$($CId)"
                    }
                
                    try {
                        $GlpiComputer = Invoke-RestMethod @params -ErrorAction Stop
                        $ComputerHash = [ordered]@{
                            'Id'                   = $GlpiComputer.id
                            'Entities_id'          = $GlpiComputer.entities_id
                            'EntityName'           = $GlpiComputer.entities_id | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName
                            'Name'                 = $GlpiComputer.name
                            'Serial'               = $GlpiComputer.serial
                            'OtherSerial'          = $GlpiComputer.otherserial
                            'Contact'              = $GlpiComputer.contact
                            'Contact_num'          = $GlpiComputer.contact_num
                            'Users_id_tech'        = $GlpiComputer.users_id_tech
                            'Groups_id_tech'       = $GlpiComputer.groups_id_tech
                            'Comment'              = $GlpiComputer.comment
                            'Date_mod'             = $GlpiComputer.date_mod
                            'Autoupdatesystems_id' = $GlpiComputer.autoupdatesystems_id
                            'Locations_id'         = $GlpiComputer.locations_id
                            'Domains_id'           = $GlpiComputer.domains_id
                            'Networks_id'          = $GlpiComputer.networks_id 
                            'ComputerModels_id'    = $GlpiComputer.computermodels_id
                            'ComputerModel'        = $GlpiComputer.computermodels_id | Get-GlpiToolsDropdownsComputerModels | Select-Object -ExpandProperty Name
                            'ComputerTypes_id'     = $GlpiComputer.computertypes_id
                            'Is_template'          = $GlpiComputer.is_template
                            'Template_name'        = $GlpiComputer.template_name
                            'Manufacturers_id'     = $GlpiComputer.manufacturers_id
                            'Is_deleted'           = $GlpiComputer.is_deleted
                            'Is_dynamic'           = $GlpiComputer.is_dynamic
                            'Users_id'             = $GlpiComputer.users_id
                            'User'                 = $GlpiComputer.users_id | Get-GlpiToolsUsers | Select-Object -ExpandProperty User
                            'Groups_id'            = $GlpiComputer.groups_id
                            'States_id'            = $GlpiComputer.states_id
                            'Ticket_tco'           = $GlpiComputer.ticket_tco
                            'UUID'                 = $GlpiComputer.uuid
                            'Date_creation'        = $GlpiComputer.date_creation
                            'Is_recursive'         = $GlpiComputer.is_recursive
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $ComputerHash
                        $ComputerObjectArray += $object
                    }
                    catch {
                        $ComputerHash = [ordered]@{
                            'Id'                   = $CId
                            'Entities_id'          = ' '
                            'EntityName'           = ' '
                            'Name'                 = ' '
                            'Serial'               = ' '
                            'OtherSerial'          = ' '
                            'Contact'              = ' '
                            'Contact_num'          = ' '
                            'Users_id_tech'        = ' '
                            'Groups_id_tech'       = ' '
                            'Comment'              = ' '
                            'Date_mod'             = ' '
                            'Autoupdatesystems_id' = ' '
                            'Locations_id'         = ' '
                            'Domains_id'           = ' '
                            'Networks_id'          = ' '
                            'ComputerModels_id'    = ' '
                            'ComputerModel'        = ' '
                            'ComputerTypes_id'     = ' '
                            'Is_template'          = ' '
                            'Template_name'        = ' '
                            'Manufacturers_id'     = ' '
                            'Is_deleted'           = ' '
                            'Is_dynamic'           = ' '
                            'Users_id'             = ' '
                            'User'                 = ' '
                            'Groups_id'            = ' '
                            'States_id'            = ' '
                            'Ticket_tco'           = ' '
                            'UUID'                 = ' '
                            'Date_creation'        = ' '
                            'Is_recursive'         = ' '
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $ComputerHash
                        $ComputerObjectArray += $object  
                    }
                }
                $ComputerObjectArray
                $ComputerObjectArray = @()
            }
            ComputerName { 
                Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue $ComputerName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}