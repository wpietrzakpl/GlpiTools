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
        [string]$EntityName
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
                    uri     = "$($PathToGlpi)/Entity/?range=0-9999999999999"
                }
                
                $GlpiEntitiesAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiEntity in $GlpiEntitiesAll) {
                    $EntityHash = [ordered]@{ }
                            $EntityProperties = $GlpiEntity.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EntityProp in $EntityProperties) {
                                $EntityHash.Add($EntityProp.Name, $EntityProp.Value)
                            }
                            $object = [pscustomobject]$EntityHash
                            $EntitiesArray += $object 
                }
                $EntitiesArray
                $EntitiesArray = @()
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

                    Try {
                        $GlpiEntity = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $EntityHash = [ordered]@{ }
                            $EntityProperties = $GlpiEntity.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EntityProp in $EntityProperties) {
                                $EntityHash.Add($EntityProp.Name, $EntityProp.Value)
                            }
                            $object = [pscustomobject]$EntityHash
                            $EntitiesArray += $object 
                        } else {
                            $EntityHash = [ordered]@{ }
                            $EntityProperties = $GlpiEntity.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($EntityProp in $EntityProperties) {

                                switch ($EntityProp.Name) {
                                    profiles_id { $EntityPropNewValue = Get-GlpiToolsProfiles -All | Where-Object {$_.id -eq $EntityProp.Value } | Select-Object -ExpandProperty name }
                                    Default {
                                        $EntityPropNewValue = $EntityProp.Value
                                    }
                                }

                                $EntityHash.Add($EntityProp.Name, $EntityPropNewValue)
                            }
                            $object = [pscustomobject]$EntityHash
                            $EntitiesArray += $object 
                        }
                    } Catch {

                        Write-Verbose -Message "Entity ID = $EId is not found"
                        
                    }
                    $EntitiesArray
                    $EntitiesArray = @()
                }
            }
            EntityName {
                Search-GlpiToolsItems -SearchFor Entity -SearchType contains -SearchValue $EntityName
            }
            Default {}
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}