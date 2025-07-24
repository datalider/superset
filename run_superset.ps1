# Apache Superset - Script de Execução para Windows
# Execute com: PowerShell -ExecutionPolicy Bypass -File run_superset.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Apache Superset - Iniciando Servidor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Verificar se o ambiente virtual existe
    if (-not (Test-Path "venv")) {
        Write-Host "ERRO: Ambiente virtual não encontrado." -ForegroundColor Red
        Write-Host "Execute primeiro: .\build_windows.ps1" -ForegroundColor Yellow
        Read-Host "Pressione Enter para sair"
        exit 1
    }

    # Ativar ambiente virtual
    Write-Host "Ativando ambiente virtual..." -ForegroundColor Yellow
    & "venv\Scripts\Activate.ps1"
    if ($LASTEXITCODE -ne 0) { throw "Falha ao ativar ambiente virtual" }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Superset iniciado com sucesso!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Acesse: http://localhost:8088" -ForegroundColor Yellow
    Write-Host "Usuário: admin" -ForegroundColor Yellow
    Write-Host "Senha: admin" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pressione Ctrl+C para parar o servidor" -ForegroundColor Cyan
    Write-Host ""

    # Iniciar Superset
    superset run -p 8088 --with-threads --reload --debugger

} catch {
    Write-Host ""
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Verifique se o build foi executado corretamente." -ForegroundColor Yellow
    Read-Host "Pressione Enter para continuar"
    exit 1
}