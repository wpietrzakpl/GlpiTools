function Set-GlpiToolsConfig {
    # help
    [cmdletbindig()]
    param (
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
            if ($_ -eq "DefaultConfig") {
                throw "You must specify a ConfigName other than 'DefaultConfig'. That is a reserved value."
            }
            elseif ($_ -notmatch '^[a-zA-Z]+[a-zA-Z0-9]*$') {
                throw "You must specify a ConfigName that starts with a letter and does not contain any spaces, otherwise the Configuration will break"
            }
            else {
                $true
            }
        })]
        [string]
        $ConfigName = $Script:ConfigName,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $UserToken,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $AppToken,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $Url,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $ContentType,
        [parameter(Mandatory = $false)]
        [switch]
        $Show
    )
    begin {

    }
    process {
        $Script:ConfigScope = $Scope
        if ($PSBoundParameters.Keys -contains "Verbose") {
            $params["Verbose"] = $PSBoundParameters["Verbose"]
        }
        

    }
    end {

    
    }
}