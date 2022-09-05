Write-Host "A simple E3 updater"
Write-Host "Written by Rekka/Rekken from Lazarus to save sanity. (Mine and yours!)"
Write-Host "please modify the Invoke-WebREquest URL to change the file to download"
############################################################################
$downloadURL="https://github.com/Ewiclip/lazarus_mq2_e3/archive/refs/heads/master.zip"
############################################################################
Add-Type -Assembly System.IO.Compression.FileSystem
#Download the file 
Write-Host "Downloading file from github...$downloadURL"
Invoke-WebRequest $downloadURL -OutFile '.\e3Update.zip'
#Expand the file
Write-Host "Uncompressing file to e3Update.zip"
Expand-Archive '.\e3Update.zip' -DestinationPath '.\' -force
#lets get the 1st folder entry as we will need to rename it
$zip = [IO.Compression.ZipFile]::OpenRead(".\e3Update.zip")
$entries=$zip.Entries[0]
#close out the zip
$zip.Dispose();
#rename whatever the root folder was to e3UpdateFiles
Write-Host "Renaming decompressed folder to e3UpdateFiles"
Rename-Item ".\$entries" ".\e3UpdateFiles"
#Get a time stamp so we can rename the old macro folder
Write-Host "Getting timestamp for old folder"
$DateTime = (Get-Date).ToUniversalTime()
$UnixTimeStamp = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
#rename the old folder
Write-Host "Renaming old folder to Macros-old-$UnixTimeStamp"
Rename-Item ".\Macros" ".\Macros-old-$UnixTimeStamp"
#move the \Macros folder from the old e3Updates folder
Write-Host "Moving new Macro folder out of update folder"
Move-Item –Path .\e3UpdateFiles\Macros -Destination .\
#get rid of the new macro inis
Write-Host "Deleting new macro inis to reuse old ones"
Remove-Item ".\Macros\e3 Macro Inis" -Force -Recurse
Write-Host "Deleting new e3_PrivateCode.inc to reuse old one"

if ([System.IO.File]::Exists(".\Macros-old-$UnixTimeStamp\e3 Includes\e3_PrivateCode.inc")) {
    Remove-Item ".\Macros\e3 Includes\e3_PrivateCode.inc" -Force
}
Write-Host "Deleting new bot inis to reuse old ones"
Remove-Item ".\Macros\e3 Bot Inis" -Force -Recurse

#copy the old macro inis into the new install
Write-Host "Copying old macro inis"
Copy-Item –Path ".\Macros-old-$UnixTimeStamp\e3 Macro Inis" -Destination ".\Macros\e3 Macro Inis" -Recurse -Force

if ([System.IO.File]::Exists(".\Macros-old-$UnixTimeStamp\e3 Includes\e3_PrivateCode.inc")) {
    Write-Host "Copying old e3_PrivateCode.inc"
    Copy-Item –Path ".\Macros-old-$UnixTimeStamp\e3 Includes\e3_PrivateCode.inc" -Destination ".\Macros\e3 Includes\" -Force

}
Write-Host "Copying old bot inisc"
Copy-Item –Path ".\Macros-old-$UnixTimeStamp\e3 Bot Inis" -Destination ".\Macros\" -Recurse -Force


#delete the zip and folder
Write-Host "Cleaing up....."
Remove-Item ".\e3UpdateFiles" -Force -Recurse
Remove-Item ".\e3Update.zip" -Force
Write-Host "Done!"
pause
