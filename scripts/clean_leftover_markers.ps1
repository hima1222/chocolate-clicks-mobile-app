Param(
    [string]$Root = ".",
    [string[]]$Extensions = @("*.dart","*.yaml","*.md","*.txt")
)

Get-ChildItem -Path $Root -Recurse -Include $Extensions -File | ForEach-Object {
    $path = $_.FullName
    try {
        $lines = Get-Content -Encoding UTF8 -Path $path -ErrorAction Stop
    } catch {
        Write-Output "Skip (read error): $path"
        return
    }
    $changed = $false
    $newLines = @()
    foreach ($line in $lines) {
        $trim = $line.Trim()
        if ($trim -match '^(origin\/\S+|HEAD)$') {
            $changed = $true
            continue
        }
        $newLines += $line
    }
    if ($changed) {
        Set-Content -Path $path -Value $newLines -Encoding UTF8
        Write-Output "Cleaned: $path"
    }
}
