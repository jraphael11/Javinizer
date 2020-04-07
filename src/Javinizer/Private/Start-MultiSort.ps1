function Start-MultiSort {
    [CmdletBinding()]
    param (
        [system.io.fileinfo]$Path,
        [system.io.fileinfo]$DestinationPath,
        [switch]$Recurse,
        [object]$Settings,
        [ValidateRange(1, 15)]
        [int]$Throttle,
        [switch]$Strict,
        [switch]$MoveToFolder,
        [switch]$RenameFile,
        [switch]$Force
    )

    #$files = Get-ChildItem "Z:\git\Projects\JAV-Organizer\dev\dev" | Where-Object { $_.Mode -eq '-a----' -and $_.Extension -eq '.mp4' }
    $files = Get-VideoFile -Path $Path -Recurse:$Recurse -Settings $Settings
    $ScriptRoot = $PSScriptRoot
    $ScriptRoot = (Get-Item $ScriptRoot).Parent

    if ($Force.IsPresent) { $forcePreference = $true } else { $forcePreference = $false }

    if ($Strict.IsPresent) { $strictPreference = $true } else { $strictPreference = $false }

    if ($MoveToFolder.IsPresent) { $movePreference = $true } else { $movePreference = $false }

    if ($RenameFile.IsPresent) { $renamePreference = $true } else { $renamePreference = $false }

    $importVariables = @(
        'ScriptRoot',
        'DestinationPath',
        'Session',
        'forcePreference',
        'strictPreference',
        'movePreference',
        'renamePreference'
    )

    $files | Start-RSJob -VariablesToImport $importVariables -Verbose:$false -ScriptBlock {
        Javinizer -Path $_.FullName -DestinationPath $DestinationPath -ScriptRoot $ScriptRoot -Strict:$strictPreference -MoveToFolder:$movePreference -RenameFile:$renamePreference -Force:$forcePreference
    } -Throttle $Throttle -FunctionFilesToImport (Join-Path -Path $PSScriptRoot -ChildPath 'Get-AggregatedDataObject.ps1'), `
    (Join-Path -Path (Get-Item $PSScriptRoot).Parent -ChildPath (Join-Path 'Public' -ChildPath 'Javinizer.ps1')), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Convert-CommaDelimitedString.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Convert-HTMLCharacter.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Convert-JavTitle.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-DmmDataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-FindDataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-JavlibraryDataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-JavlibraryUrl.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-MetadataNfo.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-MetadataPriority.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-NewFileDirName.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-R18DataObject.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-R18ThumbCsv.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-R18Url.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-TimeStamp.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-TranslatedString.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Get-VideoFile.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Import-IniSettings.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'New-CloudflareSession.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Set-JavMovie.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Test-RequiredMetadata.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Test-UrlLocation.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Test-UrlMatch.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Write-Log.ps1'), `
    (Join-Path -Path $PSScriptRoot -ChildPath 'Update-Javinizer.ps1') | Wait-RSJob -ShowProgress | Receive-RSJob
}
