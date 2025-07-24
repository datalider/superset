@echo off
echo ========================================
echo    Apache Superset - Build para Windows
echo ========================================
echo.

REM Verificar se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ERRO: Python não encontrado. Instale Python 3.10 ou 3.11 primeiro.
    echo Download: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Verificar se Node.js está instalado
node --version >nul 2>&1
if errorlevel 1 (
    echo ERRO: Node.js não encontrado. Instale Node.js 20.16.0 ou superior.
    echo Download: https://nodejs.org/
    pause
    exit /b 1
)

echo Verificando versões...
echo Python: 
python --version
echo Node.js: 
node --version
echo NPM: 
npm --version
echo.

REM Criar ambiente virtual se não existir
if not exist "venv" (
    echo Criando ambiente virtual Python...
    python -m venv venv
    if errorlevel 1 (
        echo ERRO: Falha ao criar ambiente virtual.
        pause
        exit /b 1
    )
)

echo Ativando ambiente virtual...
call venv\Scripts\activate
if errorlevel 1 (
    echo ERRO: Falha ao ativar ambiente virtual.
    pause
    exit /b 1
)

echo Atualizando pip...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo ERRO: Falha ao atualizar pip.
    pause
    exit /b 1
)

echo Instalando wheel e setuptools...
pip install wheel setuptools
if errorlevel 1 (
    echo ERRO: Falha ao instalar wheel e setuptools.
    pause
    exit /b 1
)

echo Instalando dependências Python...
pip install -r requirements/development.txt
if errorlevel 1 (
    echo ERRO: Falha ao instalar dependências Python.
    pause
    exit /b 1
)

echo Instalando Superset em modo desenvolvimento...
pip install -e .
if errorlevel 1 (
    echo ERRO: Falha ao instalar Superset.
    pause
    exit /b 1
)

echo Configurando banco de dados...
superset db upgrade
if errorlevel 1 (
    echo ERRO: Falha ao configurar banco de dados.
    pause
    exit /b 1
)

echo Criando usuário administrador...
echo Usuário: admin
echo Senha: admin
echo Email: admin@superset.com
superset fab create-admin --username admin --firstname Admin --lastname User --email admin@superset.com --password admin
if errorlevel 1 (
    echo AVISO: Usuário admin pode já existir.
)

echo Inicializando roles e permissões...
superset init
if errorlevel 1 (
    echo ERRO: Falha ao inicializar roles.
    pause
    exit /b 1
)

echo Carregando dados de exemplo...
superset load-examples
if errorlevel 1 (
    echo AVISO: Falha ao carregar exemplos (opcional).
)

echo Instalando dependências Node.js...
cd superset-frontend
npm ci
if errorlevel 1 (
    echo ERRO: Falha ao instalar dependências Node.js.
    cd ..
    pause
    exit /b 1
)

echo Fazendo build do frontend...
set NODE_OPTIONS=--max_old_space_size=8192
npm run build
if errorlevel 1 (
    echo ERRO: Falha no build do frontend.
    cd ..
    pause
    exit /b 1
)

cd ..

echo.
echo ========================================
echo    Build concluído com sucesso!
echo ========================================
echo.
echo Para executar o Superset:
echo 1. Execute: run_superset.bat
echo 2. Ou manualmente: venv\Scripts\activate e depois flask run -p 8088
echo.
echo Acesse: http://localhost:8088
echo Usuário: admin
echo Senha: admin
echo.
pause