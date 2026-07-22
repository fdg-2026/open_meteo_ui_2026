$projectName = "open_meteo_ui_2026"
$buildDir = ".\build\app\outputs\flutter-apk"
$repoName = "apks"
$dest = "..\${repoName}"
#$dest = "C:\flutter\code\fdg-2026\${repoName}\${projectName}"

Write-Output "building apk ..."
flutter build apk --release

Write-Output "copying apk to $dest"
Copy-Item -Path "$buildDir\app-release.apk" -Destination "$dest\$projectName.apk" -Force

#Pause

Push-Location
Set-Location $dest

Write-Output "performing git commit ..."
git add .
git commit -m "new delivery of ${projectName}.apk"

Write-Output "performing git push ..."
git push

Pop-Location