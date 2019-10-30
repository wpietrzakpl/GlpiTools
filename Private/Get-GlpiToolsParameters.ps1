<#
.SYNOPSIS
    Function which convert parameters of specified GLPI component.
.DESCRIPTION
    Function which convert parameters of specified GLPI component.
.EXAMPLE
    PS C:\> Get-GlpiToolsParameters -Parameter users_id -Value 3
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    PSP 07/2019
#>

function Get-GlpiToolsParameters {
    [CmdletBinding()]
    param (

        [parameter(Mandatory = $true,
            ParameterSetName = "Parameter")]
        $Parameter,
        [parameter(Mandatory = $true,
            ParameterSetName = "Parameter")]
        [AllowEmptyString()]
        [AllowNull()]
        $Value
        
    )
    
    begin {

    }
    
    process { 
        try {
            if ($Parameter -eq "entities_id") {
                $ConvertedValue = $Value | Get-GlpiToolsEntities -Raw | Select-Object -ExpandProperty CompleteName -ErrorAction Stop
            } elseif ($Parameter -eq "users_id_tech" ) {
                $ConvertedValue = $Value | Get-GlpiToolsUsers -Raw | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } -ErrorAction Stop
            } elseif ($Parameter -eq "groups_id_tech" ) {
                $ConvertedValue = $Value | Get-GlpiToolsGroups -Raw | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "autoupdatesystems_id"  ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsOSUpdateSources | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ( $Parameter -eq "locations_id"  ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsLocations | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "domains_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsDomains | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "networks_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsNetworks | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "computermodels_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsComputerModels -Raw | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "computertypes_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsComputerTypes -Raw | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "manufacturers_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsManufacturers | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "users_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsUsers -Raw | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname,$_.realname } -ErrorAction Stop
            } elseif ($Parameter -eq "groups_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsGroups -Raw | Select-Object -ExpandProperty name -ErrorAction Stop
            } elseif ($Parameter -eq "states_id" ) {
                $ConvertedValue = $Value | Get-GlpiToolsDropdownsStatusesOfItems | Select-Object -ExpandProperty name -ErrorAction Stop 
            } elseif ($Parameter -eq "softwares_id") {
                $ConvertedValue = $Value | Get-GlpiToolsSoftware -Raw | Select-Object -ExpandProperty name -ErrorAction Stop 
            } elseif ($Parameter -eq "softwareversions_id") {
                $ConvertedValue = $Value | Get-GlpiToolsSoftwareVersions -Raw | Select-Object -ExpandProperty name -ErrorAction Stop 
            } elseif ($Parameter -eq "computers_id") {
                $ConvertedValue = $Value | Get-GlpiToolsComputers -Raw | Select-Object -ExpandProperty name -ErrorAction Stop 
            } else {
                $ConvertedValue = $Value
            }
        } catch {
            $ConvertedValue = "Blank"
        }
    }
    
    end {
        $ConvertedValue
    }
}