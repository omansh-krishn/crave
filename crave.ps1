$username = [System.Environment]::UserName
$craveinstallpathpre = "C:\Users\$username"
$craveinstallpathpost = ".crave"
$craveinstallpath = "$craveinstallpathpre\$craveinstallpathpost"

$org = "accupara"
$repo = "crave"
$apiurl = "https://api.github.com/repos/$org/$repo/releases/latest"
$apiresponse = Invoke-RestMethod -Uri $apiurl -UseBasicParsing
$tagname = $apiresponse.tag_name
$cravezipurl = "https://github.com/$org/$repo/releases/download/$tagname/crave-windows-$tagname-Windows.zip"

if ($IsWindows) {
    Write-Host "Installing Crave"
} else {
    Write-Host "Only Windows host is supported for auto installation with this script."
    exit 1
}

$currentpath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)

if ($currentpath -notmatch [regex]::Escape($craveinstallpath)) {
    $newpath = "$currentpath;$craveinstallpath"
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, [System.EnvironmentVariableTarget]::User)
    $env:PATH = $newpath
    Write-Output "$craveinstallpath added to the current user's PATH."
} else {
    Write-Output "$craveinstallpath is already in the current user's PATH."
}

if (Test-Path -Path $craveinstallpath -PathType Container) {
    $contents = Get-ChildItem -Path $craveinstallpath

    if ($contents.Count -gt 0) {
        $timestamp = Get-Date -Format "dd-MM-HH-mm"
        $backupdirectoryname = "{0}-{1}" -f $craveinstallpath, $timestamp
        Move-Item -Path $craveinstallpath -Destination $backupdirectoryname
        Write-Host "Previous installation moved to $backupdirectoryname"
    } else {
        Write-Host "Not creating backup of $craveinstallpath, as it's empty."
    }
} else {
    Write-Host "Directory $craveinstallpath doesn't exist."
}

if (-not (Test-Path -Path $craveinstallpath)) {
    New-Item -ItemType Directory -Path $craveinstallpath | Out-Null
}

Invoke-WebRequest $cravezipurl -OutFile "crave-bin.zip"
Write-Output "Zip downloaded successfully.`nExpanding archive..."
Expand-Archive -Path "crave-bin.zip" -DestinationPath "crave-bin"
Move-Item -Path "./crave-bin/crave-windows/*" -Destination "$craveinstallpath" -Force
Remove-Item crave-bin.zip -Force
Remove-Item crave-bin -Recurse -Force
Write-Host "Crave is successfully installed in $craveinstallpath"
Write-Host "You can now execute 'crave' right away."