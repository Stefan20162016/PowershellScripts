# from @ippsec twitter
# tail -f of Application Log
# Inspired SilentBreakSecurity DSOPS 1 Course - (SilentBreakSecurity has since been acquired by NetSPI)

$ErrorActionPreference = "SilentlyContinue"

Function Parse-Event {
    # Credit: https://github.com/RamblingCookieMonster/PowerShell/blob/master/Get-WinEventData.ps1
    param(
        [Parameter(ValueFromPipeline=$true)] $Event
    )

    Process
    {
        foreach($entry in $Event)
        {
            $XML = [xml]$entry.ToXml()
            $X = $XML.Event.EventData.Data
            # 
            For( $i=0; $i -lt $X.count; $i++ ){
                $Entry = Add-Member -InputObject $entry -MemberType NoteProperty -Name "$($X[$i].name)" -Value $X[$i].'#text' -Force -Passthru
            }
            $Entry
        }
    }
}

Function Write-Alert ($alerts) {
    Write-Host "Type: $($alerts.Type)"
    $alerts.Remove("Type")
    foreach($alert in $alerts.GetEnumerator()) {
        write-host "$($alert.Name): $($alert.Value)"
    }
    write-host "-----"
}

#$LogName = "Microsoft-Windows-Sysmon"

$LogName  = "Application"

$index =  (Get-WinEvent -LogName $LogName -max 1).RecordID 
while ($true)
{
    Start-Sleep 1

    $NewIndex = (Get-WinEvent -LogName $LogName -max 1).RecordID

    if ($NewIndex -gt $Index) {
        # We Have New Events.
        $logs =  Get-WinEvent -LogName $LogName -max ($NewIndex - $index) | sort RecordID
        foreach($log in $logs) {
            #$evt = $log | Parse-Event
            #if ($evt.id -eq 1) {
            #    $output = @{}
            #    $output.add("Type", "Application-Log:")
            ##    $output.add("PID", $evt.ProcessId)
            #    $output.add("Message", $evt.Message)
                                
            #    write-alert $output
            #}
            $output = @{}
            #$output.add("Logname", $LogName)
            $output.add("logname", $log.ContainerLog)
            $output.add("level", $log.LevelDisplayName)
            $output.add("taskname", $log.TaskDisplayName)
            $output.add("user", $log.UserId)
            $output.add("id", $log.Id)
            $output.add("time", $log.TimeCreated)
            $output.add("message1", $log.Message)
            $output.add("message2", $log.Properties.Value )
            Write-Alert $output
            
        }
        $index = $NewIndex
    }
}
