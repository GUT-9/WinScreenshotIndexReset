
#Requires -Version 5.1
<#
.SYNOPSIS  重置 Windows 截屏计数器（仅当 ScreenshotIndex 已存在时）


#>

param()

$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$name    = "ScreenshotIndex"


# -------------- 自动提权 --------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "正在请求管理员权限..." -ForegroundColor Yellow
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName        = "powershell.exe"
    $psi.Arguments       = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb            = "runas"
    $psi.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    exit
}

# -------------- 主逻辑 --------------
$exists = $false
try {
    $exists = ($null -ne (Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue).$name)
}
catch { <# 路径本身不存在会抛异常，直接当不存在处理 #> }

if (-not $exists) {
    Write-Host "注册表值 $regPath\$name 不存在，已取消操作。" -ForegroundColor Red
    Read-Host "`n按 Enter 退出"
    exit
}

# 真正重置
Set-ItemProperty -Path $regPath -Name $name -Value 0 -Type DWord -Force
Write-Host "已把 $regPath\$name 重置为 0，下次截屏将从 1 开始计数。" -ForegroundColor Green
Read-Host "`n按 Enter 退出"
