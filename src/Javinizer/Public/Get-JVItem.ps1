#Requires -PSEdition Core

function Get-JVItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Path,

        [Parameter()]
        [Switch]$Recurse,

        [Parameter()]
        [Int]$Depth,

        [Parameter()]
        [Switch]$Strict,

        [Parameter()]
        [PSObject]$Settings,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.minimumfilesize')]
        [Int]$MinimumFileSize,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.excludedfilestring')]
        [Array]$ExcludedStrings,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.includedfileextension')]
        [Array]$IncludedExtensions,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex')]
        [Boolean]$RegexEnabled,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex.string')]
        [String]$RegexString,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex.idmatch')]
        [Int]$RegexIdMatch,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('match.regex.ptmatch')]
        [Int]$RegexPtMatch
    )

    process {
        $fileObject = @()
        if ($Settings) {
            $MinimumFileSize = $Settings.'match.minimumfilesize'
            $ExcludedStrings = $Settings.'match.excludedfilestring'
            $IncludedExtensions = $Settings.'match.includedfileextension'
            $RegexEnabled = $Settings.'match.regex'
            $RegexString = $Settings.'match.regex.string'
            $RegexIdMatch = $Settings.'match.regex.idmatch'
            $RegexPtMatch = $Settings.'match.regex.ptmatch'
        }

        if ($ExcludedStrings) {
            if ($Depth) {
                $files = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse -Depth:$Depth -Exclude:$ExcludedStrings | Where-Object {
                    $_.Extension -in $IncludedExtensions `
                        -and $_.Length -ge ($MinimumFileSize * 1MB)
                }
            } else {
                $files = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse -Exclude:$ExcludedStrings | Where-Object {
                    $_.Extension -in $IncludedExtensions `
                        -and $_.Length -ge ($MinimumFileSize * 1MB)
                }
            }

        } else {
            if ($Depth) {
                $files = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse -Depth:$Depth | Where-Object {
                    $_.Extension -in $IncludedExtensions `
                        -and $_.Length -ge ($MinimumFileSize * 1MB)
                }
            } else {
                $files = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse -Depth:$Depth | Where-Object {
                    $_.Extension -in $IncludedExtensions `
                        -and $_.Length -ge ($MinimumFileSize * 1MB)
                }
            }
        }

        if ($RegexEnabled) {
            $files = $files | Where-Object { $_.BaseName -match $RegexString }
            foreach ($file in $files) {
                $fileObject += $file | Convert-JVTitle -Strict:$Strict -RegexEnabled:$RegexEnabled -RegexString $RegexString -RegexIdMatch $RegexIdMatch -RegexPtMatch $RegexPtMatch
            }
        } else {
            foreach ($file in $files) {
                $fileObject += $file | Convert-JVTitle -Strict:$Strict -RegexEnabled:$RegexEnabled
            }
        }

        Write-Output $fileObject
    }
}
