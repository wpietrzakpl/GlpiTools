<#
.SYNOPSIS
    Add a task to a ticket
.DESCRIPTION
    Add a task to a ticket, this will change the status to solved

.PARAMETER ticket_id
    The ticket id this task will be added to
.PARAMETER content
    Provide the body/content of the task

.PARAMETER Status
    Specify the task status

.OUTPUTS
    Function returns PSCustomObject with id's and messages from the GLPI API
.NOTES
    Author:     Ron Peeters 
    Date:       20200708
    Version:    1.0.0
#>

function Update-GlpiToolsTicketTask {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "task id from GLPI"
        )]
        #[alias('TID')]
        [int]$task_id,

        [parameter(
            Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
            HelpMessage = "ticket id from GLPI"
            )]
        [alias('TID')]
        [int]$ticket_id,
        
        [parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "task content"
        )]
        [alias('Body')]
        [string]$content,

        [parameter(
            Mandatory = $false,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "task status"
        )]
        [ValidateSet("Todo", "Information", "Done")]
        [string]$Status

 
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        #$ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        switch ($Status) {
            "Todo" { $state_id = 1}
            "Information" { $state_id = 0}
            "Done" { $state_id = 2}
        }
        Write-Verbose "Ticket status id is $state_id"

        $Output = [System.Collections.Generic.List[PSObject]]::New()
    }
    
    process {

        $hashUpdateTask = @{
            id         = $task_id
            tickets_id = $ticket_id
            #content           = $content
            # items_id = $task_id
            # itemtype = "Ticket"
        }

        If ($PSBoundParameters['content']) {
            $hashUpdateTask["content"] = $content
        }

        If ($PSBoundParameters['Status']) {
            $hashUpdateTask["state"] = $state_id
        }

        #https://forum.glpi-project.org/viewtopic.php?id=159609

        $GlpiUpload = $hashUpdateTask | ConvertTo-Json
        $Upload = '{ "input" : ' + $GlpiUpload + '}'

        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'put'
            uri     = "$($PathToGlpi)/Ticket/$($task_id)/TicketTask/"
            body    = ([System.Text.Encoding]::UTF8.GetBytes($Upload))
        }

        Try {
            Write-Verbose "Invoking API to add ticket task"
            $GlpiTicket = Invoke-RestMethod @params -ErrorAction Stop

            If ($GlpiTicket -match "</body>") {
                $GLPITicket = $GlpiTicket.split(">")[-1] | ConvertFrom-JSON
            } else {
                #Do nothing
            }

            $Output.Add($GLPITicket)

            Write-Verbose "new task added with ID $($GLPITicket.id)"
            
  


        } Catch {
            Write-Error -Message "Unable to add new ticket task."
            Write-Error $_
            Write-Error ($params.GetEnumerator() | Out-string)
            Write-Error $Upload
        }
    }
    
    end {
        $Output
        $Output = [System.Collections.Generic.List[PSObject]]::New()
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}

$ItemTypeValidate = {
    param ($commandName, $parameterName, $stringMatch)
    $ModulePath = Split-Path (Get-Module -Name GlpiTools).Path -Parent
    (Get-Content "$($ModulePath)\Private\Parameters.json" | ConvertFrom-Json).GlpiComponents | Where-Object {$_ -match "$stringMatch"}
}
Register-ArgumentCompleter -CommandName Update-GlpiToolsTicketTask -ParameterName item_type -ScriptBlock $ItemTypeValidate