<#
.SYNOPSIS
    Function gets list of Search Options for specific Search in GLPI
.DESCRIPTION
    Function gets list of Search Options for specific Search in GLPI
    Parameters are the names of options in GLPI
    Remember that, names used in cmdlet coming from glpi URL, and can be hard to understand, but most of them are intuitional.
    To get name you always have to look at the URL in GLPI, for example "http://glpi/front/computer.php" where "computer" is the name to use in parameter.
.PARAMETER ListOptionsFor
    You can use this function with -ListOptionsFor parameter.
    Using TAB button you can choose desired option.
.EXAMPLE
    PS C:\WINDOWS\system32> Get-GlpiToolsListSearchOptions -ListOptionsFor DeviceCase
    Example will return object which is list of Search Option for Setup -> Components Tab from GLPI
.INPUTS
    None
.OUTPUTS
    Function returns PSCustomObject with property's of List Options from GLPI
.NOTES
    PSP 03/2019
#>

function Get-GlpiToolsListSearchOptions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [ValidateSet("Computer",
            "Monitor",
            "Software",
            "NetworkEquipment",
            "Peripheral",
            "Printer",
            "CartridgeItem",
            "ConsumableItem",
            "Phone",
            "Rack",
            "Enclosure",
            "Pdu",
            "Ticket",
            "Problem",
            "Change",
            "Ticketrecurrent",
            "Softwarelicense",
            "Supplier",
            "Budget",
            "Users",
            "Group",
            "Softwarelicense",
            "Budget",
            "Supplier",
            "Contact",
            "Contract",
            "Document",
            "Line",
            "Certificate",
            "Datacenter",
            "Project",
            "Reminder",
            "Rssfeed",
            "Knowbaseitem",
            "Reservationitem",
            "Report",
            "Savedsearch",
            "User",
            "Group",
            "Entity",
            "Rule",
            "Profile",
            "Queuednotification",
            "Savedsearch",
            "Slm",
            "Fieldunicity",
            "Crontask",
            "Mailcollector",
            "Link",
            "Plugin",
            "Location",
            "State",
            "Manufacturer",
            "Blacklist",
            "Blacklistedmailcontent",
            "Itilcategory",
            "Taskcategory",
            "Tasktemplate",
            "Solutiontype",
            "Requesttype",
            "Solutiontemplate",
            "Projectstate",
            "Projecttype",
            "Projecttasktype",
            "Projecttasktemplate",
            "Computertype",
            "Networkequipmenttype",
            "Printertype",
            "Monitortype",
            "Peripheraltype",
            "Phonetype",
            "Softwarelicensetype",
            "Cartridgeitemtype",
            "Consumableitemtype",
            "Contracttype",
            "Contacttype",
            "DeviceGenericType",
            "DeviceSensorType",
            "DeviceMemoryType",
            "Suppliertype",
            "Interfacetype",
            "DeviceCaseType",
            "Phonepowersupply",
            "Filesystem",
            "Certificatetype",
            "Budgettype",
            "DeviceSimcardType",
            "Linetype",
            "Racktype",
            "Computermodel",
            "Networkequipmentmodel",
            "Printermodel",
            "Monitormodel",
            "Peripheralmodel",
            "Phonemodel",
            "DeviceCaseModel",
            "DeviceControlModel",
            "DeviceDriveModel",
            "DeviceGenericModel",
            "DeviceGraphicCardModel",
            "DeviceHardDriveModel",
            "DeviceMemoryModel",
            "DeviceMotherBoardModel",
            "DeviceNetworkCardModel",
            "DevicePciModel",
            "DevicePowerSupplyModel",
            "DeviceProcessorModel",
            "DeviceSoundCardModel",
            "DeviceSensorModel",
            "Rackmodel",
            "Enclosuremodel",
            "Pdumodel",
            "Virtualmachinetype",
            "Virtualmachinesystem",
            "Virtualmachinestate",
            "Documentcategory",
            "Documenttype",
            "Businesscriticity",
            "Knowbaseitemcategory",
            "Calendar",
            "Holiday",
            "Operatingsystem",
            "Operatingsystemversion",
            "Operatingsystemservicepack",
            "Operatingsystemarchitecture",
            "Operatingsystemedition",
            "Operatingsystemkernel",
            "Operatingsystemkernelversion",
            "Autoupdatesystem",
            "Networkinterface",
            "Netpoint",
            "Domain",
            "Network",
            "Vlan",
            "Lineoperator",
            "Ipnetwork",
            "Fqdn",
            "Wifinetwork",
            "Networkname",
            "Softwarecategory",
            "Usertitle",
            "Usercategory",
            "Rulerightparameter",
            "Fieldblacklist",
            "Ssovariable",
            "Plug",
            "DeviceBattery",
            "DeviceCase",
            "DeviceControl",
            "DeviceDrive",
            "DeviceFirmware",
            "DeviceGeneric",
            "DeviceGraphicCard",
            "DeviceHardDrive",
            "DeviceMemory",
            "DeviceNetworkCard",
            "DevicePci",
            "DevicePowerSupply",
            "DeviceProcessor",
            "DeviceSensor",
            "DeviceSimcard",
            "DeviceSoundCard",
            "DeviceMotherboard",
            "DeviceBattery",
            "DeviceCase",
            "DeviceControl",
            "DeviceDrive",
            "DeviceFirmware",
            "DeviceGeneric",
            "DeviceGraphicCard",
            "DeviceHardDrive",
            "DeviceMemory",
            "DeviceNetworkCard",
            "DevicePci",
            "DevicePowerSupply",
            "DeviceProcessor",
            "DeviceSensor",
            "DeviceSimcard",
            "DeviceSoundCard",
            "DeviceMotherboard",
            "DeviceBattery",
            "DeviceCase",
            "DeviceControl",
            "DeviceDrive",
            "DeviceFirmware",
            "DeviceGeneric",
            "DeviceGraphicCard",
            "DeviceHardDrive",
            "DeviceMemory",
            "DeviceNetworkCard",
            "DevicePci",
            "DevicePowerSupply",
            "DeviceProcessor",
            "DeviceSensor",
            "DeviceSimcard",
            "DeviceSoundCard",
            "DeviceMotherboard",
            "Notificationtemplate",
            "Notification")]
        [String]$ListOptionsFor

    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        $SearchOptionsArray = @()
    }
    
    process {
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri = "$($PathToGlpi)/listSearchOptions/$($ListOptionsFor)"
        }
        $ListSearchOptions = Invoke-RestMethod @params
        $ListProperties = $ListSearchOptions.PSObject.Properties | Select-Object -Property Name,Value
        
        foreach ( $list in $ListProperties ) {
            $OptionsHash = [ordered]@{
                'Id' = $list.Name
                'Name' = $list.Value.name
                'Table' = $list.Value.table
                'Field' = $list.Value.field
                'DataType' = $list.Value.datatype
                'NoSearch' = $list.Value.nosearch
                'NoDisplay' = $list.Value.nodisplay
                'Available_Searchtypes' = $list.Value.available_searchtypes
                'Uid' = $list.Value.uid   
            }
            $object = New-Object -TypeName PSCustomObject -Property $OptionsHash
            $SearchOptionsArray += $object
        }
        $SearchOptionsArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}