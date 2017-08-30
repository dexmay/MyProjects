<# 
.SYNOPSIS 
Compresses and moves log files older than 7 days from specified folder to another.
.DESCRIPTION 
 If files older than $arcdays days are found in a given folder, the script will remove it.  

#>

param(
        [Parameter(
                    Mandatory=$true,
                    Position=0,
                    HelpMessage='Set path variable')]
        [string]$LogFolder
)



#days before compress

$arcdays=-65                                           


#"Start $([System.DateTime]::Now) $LogFolder" | Out-File -FilePath "C:\support\start.txt" -Append -Force

$LastWrite=(get-date).AddDays($arcdays)
If ($Logs = get-childitem $LogFolder | Where-Object {$_.LastWriteTime -le "$LastWrite" -and !($_.PSIsContainer) -and ($_.Extension -eq ".bak")} | sort-object LastWriteTime)
{
    foreach ($L in $Logs)
    {
        try
        {
        
            $FullName=$L.FullName
             
            Remove-Item $FullName -Force -ErrorAction Stop 
            "Remove  at $([System.DateTime]::Now) file $FullName" | Out-File -FilePath "C:\support\actionlist.txt" -Append -Force

        }
        catch 
        {
            $x = ($error[0] | out-string)
            "$([System.DateTime]::Now) Возникла ошибка $x при удалении в каталоге $LogFolder файл $FullName " | Out-File -FilePath "C:\support\errors.txt" -Append -Force
            exit 1
        }
        
    }
}
