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
                    $EntitiesHash = [ordered]@{
                        'Id'                               = $GlpiEntities.id
                        'Name'                             = $GlpiEntities.name
                        'EntitiesId'                       = $GlpiEntities.entities_id
                        'CompleteName'                     = $GlpiEntities.completename
                        'Comment'                          = $GlpiEntities.comment
                        'Level'                            = $GlpiEntities.level
                        'SonsCache'                        = $GlpiEntities.sons_cache
                        'AncestorsCache'                   = $GlpiEntities.ancestors_cache
                        'Address'                          = $GlpiEntities.address
                        'Postcode'                         = $GlpiEntities.postcode
                        'Town'                             = $GlpiEntities.town
                        'State'                            = $GlpiEntities.state
                        'Country'                          = $GlpiEntities.country
                        'Website'                          = $GlpiEntities.website
                        'Phonenumber'                      = $GlpiEntities.phonenumber
                        'Fax'                              = $GlpiEntities.fax
                        'Email'                            = $GlpiEntities.email
                        'AdminEmail'                       = $GlpiEntities.admin_email
                        'AdminEmailName'                   = $GlpiEntities.admin_email_name
                        'AdminReply'                       = $GlpiEntities.admin_reply
                        'AdminReplyName'                   = $GlpiEntities.admin_reply_name
                        'NotificationSubjectTag'           = $GlpiEntities.notification_subject_tag
                        'LdapDn'                           = $GlpiEntities.ldap_dn
                        'Tag'                              = $GlpiEntities.tag
                        'AuthldapsId'                      = $GlpiEntities.authldaps_id
                        'MailDomain'                       = $GlpiEntities.mail_domain
                        'EntityLdapfilter'                 = $GlpiEntities.entity_ldapfilter
                        'MailingSignature'                 = $GlpiEntities.mailing_signature
                        'CartridgesAlertRepeat'            = $GlpiEntities.cartridges_alert_repeat
                        'ConsumablesAlertRepeat'           = $GlpiEntities.consumables_alert_repeat
                        'UseLicensesAlert'                 = $GlpiEntities.use_licenses_alert
                        'SendLicensesAlertBeforeDelay'     = $GlpiEntities.send_licenses_alert_before_delay
                        'UseCertificatesAlert'             = $GlpiEntities.use_certificates_alert
                        'SendCertificatesAlertBeforeDelay' = $GlpiEntities.send_certificates_alert_before_delay
                        'UseContractsAlert'                = $GlpiEntities.use_contracts_alert
                        'SendContractsAlertBeforeDelay'    = $GlpiEntities.send_contracts_alert_before_delay
                        'UseInfocomsAlert'                 = $GlpiEntities.use_infocoms_alert
                        'SendInfocomsAlertBeforeDelay'     = $GlpiEntities.send_infocoms_alert_before_delay
                        'UseReservationsAlert'             = $GlpiEntities.use_reservations_alert
                        'AutocloseDelay'                   = $GlpiEntities.autoclose_delay
                        'NotclosedDelay'                   = $GlpiEntities.notclosed_delay
                        'CalendarsId'                      = $GlpiEntities.calendars_id
                        'AutoAssignMode'                   = $GlpiEntities.auto_assign_mode
                        'Tickettype'                       = $GlpiEntities.tickettype
                        'MaxClosedate'                     = $GlpiEntities.max_closedate
                        'InquestConfig'                    = $GlpiEntities.inquest_config
                        'InquestRate'                      = $GlpiEntities.inquest_rate
                        'InquestDelay'                     = $GlpiEntities.inquest_delay
                        'InquestURL'                       = $GlpiEntities.inquest_URL
                        'AutofillWarrantyDate'             = $GlpiEntities.autofill_warranty_date
                        'AutofillUseDate'                  = $GlpiEntities.autofill_use_date
                        'AutofillBuyDate'                  = $GlpiEntities.autofill_buy_date
                        'AutofillDeliveryDate'             = $GlpiEntities.autofill_delivery_date
                        'AutofillOrderDate'                = $GlpiEntities.autofill_order_date
                        'TickettemplatesId'                = $GlpiEntities.tickettemplates_id
                        'EntitiesIdSoftware'               = $GlpiEntities.entities_id_software
                        'DefaultContractAlert'             = $GlpiEntities.default_contract_alert
                        'DefaultInfocomAlert'              = $GlpiEntities.default_infocom_alert
                        'DefaultCartridgesAlarmThreshold'  = $GlpiEntities.default_cartridges_alarm_threshold
                        'DefaultConsumablesAlarmThreshold' = $GlpiEntities.default_consumables_alarm_threshold
                        'DelaySendEmails'                  = $GlpiEntities.delay_send_emails
                        'IsNotifEnableDefault'             = $GlpiEntities.is_notif_enable_default
                        'InquestDuration'                  = $GlpiEntities.inquest_duration
                        'DateMod'                          = $GlpiEntities.date_mod
                        'DateCreation'                     = $GlpiEntities.date_creation
                        'AutofillDecommissionDate'         = $GlpiEntities.autofill_decommission_date
                    }

                    $object = New-Object -TypeName PSCustomObject -Property $EntitiesHash
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

                        $EntitiesHash = [ordered]@{
                            'Id'                               = $GlpiEntity.id
                            'Name'                             = $GlpiEntity.name
                            'EntitiesId'                       = $GlpiEntity.entities_id
                            'CompleteName'                     = $GlpiEntity.completename
                            'Comment'                          = $GlpiEntity.comment
                            'Level'                            = $GlpiEntity.level
                            'SonsCache'                        = $GlpiEntity.sons_cache
                            'AncestorsCache'                   = $GlpiEntity.ancestors_cache
                            'Address'                          = $GlpiEntity.address
                            'Postcode'                         = $GlpiEntity.postcode
                            'Town'                             = $GlpiEntity.town
                            'State'                            = $GlpiEntity.state
                            'Country'                          = $GlpiEntity.country
                            'Website'                          = $GlpiEntity.website
                            'Phonenumber'                      = $GlpiEntity.phonenumber
                            'Fax'                              = $GlpiEntity.fax
                            'Email'                            = $GlpiEntity.email
                            'AdminEmail'                       = $GlpiEntity.admin_email
                            'AdminEmailName'                   = $GlpiEntity.admin_email_name
                            'AdminReply'                       = $GlpiEntity.admin_reply
                            'AdminReplyName'                   = $GlpiEntity.admin_reply_name
                            'NotificationSubjectTag'           = $GlpiEntity.notification_subject_tag
                            'LdapDn'                           = $GlpiEntity.ldap_dn
                            'Tag'                              = $GlpiEntity.tag
                            'AuthldapsId'                      = $GlpiEntity.authldaps_id
                            'MailDomain'                       = $GlpiEntity.mail_domain
                            'EntityLdapfilter'                 = $GlpiEntity.entity_ldapfilter
                            'MailingSignature'                 = $GlpiEntity.mailing_signature
                            'CartridgesAlertRepeat'            = $GlpiEntity.cartridges_alert_repeat
                            'ConsumablesAlertRepeat'           = $GlpiEntity.consumables_alert_repeat
                            'UseLicensesAlert'                 = $GlpiEntity.use_licenses_alert
                            'SendLicensesAlertBeforeDelay'     = $GlpiEntity.send_licenses_alert_before_delay
                            'UseCertificatesAlert'             = $GlpiEntity.use_certificates_alert
                            'SendCertificatesAlertBeforeDelay' = $GlpiEntity.send_certificates_alert_before_delay
                            'UseContractsAlert'                = $GlpiEntity.use_contracts_alert
                            'SendContractsAlertBeforeDelay'    = $GlpiEntity.send_contracts_alert_before_delay
                            'UseInfocomsAlert'                 = $GlpiEntity.use_infocoms_alert
                            'SendInfocomsAlertBeforeDelay'     = $GlpiEntity.send_infocoms_alert_before_delay
                            'UseReservationsAlert'             = $GlpiEntity.use_reservations_alert
                            'AutocloseDelay'                   = $GlpiEntity.autoclose_delay
                            'NotclosedDelay'                   = $GlpiEntity.notclosed_delay
                            'CalendarsId'                      = $GlpiEntity.calendars_id
                            'AutoAssignMode'                   = $GlpiEntity.auto_assign_mode
                            'Tickettype'                       = $GlpiEntity.tickettype
                            'MaxClosedate'                     = $GlpiEntity.max_closedate
                            'InquestConfig'                    = $GlpiEntity.inquest_config
                            'InquestRate'                      = $GlpiEntity.inquest_rate
                            'InquestDelay'                     = $GlpiEntity.inquest_delay
                            'InquestURL'                       = $GlpiEntity.inquest_URL
                            'AutofillWarrantyDate'             = $GlpiEntity.autofill_warranty_date
                            'AutofillUseDate'                  = $GlpiEntity.autofill_use_date
                            'AutofillBuyDate'                  = $GlpiEntity.autofill_buy_date
                            'AutofillDeliveryDate'             = $GlpiEntity.autofill_delivery_date
                            'AutofillOrderDate'                = $GlpiEntity.autofill_order_date
                            'TickettemplatesId'                = $GlpiEntity.tickettemplates_id
                            'EntitiesIdSoftware'               = $GlpiEntity.entities_id_software
                            'DefaultContractAlert'             = $GlpiEntity.default_contract_alert
                            'DefaultInfocomAlert'              = $GlpiEntity.default_infocom_alert
                            'DefaultCartridgesAlarmThreshold'  = $GlpiEntity.default_cartridges_alarm_threshold
                            'DefaultConsumablesAlarmThreshold' = $GlpiEntity.default_consumables_alarm_threshold
                            'DelaySendEmails'                  = $GlpiEntity.delay_send_emails
                            'IsNotifEnableDefault'             = $GlpiEntity.is_notif_enable_default
                            'InquestDuration'                  = $GlpiEntity.inquest_duration
                            'DateMod'                          = $GlpiEntity.date_mod
                            'DateCreation'                     = $GlpiEntity.date_creation
                            'AutofillDecommissionDate'         = $GlpiEntity.autofill_decommission_date
                        }
    
                        $object = New-Object -TypeName PSCustomObject -Property $EntitiesHash
                        $EntitiesArray += $object
                    }
                    catch {
                        $EntitiesHash = [ordered]@{
                            'Id'                               = $EId
                            'Name'                             = ' '
                            'EntitiesId'                       = ' '
                            'CompleteName'                     = ' '
                            'Comment'                          = ' '
                            'Level'                            = ' '
                            'SonsCache'                        = ' '
                            'AncestorsCache'                   = ' '
                            'Address'                          = ' '
                            'Postcode'                         = ' '
                            'Town'                             = ' '
                            'State'                            = ' '
                            'Country'                          = ' '
                            'Website'                          = ' '
                            'Phonenumber'                      = ' '
                            'Fax'                              = ' '
                            'Email'                            = ' '
                            'AdminEmail'                       = ' '
                            'AdminEmailName'                   = ' '
                            'AdminReply'                       = ' '
                            'AdminReplyName'                   = ' '
                            'NotificationSubjectTag'           = ' '
                            'LdapDn'                           = ' '
                            'Tag'                              = ' '
                            'AuthldapsId'                      = ' '
                            'MailDomain'                       = ' '
                            'EntityLdapfilter'                 = ' '
                            'MailingSignature'                 = ' '
                            'CartridgesAlertRepeat'            = ' '
                            'ConsumablesAlertRepeat'           = ' '
                            'UseLicensesAlert'                 = ' ' 
                            'SendLicensesAlertBeforeDelay'     = ' '
                            'UseCertificatesAlert'             = ' '
                            'SendCertificatesAlertBeforeDelay' = ' '
                            'UseContractsAlert'                = ' '
                            'SendContractsAlertBeforeDelay'    = ' '
                            'UseInfocomsAlert'                 = ' '
                            'SendInfocomsAlertBeforeDelay'     = ' '
                            'UseReservationsAlert'             = ' '
                            'AutocloseDelay'                   = ' '
                            'NotclosedDelay'                   = ' '
                            'CalendarsId'                      = ' '
                            'AutoAssignMode'                   = ' '
                            'Tickettype'                       = ' '
                            'MaxClosedate'                     = ' '
                            'InquestConfig'                    = ' '
                            'InquestRate'                      = ' '
                            'InquestDelay'                     = ' '
                            'InquestURL'                       = ' '
                            'AutofillWarrantyDate'             = ' '
                            'AutofillUseDate'                  = ' '
                            'AutofillBuyDate'                  = ' '
                            'AutofillDeliveryDate'             = ' '
                            'AutofillOrderDate'                = ' '
                            'TickettemplatesId'                = ' '
                            'EntitiesIdSoftware'               = ' '
                            'DefaultContractAlert'             = ' '
                            'DefaultInfocomAlert'              = ' '
                            'DefaultCartridgesAlarmThreshold'  = ' '
                            'DefaultConsumablesAlarmThreshold' = ' '
                            'DelaySendEmails'                  = ' '
                            'IsNotifEnableDefault'             = ' '
                            'InquestDuration'                  = ' '
                            'DateMod'                          = ' '
                            'DateCreation'                     = ' '
                            'AutofillDecommissionDate'         = ' '
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $EntitiesHash
                        $EntitiesArray += $object
                    }
                }
                $EntitiesArray
                $EntitiesArray = @()
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