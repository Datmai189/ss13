# AUDIT: Da tham dinh script, khong co lenh xoa hang loat nguy hiem.

$logPath = "..\data\log-he-thong.log"
$reportPath = "..\backup\bao-cao-su-co.txt"

Write-Output "BAO CAO SU CO HE THONG SMARTFARM" > $reportPath
Write-Output ("THOI GIAN TAO: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) >> $reportPath
Write-Output "" >> $reportPath
Write-Output "DANH SACH SU CO:" >> $reportPath

Get-Content $logPath | Select-String -Pattern "CRITICAL|ERROR" | ForEach-Object { $_.Line } >> $reportPath

$errorCount = Get-Content $logPath | Select-String -Pattern "CRITICAL|ERROR" | Measure-Object

Write-Output "" >> $reportPath
Write-Output ("TONG SO SU CO: " + $errorCount.Count) >> $reportPath
