function Audit-OldComputers([int]$daysSinceLogin, [switch]$ping = $false, [string]$excludeOU, [string]$filter, [array]$computerGroups) {

    $i=0

    $daysAgo = (Get-Date -Date (Get-Date).AddDays(-$daysSinceLogin) -Format "yyyy/MM/dd")
    
    $filterDefault = '(LastLogonDate -lt' + " `"$daysAgo`")"

    #If no filter provided, just pull days since
    if(![string]::IsNullOrEmpty($filter)){
        $filter = $filter +" -and " + $filterDefault
    }else{
        $filter = $filterDefault
    }

    $computers = Get-ADComputer -Properties LastLogonDate, OperatingSystem,LastLogonTimeStamp -Filter $filter

    if($excludeOU -ne ""){
        $computers = $computers| ? {$_.DistinguishedName -notlike "*$excludeOU*"}
    }

    $oldComputers = [System.Collections.ArrayList]::new()

    foreach ($computer in $computers) {


        ($computer.SamAccountName).replace("$","")
        $object = [PSCustomObject]@{
            Name         = $(($computer.SamAccountName).replace("$",""))
            LastLogonDate = $computer.LastLogonDate
            Enabled      = $computer.Enabled
            LastLogonTimeStamp = [DateTime]::FromFileTime($computer.LastLogonTimeStamp)
            DistinguishedName = $computer.DistinguishedName
        }

        if ($ping) {
            if((New-Object System.Net.NetworkInformation.Ping).SendPingAsync("$($computer.name)").result.status -like "Success"){$value=$true}else{$value=$false}
            $object | Add-Member -MemberType NoteProperty -Name 'PINGABLE' -Value ($value)
        }

        #if groups provided, confirm if groups exist
        #TODO : Flexable group name
        if(![string]::IsNullOrEmpty($computerGroups)){
            foreach($group in $computerGroups){
                $object | Add-Member -Name $group -Type NoteProperty -Value $([bool](Get-ADGroup -filter "name -like '$($computer.Name) $($group)*'"))
            }
        }


        $oldComputers.Add($object) | Out-Null

        $i++
        Write-Progress -Activity "Audit In Progress" -Status "$($i)/$($computers.length) % Complete:" -PercentComplete $(($i/$computers.length)*100)        

    }

    return $oldComputers
}


#example
#oldComputers = Audit-OldComputers -daysSinceLogin (90) -ping -excludeOU "" -filter '(OperatingSystem -notlike "*Server*") -and (OperatingSystem -like "*Windows*")' -computerGroups "Administrators","RemoteUsers"


