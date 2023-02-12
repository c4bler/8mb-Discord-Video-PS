# 8mb-Discord-Video-PS
Create 8MB 720p Discord Videos from a Desktop Shortcut

Based on the work of https://github.com/matthewbaggett/8mb
I simply converted the script from bash to PowerShell, essentially.

## Usage
I use this to shrink down Xbox Game Bar 1-minute captures for sharing in Discord. Because of this I included a feature to input a trim-seconds-from-start so the action that was recorded will be the best quality.

The script will automatically increase bitrate the shorter the clip is to be as close to 8mb as possible. It also autosizes to 720p.

Good to know is the $bufMultiplier variable which will change -bufsize in ffmpeg. This determines how often ffmpeg will check the size is being adhered to (e.g every 2kb).
More frequent checks will ensure filesize is adhered to but will potentially sacrifice some optimizations that could be achieved to get a better quality.
Common values for -bufsize are between 1 and 2 times the bitrate. Well explained here: https://superuser.com/a/946343

## Shortcut Path
`"C:\Program Files\PowerShell\7\pwsh.exe" -nologo -noprofile -noexit -file "<Path to ConvertTo-8MBVideo.ps1>"`

You can then drag .mp4 or .mkv files on top of the shortcut and the script will run in pwsh.

## Prerequisites
1. ffmpeg must be installed, and in %PATH%. Can be installed via Chocolatey: `choco install ffmpeg`
2. pwsh (PowerShell v7) should be installed, powershell.exe is untested but may work.

## Output
Files will be outputted at the original path with .shrunk at the end of the filename and before the extension.
