<# 
.SYNOPSIS 
Compresses and moves log files older than 7 days from specified folder to another.
.DESCRIPTION 
 If files older than 7 days are found in a given folder, the script will move them to archive folder.  

#>
param(
        [Parameter(
                    Mandatory=$true,
                    Position=0,
                    HelpMessage='Set path variable')]
        [string]$LogFolder
)


#$LogFolder=“C:\inetpub\logs\LogFiles\W3SVC4”

#days before compress
$arcdays=-7                                           

$tz = "C:\Program Files\7-Zip\7z.exe"                         
Set-Alias sz $tz
"Start $([System.DateTime]::Now) $LogFolder" | Out-File -FilePath "C:\support\start.txt" -Append -Force

$LastWrite=(get-date).AddDays($arcdays)
If ($Logs = get-childitem $LogFolder | Where-Object {$_.LastWriteTime -le "$LastWrite" -and !($_.PSIsContainer) -and ($_.Extension -eq ".log")} | sort-object LastWriteTime)
{
    foreach ($L in $Logs)
    {
        try
        {
            $OldFolder=$LogFolder+"\Old"
            $ValidPath=Test-Path $OldFolder
            If ($ValidPath -eq $False) 
            {
                New-Item -ItemType Directory -Force -Path $OldFolder -ErrorAction Stop
            }
            $FullName=$L.FullName
        
            $archFullName="$FullName.7z"
            $ValidPath=Test-Path ($OldFolder+"\"+$L.Name+".7z")
            If ($ValidPath -eq $False) 
            {

                sz a -t7z $archFullName $FullName 
                Move-Item $archFullName $OldFolder -ErrorAction Stop
                Remove-Item $FullName -Force -ErrorAction Stop
            }

        }
        catch 
        {
            $x = ($error[0] | out-string)
            "$([System.DateTime]::Now) Возникла ошибка $x при архивации в каталоге $LogFolder файл $FullName " | Out-File -FilePath "C:\support\errors.txt" -Append -Force
            exit
        }
        
    }
}
