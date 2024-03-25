Import-Module ".\Audit-ADComputers.ps1"
Import-Module ".\Update-ADObjectHelper.ps1"


$removedComputerTotal  = 0
$removedGroupTotal     = 0
#$disabledTotal         = 0
#$adMessageTotal        = 0
#$renamedTotal          = 0
#$movedTotal            = 0
$sendEmail             = $false

$date = (Get-Date -Format MMyyyy)
$Exclude = Import-Csv ".\Exclude.csv"

$oldComputers = Audit-OldComputers -daysSinceLogin (90) -ping -excludeOU "" -filter '(OperatingSystem -notlike "*Server*") -and (OperatingSystem -like "*Windows*")' -computerGroups "Administrators","RemoteUsers" | `
    Where-Object {$_.PINGABLE -EQ $false} | Where-Object {$_.name -notin $Exclude.name}

$oldComputers | Export-Csv -path ".\Get-OldComputers-$($date).csv" -NoTypeInformation -Append

$updateErrorLogPath=".\Update-ADObjectHelper.err"
foreach ($computer in $oldComputers){
    
    $results = Update-ADObjectHelper -Identity $(Get-ADComputer $computer.Name).DistinguishedName -Remove -errorLogPath $updateErrorLogPath
    $removedComputerTotal    += $results.removed
    #$disabledTotal           += $results.Disabled
    #$adMessageTotal          += $results.adMessage 
    #$renamedTotal            += $results.Renamed
    #$movedTotal              += $results.Moved    
    
    #If the computer returns with an admin/Remote group - attempt to remove it and add it to the group removed total
    if($computer.AdminGroup){
        $removedGroupTotal    += (Update-ADObjectHelper -Identity $(Get-ADGroup "$($computer.Name) Administrators").DistinguishedName -Remove -errorLogPath $updateErrorLogPath).Removed
    }

    if($computer.RemoteUsers){
        $removedGroupTotal    += (Update-ADObjectHelper -Identity $(Get-ADGroup "$($computer.Name) RemoteUsers").DistinguishedName -Remove -errorLogPath $updateErrorLogPath).Removed
    }
}


#Take in the log and rebuild it with the new info
$logPath = ".\MonthlyRemovedCountLog.csv"
$log = Import-Csv $logPath
$logLength = ($log|Measure-Object).count

#If new month/year add it to log
if($date -notin $log.date){
    $sendEmail=$true
    $newEntry = [PSCustomObject]@{
            Date             = $date
            computerRemoved  = $removedComputerTotal
            groupsRemoved    = $removedGroupTotal
        }
}else{
    #Get last line and add new values to it
    $newEntry = [PSCustomObject]@{
        Date              = $date
        computerRemoved   = $removedComputerTotal + $log[$logLength-1].computerRemoved
        groupsRemoved     = $removedGroupTotal + $log[$logLength-1].groupsRemoved
    }

    #Rebuild log excluding the last line
    #Only rebuild if not in log
    $log | Select-Object -SkipLast 1 | Export-Csv $logPath -NoTypeInformation
}

#Append last line
$newEntry | Export-Csv -append $logPath -NoTypeInformation
