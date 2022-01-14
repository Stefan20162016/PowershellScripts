# PowershellScripts
powershell backup from contextmenu with robocopy

- features: predefined destination paths e.g. "Project1" and "Project2" or select with Windows Forms Dialog

- create directory C:\PowerShellScripts\
- copy BackupWithRobo.ps1 in there
- double click reg_complete.reg to add context menus for folder right click and background right click ( not selecting any file or folder)
- c:\PowerShellScripts\robolog.txt saves the output of the last run

- change $mainBackupDir = "D:\Robo Backup" to suite your needs

- will create directory with date&timestamp in destination dir and in there a dir with source dir name

![a](screenshots/screen_rightfolder.jpg)

![b](screenshots/screen_rightbackground.jpg)

![c](screenshots/screen_select.jpg)

![d](screenshots/screen_select2.jpg)

![e](screenshots/screen_select3.png)
