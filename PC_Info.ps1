    #(C)Robin Wohlgemuth#
    ##
    Import-Module ActiveDirectory
    ##
    $computername = Read-Host "Computernamen eingeben..."

    if (Test-Connection -ComputerName $computername -Count 1 -Quiet)
    {
    ####IPv4 Addresse herausfiltern####
    $ip = gwmi Win32_NetworkAdapterConfiguration -ComputerName $computername | select -expand ipaddress | where {$_ -like "*.*"} 
    ##################################

    ##WMI Queries##
    $mac = gwmi Win32_NetworkAdapterConfiguration -ComputerName $computername | where {$_.DHCPEnabled -eq $True -and $_.IPAddress -ne $null} | select -ExpandProperty Macaddress
    $seriennummer_pc = gwmi win32_bios -ComputerName $computername | select -ExpandProperty serialnumber
    $modell_pc = gwmi –class Win32_ComputerSystem -ComputerName $computername | select -expand Model
    ##################################


    ##Arbeitsspeicher##
    $memory = Get-WmiObject -class "win32_physicalmemory" -namespace "root\CIMV2" -ComputerName $computername
    if (($memory.count) -gt 1){
    $total_memory = ($memory.capacity -join '+' | Invoke-Expression) / 1MB
    }
    else
    {
    $total_memory = ($memory.capacity) / 1MB
    }
    $TotalSlots = ((Get-WmiObject -Class "win32_PhysicalMemoryArray" -namespace "root\CIMV2" -ComputerName $computername).MemoryDevices | Measure-Object -Sum).Sum
    $UsedSlots = (($memory) | Measure-Object).Count 
    ##Bitlocker Schlüssel
    $computer_dn = (Get-ADComputer $computername).distinguishedname
    $recovery = Get-ADObject -Filter 'objectclass -eq "msFVE-RecoveryInformation"' -SearchBase $computer_dn -Properties msfve-recoverypassword,whencreated | sort whencreated -Descending | select -ExpandProperty msfve-recoverypassword -Last 1

    ##GET AD INFOs##
    $adinfo = Get-ADComputer $computername -Properties *

    $items_modell = @()
    $items_SN = @()

    $output = Write-Host -BackgroundColor Black -ForegroundColor Green "Computername: $computername"
    Write-Host -BackgroundColor Black -ForegroundColor Green "IP-Adresse: $ip"
    Write-Host -BackgroundColor Black -ForegroundColor Green "MAC-Adresse(aktiv): $mac"
    Write-Host -BackgroundColor Black -ForegroundColor Green "Seriennummer PC: $seriennummer_pc"
    Write-Host -BackgroundColor Black -ForegroundColor Green "Modell PC: $modell_pc"
    Write-Host -BackgroundColor Black -ForegroundColor Green "Betriebssystem PC: "$adinfo.OperatingSystem""
    Write-Host -BackgroundColor Black -ForegroundColor Green "Description PC: "$adinfo.Description""
    Write-Host -BackgroundColor Black -ForegroundColor Green "Modell PC: $modell_pc"
    Write-Host -BackgroundColor Black -ForegroundColor Green "RAM: $total_memory Megabyte - $UsedSlots von $TotalSlots Slots in Benutzung"
    Write-Host -BackgroundColor Black -ForegroundColor Green "Wiederherstellungsschlüssel: $recovery"
    Write-Host ""
    Write-Host -BackgroundColor Black -ForegroundColor Green "#####################"
    Write-Host ""


    Write-Host ""
    Write-Host ""
    Write-Host -backgroundcolor black -foregroundcolor yellow "#####################################################################################"
    Write-Host -backgroundcolor black -foregroundcolor yellow "#Geben Sie den nächsten Computername ein oder beenden Sie das Programm mit STRG-C!#"
    Write-Host -backgroundcolor black -foregroundcolor yellow "#####################################################################################"
    Write-Host ""
    Write-Host ""
    }
    else
    { 
    Write-Host -BackgroundColor Black -ForegroundColor Red "Der Computer mit dem Namen $computername ist offline / nicht erreichbar."
    ##Bitlocker Schlüssel
    $computer_dn = (Get-ADComputer $computername).distinguishedname
    $recovery = Get-ADObject -Filter 'objectclass -eq "msFVE-RecoveryInformation"' -SearchBase $computer_dn -Properties msfve-recoverypassword,whencreated | sort whencreated -Descending | select -ExpandProperty msfve-recoverypassword -Last 1
    Write-Host -BackgroundColor Black -ForegroundColor Green "Wiederherstellungsschlüssel: $recovery"
    }
