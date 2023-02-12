# for making 8 second discord videos, drag and drop mkv or mp4 onto the shortcut

# ffmpeg must be in %PATH% environment variable
# pwsh must be installed

# shortcut path:
#   pwsh.exe -nologo -noprofile -noexit -file <location of ConvertTo-8MBVideo.ps1>

[CmdletBinding()]
param (
    [Parameter(ValueFromRemainingArguments=$true)]
    $Path
)

$targetSizeKilobytes = 8192
$targetSizeKilobits = $targetSizeKilobytes * 8

# $Path will be equal to the fullpath of the file dragged-and-dropped onto the shortcut. We can now call ffmpeg with the path of the file
$fileToConvert = Get-Item -Path $Path
$fileOutputName = $fileToConvert.DirectoryName + "\" + $fileToConvert.BaseName + ".shrunk" + $fileToConvert.Extension

# Get length of video file and calculate required bit rate to get to under 8mb 
while($true){
    try{
        [int]$secondsToTrim = Read-Host "[+] Enter the desired number of seconds to trim from the start [0]"
        break
    }catch{
        Write-Output "[!] Enter an Integer"
    }
}
$inputVideoDuration = $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $fileToConvert) - $secondsToTrim
if(!($secondsToTrim)){
    [string]$secondsToTrim = "00:00:00"
}else{
    [string]$secondsToTrim = ([timespan]::fromseconds($secondsToTrim)).ToString("hh\:mm\:ss")
}

# Account for the audio bitrate for the total filesize
$totalBitrate = ([Math]::Round(($targetSizeKilobits / $inputVideoDuration), 0))
$audioBitrate = 96 #kbps
$videoBitrate = $totalBitrate - $audioBitrate

# How often to check the target size is being adhered to... Higher number *should* give a better quality due to encoding optimizations, but higher risk of being oversize. 
# Lower number = more frequent checks, but potentially less optimized
$bufMultiplier = 1.5

$bufSize = $totalBitrate * $bufMultiplier

Write-Output "[-] Shrinking $($fileToConvert) to (hopefully!) under $($targetSizeKilobytes / 1024)MB. Bitrate: $($totalBitrate)k "

ffmpeg -y -hide_banner -loglevel error `
-ss $secondsToTrim `
-i "$fileToConvert" `
-c:v libx264 -strict -2 -passlogfile "$env:temp"`
-vf scale=-1:720 `
-b:v "$($videoBitrate)k" `
-b:a "$($audioBitrate)k" `
-maxrate "$($totalBitrate)k" `
-bufsize "$($bufSize)k" `
-preset veryslow `
-pass 1 `
-f mp4 NUL

ffmpeg -y -hide_banner -loglevel error `
-ss $secondsToTrim `
-i "$fileToConvert" `
-c:v libx264 -strict -2 -passlogfile "$env:temp"`
-vf scale=-1:720 `
-b:v "$($videoBitrate)k" `
-b:a "$($audioBitrate)k" `
-maxrate "$($totalBitrate)k" `
-bufsize "$($bufSize)k" `
-preset veryslow `
-pass 2 `
$fileOutputName

$afterSizeBytes = (Get-Item $fileOutputName).Length
$shrinkPercentage = ([Math]::Round((($afterSizeBytes / $fileToConvert.Length) * 100), 2))
Write-Output "[-] Rebuilt file as $($fileOutputName)"
Write-Output "[-] Shrank to $($shrinkPercentage)% of original size"
