<#
.SYNOPSIS
    Function gets list of Search Options for specific Search in GLPI
.DESCRIPTION
    Function gets list of Search Options for specific Search in GLPI
    Parameters are the names of options in GLPI
    Remember that, names used in cmdlet coming from glpi URL, and can be hard to understand, but most of them are intuitional.
    To get name you always have to look at the URL in GLPI, for example "http://glpi/front/computer.php" where "computer" is the name to use in parameter.
.PARAMETER ListOptionsForAssets
    You can use this function with -ListOptionsForAssets parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForAssistance
    You can use this function with -ListOptionsForAssistance parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForManagement
    You can use this function with -ListOptionsForManagement parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForTools
    You can use this function with -ListOptionsForTools parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForAdministration
    You can use this function with -ListOptionsForAdministration parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForSetup
    You can use this function with -ListOptionsForSetup parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForSetupDropdowns
    You can use this function with -ListOptionsForSetupDropdowns parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForSetupComponents
    You can use this function with -ListOptionsForSetupComponents parameter.
    Using TAB button you can choose desired option.
.PARAMETER ListOptionsForSetupNotifications
    You can use this function with -ListOptionsForSetupNotifications parameter.
    Using TAB button you can choose desired option.
.EXAMPLE
    PS C:\WINDOWS\system32> Get-GlpiToolsListSearchOptions -ListOptionsForSetupComponents DeviceCase
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
        [parameter(Mandatory = $false,
            ParameterSetName = "Assets")]
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
            "Pdu")]
        [String]$ListOptionsForAssets,

        [parameter(Mandatory = $false,
            ParameterSetName = "Assistance")]
        [ValidateSet("Ticket",
            "Problem",
            "Change",
            "Ticketrecurrent",
            "Softwarelicense",
            "Supplier",
            "Budget",
            "Users",
            "Group")]
        [String]$ListOptionsForAssistance,

        [parameter(Mandatory = $false, ParameterSetName = "Management")]
        [ValidateSet("Softwarelicense",
            "Budget",
            "Supplier",
            "Contact",
            "Contract",
            "Document",
            "Line",
            "Certificate",
            "Datacenter")]
        [String]$ListOptionsForManagement,

        [parameter(Mandatory = $false,
            ParameterSetName = "Tools")]
        [ValidateSet("Project",
            "Reminder",
            "Rssfeed",
            "Knowbaseitem",
            "Reservationitem",
            "Report",
            "Savedsearch")]
        [String]$ListOptionsForTools,

        [parameter(Mandatory = $false,
            ParameterSetName = "Administration")]
        [ValidateSet("User",
            "Group",
            "Entity",
            "Rule",
            "Profile",
            "Queuednotification",
            "Savedsearch")]
        [String]$ListOptionsForAdministration,

        [parameter(Mandatory = $false,
            ParameterSetName = "Setup")]
        [ValidateSet("Slm",
            "Fieldunicity",
            "Crontask",
            "Mailcollector",
            "Link",
            "Plugin")]
        [String]$ListOptionsForSetup,

        [parameter(Mandatory = $false,
            ParameterSetName = "Dropdowns")]
        [ValidateSet("Location",
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
            "Plug")]
        [String]$ListOptionsForSetupDropdowns,
        [parameter(Mandatory = $false,
        ParameterSetName = "Components")]
        [ValidateSet("DeviceBattery",
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
            "DeviceMotherboard")]
        [String]$ListOptionsForSetupComponents,
        [parameter(Mandatory = $false,
        ParameterSetName = "Notifications")]
        [ValidateSet("Notificationtemplate",
            "Notification")]
        [String]$ListOptionsForSetupNotifications

    )
    
    begin {
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Values

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
            uri = "$($PathToGlpi)/listSearchOptions/$($ChoosenParam)"
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