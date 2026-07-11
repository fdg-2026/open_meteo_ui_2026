$projectName = "open_meteo_ui_2026"
$webRepoName = "web"
$dest = "..\${webRepoName}\${projectName}"
#$dest = "C:\flutter\code\fdg-2026\${webRepoName}\${projectName}"

Write-Output "building web app ..."
flutter build web --base-href /${webRepoName}/${projectName}/

if (Test-Path -Path $dest -PathType Container) {
    Write-Output "deleting destination $dest"
    Remove-Item -Path $dest -Recurse
}
Write-Output "copying web app to $dest"
Copy-Item -Path "build\web" -Destination $dest -Recurse 

#Pause

Push-Location
Set-Location $dest

Write-Output "performing git commit ..."
git add .
git commit -m "new delivery of ${projectName}"

Write-Output "performing git push ..."
git push

Pop-Location