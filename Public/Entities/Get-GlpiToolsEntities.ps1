<#
.SYNOPSIS
    Function returns entities from GLPI
.DESCRIPTION
    Function returns all possible enitites, you can provide id or name to get informations about desired entity
.PARAMETER All
    This parameter will return all Entities from GLPI
.PARAMETER EntityId
    This parameter can take pipline input, either, you can use this function with -ComputerId keyword.
    Provide to this param Entity ID from GLPI Entities Bookmark
.PARAMETER EntityName
    This parameter can take pipline input, either, you can use this function with -ComputerName keyword.
    Provide to this param entity Name from GLPI Entities Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsEntities -All
    Command will return all entities from GLPI
.EXAMPLE
    PS C:\> Get-GlpiToolsEntities -EntityId 3
    Command will return entity with Id number 3 from GLPI
.EXAMPLE
    PS C:\> 3 | Get-GlpiToolsEntities
    Command will return entity with Id number 3 from GLPI
.EXAMPLE
    PS C:\> Get-GlpiToolsEntities -EntityName Old
    Command will return entity with Name Old from GLPI
.INPUTS
    Entity ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of entity from GLPI
.NOTES
    PSP 01/2019
#>

function Get-GlpiToolsEntities {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "EntityId")]
        [alias('EID')]
        [string[]]$EntityId,
        [parameter(Mandatory = $true,
            ParameterSetName = "EntityName")]
        [alias('EN')]
        [string[]]$EntityName
    )
    
    begin {
        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $EntitiesArray = @()
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
                    uri     = "$($PathToGlpi)/Entity/"
                }
                
                try {
                    $GlpiEntitiesAll = Invoke-RestMethod @params -ErrorAction Stop
                }
                catch {
                    throw "I cannot invoke command, check if u setup Glpi Config by the Set-GlpiToolsConfig function"
                }

                foreach ($GlpiEntities in $GlpiEntitiesAll) {
                    $Id = $GlpiEntities | Select-Object -ExpandProperty id
                    $Name = $GlpiEntities | Select-Object -ExpandProperty name
                    $EntitiesId = $GlpiEntities | Select-Object -ExpandProperty entities_id
                    $CompleteName = $GlpiEntities | Select-Object -ExpandProperty completename
                    $Comment = $GlpiEntities | Select-Object -ExpandProperty comment
                    $Level = $GlpiEntities | Select-Object -ExpandProperty level
                    $SonsCache = $GlpiEntities | Select-Object -ExpandProperty sons_cache
                    $AncestorsCache = $GlpiEntities | Select-Object -ExpandProperty ancestors_cache
                    $Address = $GlpiEntities | Select-Object -ExpandProperty address
                    $Postcode = $GlpiEntities | Select-Object -ExpandProperty postcode
                    $Town = $GlpiEntities | Select-Object -ExpandProperty town
                    $State = $GlpiEntities | Select-Object -ExpandProperty state
                    $Country = $GlpiEntities | Select-Object -ExpandProperty country
                    $Website = $GlpiEntities | Select-Object -ExpandProperty website
                    $Phonenumber = $GlpiEntities | Select-Object -ExpandProperty phonenumber
                    $Fax = $GlpiEntities | Select-Object -ExpandProperty fax
                    $Email = $GlpiEntities | Select-Object -ExpandProperty email
                    $AdminEmail = $GlpiEntities | Select-Object -ExpandProperty admin_email
                    $AdminEmailName = $GlpiEntities | Select-Object -ExpandProperty admin_email_name
                    $AdminReply = $GlpiEntities | Select-Object -ExpandProperty admin_reply
                    $AdminReplyName = $GlpiEntities | Select-Object -ExpandProperty admin_reply_name
                    $NotificationSubjectTag = $GlpiEntities | Select-Object -ExpandProperty notification_subject_tag
                    $LdapDn = $GlpiEntities | Select-Object -ExpandProperty ldap_dn
                    $Tag = $GlpiEntities | Select-Object -ExpandProperty tag
                    $AuthldapsId = $GlpiEntities | Select-Object -ExpandProperty authldaps_id
                    $MailDomain = $GlpiEntities | Select-Object -ExpandProperty mail_domain
                    $EntityLdapfilter = $GlpiEntities | Select-Object -ExpandProperty entity_ldapfilter
                    $MailingSignature = $GlpiEntities | Select-Object -ExpandProperty mailing_signature
                    $CartridgesAlertRepeat = $GlpiEntities | Select-Object -ExpandProperty cartridges_alert_repeat
                    $ConsumablesAlertRepeat = $GlpiEntities | Select-Object -ExpandProperty consumables_alert_repeat
                    $UseLicensesAlert = $GlpiEntities | Select-Object -ExpandProperty use_licenses_alert
                    $SendLicensesAlertBeforeDelay = $GlpiEntities | Select-Object -ExpandProperty send_licenses_alert_before_delay
                    $UseCertificatesAlert = $GlpiEntities | Select-Object -ExpandProperty use_certificates_alert
                    $SendCertificatesAlertBeforeDelay = $GlpiEntities | Select-Object -ExpandProperty send_certificates_alert_before_delay
                    $UseContractsAlert = $GlpiEntities | Select-Object -ExpandProperty use_contracts_alert
                    $SendContractsAlertBeforeDelay = $GlpiEntities | Select-Object -ExpandProperty send_contracts_alert_before_delay
                    $UseInfocomsAlert = $GlpiEntities | Select-Object -ExpandProperty use_infocoms_alert
                    $SendInfocomsAlertBeforeDelay = $GlpiEntities | Select-Object -ExpandProperty send_infocoms_alert_before_delay
                    $UseReservationsAlert = $GlpiEntities | Select-Object -ExpandProperty use_reservations_alert
                    $AutocloseDelay = $GlpiEntities | Select-Object -ExpandProperty autoclose_delay
                    $NotclosedDelay = $GlpiEntities | Select-Object -ExpandProperty notclosed_delay
                    $CalendarsId = $GlpiEntities | Select-Object -ExpandProperty calendars_id
                    $AutoAssignMode = $GlpiEntities | Select-Object -ExpandProperty auto_assign_mode
                    $Tickettype = $GlpiEntities | Select-Object -ExpandProperty tickettype
                    $MaxClosedate = $GlpiEntities | Select-Object -ExpandProperty max_closedate
                    $InquestConfig = $GlpiEntities | Select-Object -ExpandProperty inquest_config
                    $InquestRate = $GlpiEntities | Select-Object -ExpandProperty inquest_rate
                    $InquestDelay = $GlpiEntities | Select-Object -ExpandProperty inquest_delay
                    $InquestURL = $GlpiEntities | Select-Object -ExpandProperty inquest_URL
                    $AutofillWarrantyDate = $GlpiEntities | Select-Object -ExpandProperty autofill_warranty_date
                    $AutofillUseDate = $GlpiEntities | Select-Object -ExpandProperty autofill_use_date
                    $AutofillBuyDate = $GlpiEntities | Select-Object -ExpandProperty autofill_buy_date
                    $AutofillDeliveryDate = $GlpiEntities | Select-Object -ExpandProperty autofill_delivery_date
                    $AutofillOrderDate = $GlpiEntities | Select-Object -ExpandProperty autofill_order_date
                    $TickettemplatesId = $GlpiEntities | Select-Object -ExpandProperty tickettemplates_id
                    $EntitiesIdSoftware = $GlpiEntities | Select-Object -ExpandProperty entities_id_software
                    $DefaultContractAlert = $GlpiEntities | Select-Object -ExpandProperty default_contract_alert
                    $DefaultInfocomAlert = $GlpiEntities | Select-Object -ExpandProperty default_infocom_alert
                    $DefaultCartridgesAlarmThreshold = $GlpiEntities | Select-Object -ExpandProperty default_cartridges_alarm_threshold
                    $DefaultConsumablesAlarmThreshold = $GlpiEntities | Select-Object -ExpandProperty default_consumables_alarm_threshold
                    $DelaySendEmails = $GlpiEntities | Select-Object -ExpandProperty delay_send_emails
                    $IsNotifEnableDefault = $GlpiEntities | Select-Object -ExpandProperty is_notif_enable_default
                    $InquestDuration = $GlpiEntities | Select-Object -ExpandProperty inquest_duration
                    $DateMod = $GlpiEntities | Select-Object -ExpandProperty date_mod
                    $DateCreation = $GlpiEntities | Select-Object -ExpandProperty date_creation
                    $AutofillDecommissionDate = $GlpiEntities | Select-Object -ExpandProperty autofill_decommission_date

                    $object = New-Object -TypeName PSCustomObject
                    $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
                    $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value $Name
                    $object | Add-Member -Name 'EntitiesId' -MemberType NoteProperty -Value $EntitiesId
                    $object | Add-Member -Name 'CompleteName' -MemberType NoteProperty -Value $CompleteName
                    $object | Add-Member -Name 'Comment' -MemberType NoteProperty -Value $Comment
                    $object | Add-Member -Name 'Level' -MemberType NoteProperty -Value $Level
                    $object | Add-Member -Name 'SonsCache' -MemberType NoteProperty -Value $SonsCache
                    $object | Add-Member -Name 'AncestorsCache' -MemberType NoteProperty -Value $AncestorsCache
                    $object | Add-Member -Name 'Address' -MemberType NoteProperty -Value $Address
                    $object | Add-Member -Name 'Postcode' -MemberType NoteProperty -Value $Postcode
                    $object | Add-Member -Name 'Town' -MemberType NoteProperty -Value $Town
                    $object | Add-Member -Name 'State' -MemberType NoteProperty -Value $State
                    $object | Add-Member -Name 'Country' -MemberType NoteProperty -Value $Country
                    $object | Add-Member -Name 'Website' -MemberType NoteProperty -Value $Website
                    $object | Add-Member -Name 'Phonenumber' -MemberType NoteProperty -Value $Phonenumber
                    $object | Add-Member -Name 'Fax' -MemberType NoteProperty -Value $Fax
                    $object | Add-Member -Name 'Email' -MemberType NoteProperty -Value $Email
                    $object | Add-Member -Name 'AdminEmail' -MemberType NoteProperty -Value $AdminEmail
                    $object | Add-Member -Name 'AdminEmailName' -MemberType NoteProperty -Value $AdminEmailName
                    $object | Add-Member -Name 'AdminReply' -MemberType NoteProperty -Value $AdminReply
                    $object | Add-Member -Name 'AdminReplyName' -MemberType NoteProperty -Value $AdminReplyName
                    $object | Add-Member -Name 'NotificationSubjectTag' -MemberType NoteProperty -Value $NotificationSubjectTag
                    $object | Add-Member -Name 'LdapDn' -MemberType NoteProperty -Value $LdapDn
                    $object | Add-Member -Name 'Tag' -MemberType NoteProperty -Value $Tag
                    $object | Add-Member -Name 'AuthldapsId' -MemberType NoteProperty -Value $AuthldapsId
                    $object | Add-Member -Name 'MailDomain' -MemberType NoteProperty -Value $MailDomain
                    $object | Add-Member -Name 'EntityLdapfilter' -MemberType NoteProperty -Value $EntityLdapfilter
                    $object | Add-Member -Name 'MailingSignature' -MemberType NoteProperty -Value $MailingSignature
                    $object | Add-Member -Name 'CartridgesAlertRepeat' -MemberType NoteProperty -Value $CartridgesAlertRepeat
                    $object | Add-Member -Name 'ConsumablesAlertRepeat' -MemberType NoteProperty -Value $ConsumablesAlertRepeat
                    $object | Add-Member -Name 'UseLicensesAlert' -MemberType NoteProperty -Value $UseLicensesAlert
                    $object | Add-Member -Name 'SendLicensesAlertBeforeDelay' -MemberType NoteProperty -Value $SendLicensesAlertBeforeDelay
                    $object | Add-Member -Name 'UseCertificatesAlert' -MemberType NoteProperty -Value $UseCertificatesAlert
                    $object | Add-Member -Name 'SendCertificatesAlertBeforeDelay' -MemberType NoteProperty -Value $SendCertificatesAlertBeforeDelay
                    $object | Add-Member -Name 'UseContractsAlert' -MemberType NoteProperty -Value $UseContractsAlert
                    $object | Add-Member -Name 'SendContractsAlertBeforeDelay' -MemberType NoteProperty -Value $SendContractsAlertBeforeDelay
                    $object | Add-Member -Name 'UseInfocomsAlert' -MemberType NoteProperty -Value $UseInfocomsAlert
                    $object | Add-Member -Name 'SendInfocomsAlertBeforeDelay' -MemberType NoteProperty -Value $SendInfocomsAlertBeforeDelay
                    $object | Add-Member -Name 'UseReservationsAlert' -MemberType NoteProperty -Value $UseReservationsAlert
                    $object | Add-Member -Name 'AutocloseDelay' -MemberType NoteProperty -Value $AutocloseDelay
                    $object | Add-Member -Name 'NotclosedDelay' -MemberType NoteProperty -Value $NotclosedDelay
                    $object | Add-Member -Name 'CalendarsId' -MemberType NoteProperty -Value $CalendarsId
                    $object | Add-Member -Name 'AutoAssignMode' -MemberType NoteProperty -Value $AutoAssignMode
                    $object | Add-Member -Name 'Tickettype' -MemberType NoteProperty -Value $Tickettype
                    $object | Add-Member -Name 'MaxClosedate' -MemberType NoteProperty -Value $MaxClosedate
                    $object | Add-Member -Name 'InquestConfig' -MemberType NoteProperty -Value $InquestConfig
                    $object | Add-Member -Name 'InquestRate' -MemberType NoteProperty -Value $InquestRate
                    $object | Add-Member -Name 'InquestDelay' -MemberType NoteProperty -Value $InquestDelay
                    $object | Add-Member -Name 'InquestURL' -MemberType NoteProperty -Value $InquestURL
                    $object | Add-Member -Name 'AutofillWarrantyDate' -MemberType NoteProperty -Value $AutofillWarrantyDate
                    $object | Add-Member -Name 'AutofillUseDate' -MemberType NoteProperty -Value $AutofillUseDate
                    $object | Add-Member -Name 'AutofillBuyDate' -MemberType NoteProperty -Value $AutofillBuyDate
                    $object | Add-Member -Name 'AutofillDeliveryDate' -MemberType NoteProperty -Value $AutofillDeliveryDate
                    $object | Add-Member -Name 'AutofillOrderDate' -MemberType NoteProperty -Value $AutofillOrderDate
                    $object | Add-Member -Name 'TickettemplatesId' -MemberType NoteProperty -Value $TickettemplatesId
                    $object | Add-Member -Name 'EntitiesIdSoftware' -MemberType NoteProperty -Value $EntitiesIdSoftware
                    $object | Add-Member -Name 'DefaultContractAlert' -MemberType NoteProperty -Value $DefaultContractAlert
                    $object | Add-Member -Name 'DefaultInfocomAlert' -MemberType NoteProperty -Value $DefaultInfocomAlert
                    $object | Add-Member -Name 'DefaultCartridgesAlarmThreshold' -MemberType NoteProperty -Value $DefaultCartridgesAlarmThreshold
                    $object | Add-Member -Name 'DefaultConsumablesAlarmThreshold' -MemberType NoteProperty -Value $DefaultConsumablesAlarmThreshold
                    $object | Add-Member -Name 'DelaySendEmails' -MemberType NoteProperty -Value $DelaySendEmails
                    $object | Add-Member -Name 'IsNotifEnableDefault' -MemberType NoteProperty -Value $IsNotifEnableDefault
                    $object | Add-Member -Name 'InquestDuration' -MemberType NoteProperty -Value $InquestDuration
                    $object | Add-Member -Name 'DateMod' -MemberType NoteProperty -Value $DateMod
                    $object | Add-Member -Name 'DateCreation' -MemberType NoteProperty -Value $DateCreation
                    $object | Add-Member -Name 'AutofillDecommissionDate' -MemberType NoteProperty -Value $AutofillDecommissionDate
                    $EntitiesArray += $object
                }

                $EntitiesArray
            }
            EntityId {
                foreach ( $EId in $EntityId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Entity/$($EId)"
                    }
                
                    try {
                        $GlpiEntity = Invoke-RestMethod @params -ErrorAction Stop

                        $Id = $GlpiEntity | Select-Object -ExpandProperty id
                        $Name = $GlpiEntity | Select-Object -ExpandProperty name
                        $EntitiesId = $GlpiEntity | Select-Object -ExpandProperty entities_id
                        $CompleteName = $GlpiEntity | Select-Object -ExpandProperty completename
                        $Comment = $GlpiEntity | Select-Object -ExpandProperty comment
                        $Level = $GlpiEntity | Select-Object -ExpandProperty level
                        $SonsCache = $GlpiEntity | Select-Object -ExpandProperty sons_cache
                        $AncestorsCache = $GlpiEntity | Select-Object -ExpandProperty ancestors_cache
                        $Address = $GlpiEntity | Select-Object -ExpandProperty address
                        $Postcode = $GlpiEntity | Select-Object -ExpandProperty postcode
                        $Town = $GlpiEntity | Select-Object -ExpandProperty town
                        $State = $GlpiEntity | Select-Object -ExpandProperty state
                        $Country = $GlpiEntity | Select-Object -ExpandProperty country
                        $Website = $GlpiEntity | Select-Object -ExpandProperty website
                        $Phonenumber = $GlpiEntity | Select-Object -ExpandProperty phonenumber
                        $Fax = $GlpiEntity | Select-Object -ExpandProperty fax
                        $Email = $GlpiEntity | Select-Object -ExpandProperty email
                        $AdminEmail = $GlpiEntity | Select-Object -ExpandProperty admin_email
                        $AdminEmailName = $GlpiEntity | Select-Object -ExpandProperty admin_email_name
                        $AdminReply = $GlpiEntity | Select-Object -ExpandProperty admin_reply
                        $AdminReplyName = $GlpiEntity | Select-Object -ExpandProperty admin_reply_name
                        $NotificationSubjectTag = $GlpiEntity | Select-Object -ExpandProperty notification_subject_tag
                        $LdapDn = $GlpiEntity | Select-Object -ExpandProperty ldap_dn
                        $Tag = $GlpiEntity | Select-Object -ExpandProperty tag
                        $AuthldapsId = $GlpiEntity | Select-Object -ExpandProperty authldaps_id
                        $MailDomain = $GlpiEntity | Select-Object -ExpandProperty mail_domain
                        $EntityLdapfilter = $GlpiEntity | Select-Object -ExpandProperty entity_ldapfilter
                        $MailingSignature = $GlpiEntity | Select-Object -ExpandProperty mailing_signature
                        $CartridgesAlertRepeat = $GlpiEntity | Select-Object -ExpandProperty cartridges_alert_repeat
                        $ConsumablesAlertRepeat = $GlpiEntity | Select-Object -ExpandProperty consumables_alert_repeat
                        $UseLicensesAlert = $GlpiEntity | Select-Object -ExpandProperty use_licenses_alert
                        $SendLicensesAlertBeforeDelay = $GlpiEntity | Select-Object -ExpandProperty send_licenses_alert_before_delay
                        $UseCertificatesAlert = $GlpiEntity | Select-Object -ExpandProperty use_certificates_alert
                        $SendCertificatesAlertBeforeDelay = $GlpiEntity | Select-Object -ExpandProperty send_certificates_alert_before_delay
                        $UseContractsAlert = $GlpiEntity | Select-Object -ExpandProperty use_contracts_alert
                        $SendContractsAlertBeforeDelay = $GlpiEntity | Select-Object -ExpandProperty send_contracts_alert_before_delay
                        $UseInfocomsAlert = $GlpiEntity | Select-Object -ExpandProperty use_infocoms_alert
                        $SendInfocomsAlertBeforeDelay = $GlpiEntity | Select-Object -ExpandProperty send_infocoms_alert_before_delay
                        $UseReservationsAlert = $GlpiEntity | Select-Object -ExpandProperty use_reservations_alert
                        $AutocloseDelay = $GlpiEntity | Select-Object -ExpandProperty autoclose_delay
                        $NotclosedDelay = $GlpiEntity | Select-Object -ExpandProperty notclosed_delay
                        $CalendarsId = $GlpiEntity | Select-Object -ExpandProperty calendars_id
                        $AutoAssignMode = $GlpiEntity | Select-Object -ExpandProperty auto_assign_mode
                        $Tickettype = $GlpiEntity | Select-Object -ExpandProperty tickettype
                        $MaxClosedate = $GlpiEntity | Select-Object -ExpandProperty max_closedate
                        $InquestConfig = $GlpiEntity | Select-Object -ExpandProperty inquest_config
                        $InquestRate = $GlpiEntity | Select-Object -ExpandProperty inquest_rate
                        $InquestDelay = $GlpiEntity | Select-Object -ExpandProperty inquest_delay
                        $InquestURL = $GlpiEntity | Select-Object -ExpandProperty inquest_URL
                        $AutofillWarrantyDate = $GlpiEntity | Select-Object -ExpandProperty autofill_warranty_date
                        $AutofillUseDate = $GlpiEntity | Select-Object -ExpandProperty autofill_use_date
                        $AutofillBuyDate = $GlpiEntity | Select-Object -ExpandProperty autofill_buy_date
                        $AutofillDeliveryDate = $GlpiEntity | Select-Object -ExpandProperty autofill_delivery_date
                        $AutofillOrderDate = $GlpiEntity | Select-Object -ExpandProperty autofill_order_date
                        $TickettemplatesId = $GlpiEntity | Select-Object -ExpandProperty tickettemplates_id
                        $EntitiesIdSoftware = $GlpiEntity | Select-Object -ExpandProperty entities_id_software
                        $DefaultContractAlert = $GlpiEntity | Select-Object -ExpandProperty default_contract_alert
                        $DefaultInfocomAlert = $GlpiEntity | Select-Object -ExpandProperty default_infocom_alert
                        $DefaultCartridgesAlarmThreshold = $GlpiEntity | Select-Object -ExpandProperty default_cartridges_alarm_threshold
                        $DefaultConsumablesAlarmThreshold = $GlpiEntity | Select-Object -ExpandProperty default_consumables_alarm_threshold
                        $DelaySendEmails = $GlpiEntity | Select-Object -ExpandProperty delay_send_emails
                        $IsNotifEnableDefault = $GlpiEntity | Select-Object -ExpandProperty is_notif_enable_default
                        $InquestDuration = $GlpiEntity | Select-Object -ExpandProperty inquest_duration
                        $DateMod = $GlpiEntity | Select-Object -ExpandProperty date_mod
                        $DateCreation = $GlpiEntity | Select-Object -ExpandProperty date_creation
                        $AutofillDecommissionDate = $GlpiEntity | Select-Object -ExpandProperty autofill_decommission_date
    
                        $object = New-Object -TypeName PSCustomObject
                        $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
                        $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value $Name
                        $object | Add-Member -Name 'EntitiesId' -MemberType NoteProperty -Value $EntitiesId
                        $object | Add-Member -Name 'CompleteName' -MemberType NoteProperty -Value $CompleteName
                        $object | Add-Member -Name 'Comment' -MemberType NoteProperty -Value $Comment
                        $object | Add-Member -Name 'Level' -MemberType NoteProperty -Value $Level
                        $object | Add-Member -Name 'SonsCache' -MemberType NoteProperty -Value $SonsCache
                        $object | Add-Member -Name 'AncestorsCache' -MemberType NoteProperty -Value $AncestorsCache
                        $object | Add-Member -Name 'Address' -MemberType NoteProperty -Value $Address
                        $object | Add-Member -Name 'Postcode' -MemberType NoteProperty -Value $Postcode
                        $object | Add-Member -Name 'Town' -MemberType NoteProperty -Value $Town
                        $object | Add-Member -Name 'State' -MemberType NoteProperty -Value $State
                        $object | Add-Member -Name 'Country' -MemberType NoteProperty -Value $Country
                        $object | Add-Member -Name 'Website' -MemberType NoteProperty -Value $Website
                        $object | Add-Member -Name 'Phonenumber' -MemberType NoteProperty -Value $Phonenumber
                        $object | Add-Member -Name 'Fax' -MemberType NoteProperty -Value $Fax
                        $object | Add-Member -Name 'Email' -MemberType NoteProperty -Value $Email
                        $object | Add-Member -Name 'AdminEmail' -MemberType NoteProperty -Value $AdminEmail
                        $object | Add-Member -Name 'AdminEmailName' -MemberType NoteProperty -Value $AdminEmailName
                        $object | Add-Member -Name 'AdminReply' -MemberType NoteProperty -Value $AdminReply
                        $object | Add-Member -Name 'AdminReplyName' -MemberType NoteProperty -Value $AdminReplyName
                        $object | Add-Member -Name 'NotificationSubjectTag' -MemberType NoteProperty -Value $NotificationSubjectTag
                        $object | Add-Member -Name 'LdapDn' -MemberType NoteProperty -Value $LdapDn
                        $object | Add-Member -Name 'Tag' -MemberType NoteProperty -Value $Tag
                        $object | Add-Member -Name 'AuthldapsId' -MemberType NoteProperty -Value $AuthldapsId
                        $object | Add-Member -Name 'MailDomain' -MemberType NoteProperty -Value $MailDomain
                        $object | Add-Member -Name 'EntityLdapfilter' -MemberType NoteProperty -Value $EntityLdapfilter
                        $object | Add-Member -Name 'MailingSignature' -MemberType NoteProperty -Value $MailingSignature
                        $object | Add-Member -Name 'CartridgesAlertRepeat' -MemberType NoteProperty -Value $CartridgesAlertRepeat
                        $object | Add-Member -Name 'ConsumablesAlertRepeat' -MemberType NoteProperty -Value $ConsumablesAlertRepeat
                        $object | Add-Member -Name 'UseLicensesAlert' -MemberType NoteProperty -Value $UseLicensesAlert
                        $object | Add-Member -Name 'SendLicensesAlertBeforeDelay' -MemberType NoteProperty -Value $SendLicensesAlertBeforeDelay
                        $object | Add-Member -Name 'UseCertificatesAlert' -MemberType NoteProperty -Value $UseCertificatesAlert
                        $object | Add-Member -Name 'SendCertificatesAlertBeforeDelay' -MemberType NoteProperty -Value $SendCertificatesAlertBeforeDelay
                        $object | Add-Member -Name 'UseContractsAlert' -MemberType NoteProperty -Value $UseContractsAlert
                        $object | Add-Member -Name 'SendContractsAlertBeforeDelay' -MemberType NoteProperty -Value $SendContractsAlertBeforeDelay
                        $object | Add-Member -Name 'UseInfocomsAlert' -MemberType NoteProperty -Value $UseInfocomsAlert
                        $object | Add-Member -Name 'SendInfocomsAlertBeforeDelay' -MemberType NoteProperty -Value $SendInfocomsAlertBeforeDelay
                        $object | Add-Member -Name 'UseReservationsAlert' -MemberType NoteProperty -Value $UseReservationsAlert
                        $object | Add-Member -Name 'AutocloseDelay' -MemberType NoteProperty -Value $AutocloseDelay
                        $object | Add-Member -Name 'NotclosedDelay' -MemberType NoteProperty -Value $NotclosedDelay
                        $object | Add-Member -Name 'CalendarsId' -MemberType NoteProperty -Value $CalendarsId
                        $object | Add-Member -Name 'AutoAssignMode' -MemberType NoteProperty -Value $AutoAssignMode
                        $object | Add-Member -Name 'Tickettype' -MemberType NoteProperty -Value $Tickettype
                        $object | Add-Member -Name 'MaxClosedate' -MemberType NoteProperty -Value $MaxClosedate
                        $object | Add-Member -Name 'InquestConfig' -MemberType NoteProperty -Value $InquestConfig
                        $object | Add-Member -Name 'InquestRate' -MemberType NoteProperty -Value $InquestRate
                        $object | Add-Member -Name 'InquestDelay' -MemberType NoteProperty -Value $InquestDelay
                        $object | Add-Member -Name 'InquestURL' -MemberType NoteProperty -Value $InquestURL
                        $object | Add-Member -Name 'AutofillWarrantyDate' -MemberType NoteProperty -Value $AutofillWarrantyDate
                        $object | Add-Member -Name 'AutofillUseDate' -MemberType NoteProperty -Value $AutofillUseDate
                        $object | Add-Member -Name 'AutofillBuyDate' -MemberType NoteProperty -Value $AutofillBuyDate
                        $object | Add-Member -Name 'AutofillDeliveryDate' -MemberType NoteProperty -Value $AutofillDeliveryDate
                        $object | Add-Member -Name 'AutofillOrderDate' -MemberType NoteProperty -Value $AutofillOrderDate
                        $object | Add-Member -Name 'TickettemplatesId' -MemberType NoteProperty -Value $TickettemplatesId
                        $object | Add-Member -Name 'EntitiesIdSoftware' -MemberType NoteProperty -Value $EntitiesIdSoftware
                        $object | Add-Member -Name 'DefaultContractAlert' -MemberType NoteProperty -Value $DefaultContractAlert
                        $object | Add-Member -Name 'DefaultInfocomAlert' -MemberType NoteProperty -Value $DefaultInfocomAlert
                        $object | Add-Member -Name 'DefaultCartridgesAlarmThreshold' -MemberType NoteProperty -Value $DefaultCartridgesAlarmThreshold
                        $object | Add-Member -Name 'DefaultConsumablesAlarmThreshold' -MemberType NoteProperty -Value $DefaultConsumablesAlarmThreshold
                        $object | Add-Member -Name 'DelaySendEmails' -MemberType NoteProperty -Value $DelaySendEmails
                        $object | Add-Member -Name 'IsNotifEnableDefault' -MemberType NoteProperty -Value $IsNotifEnableDefault
                        $object | Add-Member -Name 'InquestDuration' -MemberType NoteProperty -Value $InquestDuration
                        $object | Add-Member -Name 'DateMod' -MemberType NoteProperty -Value $DateMod
                        $object | Add-Member -Name 'DateCreation' -MemberType NoteProperty -Value $DateCreation
                        $object | Add-Member -Name 'AutofillDecommissionDate' -MemberType NoteProperty -Value $AutofillDecommissionDate
                        $EntitiesArray += $object
                    }
                    catch {
                        $object = New-Object -TypeName PSCustomObject
                        $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
                        $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'EntitiesId' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'CompleteName' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Comment' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Level' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'SonsCache' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AncestorsCache' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Address' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Postcode' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Town' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'State' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Country' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Website' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Phonenumber' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Fax' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Email' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AdminEmail' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AdminEmailName' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AdminReply' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AdminReplyName' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'NotificationSubjectTag' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'LdapDn' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Tag' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AuthldapsId' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'MailDomain' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'EntityLdapfilter' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'MailingSignature' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'CartridgesAlertRepeat' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'ConsumablesAlertRepeat' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'UseLicensesAlert' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'SendLicensesAlertBeforeDelay' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'UseCertificatesAlert' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'SendCertificatesAlertBeforeDelay' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'UseContractsAlert' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'SendContractsAlertBeforeDelay' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'UseInfocomsAlert' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'SendInfocomsAlertBeforeDelay' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'UseReservationsAlert' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutocloseDelay' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'NotclosedDelay' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'CalendarsId' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutoAssignMode' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'Tickettype' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'MaxClosedate' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'InquestConfig' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'InquestRate' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'InquestDelay' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'InquestURL' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutofillWarrantyDate' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutofillUseDate' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutofillBuyDate' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutofillDeliveryDate' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutofillOrderDate' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'TickettemplatesId' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'EntitiesIdSoftware' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'DefaultContractAlert' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'DefaultInfocomAlert' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'DefaultCartridgesAlarmThreshold' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'DefaultConsumablesAlarmThreshold' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'DelaySendEmails' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'IsNotifEnableDefault' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'InquestDuration' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'DateMod' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'DateCreation' -MemberType NoteProperty -Value ' '
                        $object | Add-Member -Name 'AutofillDecommissionDate' -MemberType NoteProperty -Value ' '
                        $EntitiesArray += $object 
                    }
                }
                $EntitiesArray
            }
            EntityName {
                
            }
            Default {}
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}