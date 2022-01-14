Param(
# first parameter is a switch if 0: second parameter is the destination directory
# if first para is 1 you can select the destination dir in a windows.forms form
# second paramter makes subdirectory in e.g. D:\Robo Backup\Second Parameter\<Current DateTime>\
# third para is source directory
#
# e.g. .\BackupWithRobo.ps1 0 Projekt_Win32 "D:\repo\win32"
# will backup to directory $mainbackupDir\ProjektWin32\20220113_150130\ e.g. D:\Robo Backup\ProjektWin32\20220113_150130\ 
# .\BackupWithRobo.ps1 1 PLACEHOLDER "D:\repo\win32" will open GUI to select dir

    [Parameter(Mandatory=$True)]
    [bool]$selectFolder=$False,
    [Parameter(Mandatory=$True)]
    [string]$PARAtargetDir,
    [Parameter(Mandatory=$True)]
    [string]$sourceDir
)


Write-Host $sourceDir


$registryplaceholder = "PLACEHOLDERFORDOUBLEESCAPE" # to not escape the backslash in e.g. \"C:\\"

$sourceDir = $sourceDir.Substring(0, $sourceDir.Length - $registryplaceholder.Length)
Write-Host $sourceDir


$mainbackupDir = "D:\Robo Backup\"

function GetDestFolderPath {

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Global:selectedFolderSwitch = 0
$window = New-Object System.Windows.Forms.Form
$window.Width = 800
$window.Height = 400

$windowFolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Size(20,20)
$Label.Font = New-Object System.Drawing.Font("",16,[System.Drawing.FontStyle]::Regular)
$Label.Text = "selected folder path"
$Label.AutoSize = $True
$window.Controls.Add($Label)
$windowTextBox = New-Object System.Windows.Forms.TextBox

  $windowButton = New-Object System.Windows.Forms.Button
  $windowButton.Location = New-Object System.Drawing.Size(18,290)
  $windowButton.Size = New-Object System.Drawing.Size(90,60)
  $windowButton.Text = "OK"
  $windowButton.Add_Click(
  {
     $window.Dispose()
     Write-Host "okay button path: " $windowFolderBrowser.SelectedPath

  })
 
$window.Controls.Add($windowButton)


$selectFolderButton = New-Object System.Windows.Forms.Button
$selectFolderButton.Location = New-Object System.Drawing.Size(18,90)
$selectFolderButton.Size = New-Object System.Drawing.Size(90,60)
$selectFolderButton.Text = "Select Folder"
$selectFolderButton.Add_Click({
    Write-Host "Select Folder Button Clicked"
    $result = $windowFolderBrowser.ShowDialog()
    if($result -eq "OK")
    {
        Write-Host "selecting folder is okay: " $windowFolderBrowser.SelectedPath
        #Write-Host $windowFolderBrowser.SelectedPath
        $Label.Text = $windowFolderBrowser.SelectedPath
        $Global:selectedFolderSwitch = 1
    }
})

$window.Controls.Add($selectFolderButton)

[void]$window.ShowDialog()

# RETURN FROM HERE

if($Global:selectedFolderSwitch -eq 1)
{
    Write-Host "returning (nonempty): " $windowFolderBrowser.SelectedPath
    return $windowFolderBrowser.SelectedPath
}
else 
{ 
    Write-Host "returning empty string"
    return "" 
}

}

Write-Host "Backup of Directory: $sourceDir"
$datestring = get-date -UFormat “%Y%m%d_%H%M%S”
Write-Host "Backup to: $destDir"

$subdir = $sourceDir.Split('\')[-1]         # create directory with source dir name
if ($subdir -eq ":") { $subdir=""  }        # for root drives e.g. "D:\"
Write-Host "create subdir in destination " $subdir

if($selectFolder -eq $True)
{
    $a = GetDestFolderPath
    Write-Host "selected Path is: " $a
    if($a -eq ""){
        Write-Host "no path selected: exiting here"
        return
    }
    $destDir = "$a\$datestring\$subdir"
    
}

else 
{
    $destDir = "$mainbackupDir$PARAtargetDir\$datestring\$subdir"
}

# cleanup of sourceDir and destDir for D:\ cases where the backslash escapes the following arguments
if($sourceDir[-1] -eq '\') 
{
    $sourcedir = $sourceDir.Substring(0, $sourceDir.Length - 1)
}
if($destDir[-1] -eq '\')
{
    $destDir = $destDir.Substring(0, $destDir.Length - 1)
}

Write-Host "BackUp Source: " $sourceDir
Write-Host "BackUp Destination: " $destDir
Write-Host "subdir: " $subdir


Start-Process -NoNewWindow -Wait -FilePath "C:\WINDOWS\system32\Robocopy.exe" -ArgumentList "`"$sourceDir`"","`"$destDir`"","/LOG:c:\PowerShellScripts\robolog.txt","/MIR /COPY:DAT /MT:32 /R:2 /W:1 /NFL /NDL /V /TEE"





