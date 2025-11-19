<#
.SYNOPSIS
Instala scripts de limpeza automática para laboratórios UFRN.
Autor: Fabiano Campos da Cruz - Técnico de TI - CT
Versão: 1.0 - 09/10/2025
#>

Write-Host "=== Instalador de Limpeza de Perfis e Pastas ===" -ForegroundColor Cyan

# Caminho dos scripts
$dir = "C:\Scripts"
if (!(Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory | Out-Null
    Write-Host "Criada pasta: $dir"
}

# -----------------------------
# 1. Script de limpeza de perfis
# -----------------------------
$scriptPerfis = @'
# LimparPerfis.ps1
# Remove perfis de usuário (exceto padrões) no boot

# Incluir aqui outros perfis que não se queira remover
$excluir = @(
    'C:\Users\Administrator',
    'C:\Users\Administrador',
    'C:\Users\Public',
    'C:\Users\Default',
    'C:\Users\Default User',
    'C:\Users\ADM LABCAD',
    'C:\Users\CT-Redes',
    'C:\Users\modelagem'
)

Get-CimInstance -ClassName Win32_UserProfile | Where-Object {
    $_.LocalPath -and
    ($excluir -notcontains $_.LocalPath) -and
    (-not $_.Special) -and
    (-not $_.Loaded)
} | ForEach-Object {
    try {
        Remove-CimInstance -InputObject $_ -ErrorAction Stop
        Write-Output "Removido: $($_.LocalPath)"
    } catch {
        Write-Output "Falha ao remover $($_.LocalPath): $_"
    }
}
'@

Set-Content -Path "$dir\LimparPerfis.ps1" -Value $scriptPerfis -Encoding UTF8
Write-Host "Script criado: $dir\LimparPerfis.ps1"

# -----------------------------
# 2. Script de limpeza de pastas
# -----------------------------
$scriptPastas = @'
# Limpa downloads, documentos públicos e temporários
$pastas = @(
    "C:\Users\Public\Downloads",
    "C:\Users\Public\Documents",
    "C:\Temp",
    "C:\Windows\Temp"
)

foreach ($p in $pastas) {
    if (Test-Path $p) {
        Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
}
'@

Set-Content -Path "$dir\LimparPastas.ps1" -Value $scriptPastas -Encoding UTF8
Write-Host "Script criado: $dir\LimparPastas.ps1"

# -----------------------------
# 3. Criar tarefas agendadas
# -----------------------------
Write-Host "Registrando tarefas agendadas..." -ForegroundColor Yellow

# Remove tarefas antigas, se existirem
$tasks = @("Limpar Perfis de Usuário","Limpar Pastas Públicas")
foreach ($t in $tasks) {
    if (Get-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $t -Confirm:$false
    }
}

$action1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$dir\LimparPerfis.ps1`""
$action2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$dir\LimparPastas.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero)

# Tarefa 1: limpeza de perfis
Register-ScheduledTask -Action $action1 -Trigger $trigger -Principal $principal -TaskName "Limpar Perfis de Usuário" -Description "Remove perfis de alunos no boot" -Settings $settings

# Tarefa 2: limpeza de pastas
Register-ScheduledTask -Action $action2 -Trigger $trigger -Principal $principal -TaskName "Limpar Pastas Públicas" -Description "Apaga pastas públicas e temporárias" -Settings $settings

Write-Host "Tarefas registradas com sucesso." -ForegroundColor Green
Write-Host "Instalação concluída!" -ForegroundColor Cyan
Write-Host "Os perfis e pastas públicas serão limpos a cada reinicialização." -ForegroundColor Cyan
