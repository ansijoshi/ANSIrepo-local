if (Test-Path "C:\temp\HostSystemInfo\$env:COMPUTERNAME.xlsx") {
Remove-Item "C:\temp\HostSystemInfo\$env:COMPUTERNAME.xlsx" -Force
}
#Remove-Item "C:\temp\HostSystemInfo\$env:COMPUTERNAME.xlsx"
$csvs = Get-ChildItem C:\temp\HostSystemInfo\Reports\Computers\* -Include *.csv

$excelapp = new-object -comobject Excel.Application
$excelapp.sheetsInNewWorkbook = $csvs.Count
$xlsx = $excelapp.Workbooks.Add()
$sheet=1

write-host "Please avoid closing this window till you see a completion alert..." -foreground "red"
write-host ""

foreach ($csv in $csvs)
{
$row=1
$column=1
$worksheet = $xlsx.Worksheets.Item($sheet)
$worksheet.Name = $csv.Name
$file = (Get-Content $csv)
foreach($line in $file)
{
$linecontents=$line -split ‘,(?!\s*\w+”)’
foreach($cell in $linecontents)
{
$worksheet.Cells.Item($row,$column) = $cell
$column++
}
$column=1
$row++
}
$sheet++
}

$xlsx.SaveAs("C:\temp\HostSystemInfo\$env:COMPUTERNAME")
$excelapp.quit()
if (Test-Path "C:\temp\HostSystemInfo\Reports") {
Remove-Item "C:\temp\HostSystemInfo\Reports" -Force -Recurse 
}
if (Test-Path "C:\temp\HostSystemInfo\System Files") {
Remove-Item "C:\temp\HostSystemInfo\System Files" -Force -Recurse 
}
#Remove-Item "C:\temp\HostSystemInfo\Reports\Computers\*"

write-host "HostSystemInfo Excel sheet generated successfully at: C:\temp\HostSystemInfo !!!" -foreground "green"