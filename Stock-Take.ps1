##You need to put the Computernames in the Txt-document which is declared in $computername.
##Export happens in the same folder as $computername path or change in line 58 / 59

$computername = Get-Content "C:\Stock\pc.txt"
$items = @()
$items2 = @()


ForEach ($computer in $computername) 
{
    if (Test-Connection $computer -ErrorAction SilentlyContinue -count 1)
    {
    ####IPv4 Addresse herausfiltern####
    $ip = gwmi Win32_NetworkAdapterConfiguration -ComputerName $computer | where {$_.DHCPEnabled -eq $True -and $_.IPAddress -ne $null} | select -expand IPAddress 
    $ipstring = [string]$ip
    ##################################

    ##WMIC Abfragen##
    $ipv4 = $ipstring[0,1,2,3,4,5,6,7,8] -join ''
    $mac = gwmi Win32_NetworkAdapterConfiguration -ComputerName $computer | where {$_.DHCPEnabled -eq $True -and $_.IPAddress -ne $null} | select -ExpandProperty Macaddress
    $seriennummer_pc = gwmi win32_bios -ComputerName $computer | select -ExpandProperty serialnumber
    $modell_pc = gwmi –class Win32_ComputerSystem -ComputerName $computer | select -expand Model
    ##################################

        $obj2 = New-Object -type psobject
        $obj2 | Add-Member -Name ("Computername") -value $computer -MemberType NoteProperty -Force  
        $obj2 | add-member -Name ("MAC-Address") -value $mac -MemberType NoteProperty -Force
        $obj2 | add-member -Name ("Serialnumber PC") -value $seriennummer_pc -MemberType NoteProperty -Force  
        $obj2 | add-member -Name ("Modell PC") -value $modell_pc -MemberType NoteProperty -Force
        $obj2 | add-member -Name ("IP Address") -value $ipv4 -MemberType NoteProperty -Force
        $items2 += $obj2
        write-host  "$computer checked.."

    $Monitors = Get-WmiObject -ComputerName $computer -Namespace root\wmi -Class wmiMonitorID    

    Foreach ($Monitor in $Monitors)
    {
                 
        $obj = new-object -type psobject
        $obj | Add-Member -Name ("Computername") -value $computer -MemberType NoteProperty -Force  
        $obj | add-member -Name ("Monitor" +" Modell") -Value ([char[]]$Monitor.UserFriendlyName -join '') -MemberType NoteProperty -Force
        $obj | add-member -Name ("Monitor" +" Serial") -Value ([char[]]$Monitor.SerialNumberID -join '') -MemberType NoteProperty -Force
        $i++
        $items += $obj
    
    }
 }
 else
 {
       $obj2 = New-Object -type psobject
        $obj2 | Add-Member -Name ("Computername") -value $computer -MemberType NoteProperty -Force  
        $obj2 | add-member -Name ("Seriennummer PC") -value ("Offline") -MemberType NoteProperty -Force  
                $items2 += $obj2
        Write-Host -ForegroundColor Red "$computer offline.."
 }
 }

$items | export-csv -path C:\Stock\Monitors.csv -Append
$items2 | export-csv -path C:\Stock\Computers.csv -Append
