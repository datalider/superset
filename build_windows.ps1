# Apache Superset - Build Script para Windows (PowerShell)
# Execute com: PowerShell -ExecutionPolicy Bypass -File build_windows.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Apache Superset - Build para Windows" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Função para verificar se um comando existe
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Verificar Python
if (-not (Test-Command "python")) {
    Write-Host "ERRO: Python não encontrado." -ForegroundColor Red
    Write-Host "Instale Python 3.10 ou 3.11 de: https://www.python.org/downloads/" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Verificar Node.js
if (-not (Test-Command "node")) {
    Write-Host "ERRO: Node.js não encontrado." -ForegroundColor Red
    Write-Host "Instale Node.js 20.16.0+ de: https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Mostrar versões
Write-Host "Verificando versões..." -ForegroundColor Green
Write-Host "Python: $(python --version)"
Write-Host "Node.js: $(node --version)"
Write-Host "NPM: $(npm --version)"
Write-Host ""

try {
    # Criar ambiente virtual
    if (-not (Test-Path "venv")) {
        Write-Host "Criando ambiente virtual Python..." -ForegroundColor Yellow
        python -m venv venv
        if ($LASTEXITCODE -ne 0) { throw "Falha ao criar ambiente virtual" }
    }

    # Ativar ambiente virtual
    Write-Host "Ativando ambiente virtual..." -ForegroundColor Yellow
    & "venv\Scripts\Activate.ps1"
    if ($LASTEXITCODE -ne 0) { throw "Falha ao ativar ambiente virtual" }

    # Atualizar pip
    Write-Host "Atualizando pip..." -ForegroundColor Yellow
    python -m pip install --upgrade pip
    if ($LASTEXITCODE -ne 0) { throw "Falha ao atualizar pip" }

    # Instalar wheel e setuptools
    Write-Host "Instalando wheel e setuptools..." -ForegroundColor Yellow
    pip install wheel setuptools
    if ($LASTEXITCODE -ne 0) { throw "Falha ao instalar wheel e setuptools" }

    # Instalar dependências Python (base primeiro, sem psycopg2-binary problemático)
    Write-Host "Instalando dependências Python básicas..." -ForegroundColor Yellow
    pip install -r requirements/base.txt
    if ($LASTEXITCODE -ne 0) { throw "Falha ao instalar dependências Python básicas" }
    
    # Instalar dependências de desenvolvimento adicionais (sem as problemáticas)
    Write-Host "Instalando dependências de desenvolvimento..." -ForegroundColor Yellow
    pip install flask-testing freezegun parameterized pytest pytest-mock pre-commit
    # Não falhar se algumas dependências opcionais falharem

    # Instalar Superset
    Write-Host "Instalando Superset em modo desenvolvimento..." -ForegroundColor Yellow
    pip install -e .
    if ($LASTEXITCODE -ne 0) { throw "Falha ao instalar Superset" }

    # Configurar banco de dados
    Write-Host "Configurando banco de dados..." -ForegroundColor Yellow
    superset db upgrade
    if ($LASTEXITCODE -ne 0) { throw "Falha ao configurar banco de dados" }

    # Criar usuário admin
    Write-Host "Criando usuário administrador..." -ForegroundColor Yellow
    Write-Host "Usuário: admin, Senha: admin, Email: admin@superset.com" -ForegroundColor Cyan
    superset fab create-admin --username admin --firstname Admin --lastname User --email admin@superset.com --password admin
    # Não falhar se usuário já existir

    # Inicializar
    Write-Host "Inicializando roles e permissões..." -ForegroundColor Yellow
    superset init
    if ($LASTEXITCODE -ne 0) { throw "Falha ao inicializar roles" }

    # Carregar exemplos
    Write-Host "Carregando dados de exemplo..." -ForegroundColor Yellow
    superset load-examples
    # Não falhar se houver erro nos exemplos

    # Frontend
    Write-Host "Instalando dependências Node.js..." -ForegroundColor Yellow
    Set-Location "superset-frontend"
    npm ci
    if ($LASTEXITCODE -ne 0) { 
        Set-Location ".."
        throw "Falha ao instalar dependências Node.js" 
    }

    # Build frontend
    Write-Host "Fazendo build do frontend..." -ForegroundColor Yellow
    $env:NODE_OPTIONS = "--max_old_space_size=8192"
    npm run build
    if ($LASTEXITCODE -ne 0) { 
        Set-Location ".."
        throw "Falha no build do frontend" 
    }

    Set-Location ".."

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Build concluído com sucesso!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Para executar o Superset:" -ForegroundColor Cyan
    Write-Host "1. Execute: .\run_superset.ps1" -ForegroundColor White
    Write-Host "2. Ou manualmente: venv\Scripts\Activate.ps1 e depois flask run -p 8088" -ForegroundColor White
    Write-Host ""
    Write-Host "Acesse: http://localhost:8088" -ForegroundColor Yellow
    Write-Host "Usuário: admin" -ForegroundColor Yellow
    Write-Host "Senha: admin" -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Verifique os logs acima para mais detalhes." -ForegroundColor Yellow
    exit 1
} finally {
    Read-Host "Pressione Enter para continuar"
}