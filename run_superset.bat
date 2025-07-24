@echo off
echo ========================================
echo    Apache Superset - Servidor Windows
echo ========================================
echo.

REM Verificar se o ambiente virtual existe
if not exist "venv\Scripts\activate.bat" (
    echo ERRO: Ambiente virtual não encontrado.
    echo Execute primeiro: build_windows.bat
    pause
    exit /b 1
)

echo Ativando ambiente virtual...
call venv\Scripts\activate

REM Configurar variáveis de ambiente
set FLASK_APP=superset
set FLASK_ENV=development
set SUPERSET_CONFIG_PATH=superset_config.py
set PYTHONPATH=.

echo Verificando instalação do Superset...
superset --help >nul 2>&1
if errorlevel 1 (
    echo ERRO: Superset não está instalado corretamente.
    echo Execute: build_windows.bat
    pause
    exit /b 1
)

echo.
echo ========================================
echo    Iniciando Apache Superset
echo ========================================
echo.
echo URL: http://localhost:8088
echo Usuário: admin
echo Senha: admin
echo.
echo Pressione Ctrl+C para parar o servidor
echo.

REM Tentar usar waitress primeiro (melhor para Windows)
waitress-serve --port=8088 --threads=4 superset.app:create_app 2>nul
if errorlevel 1 (
    echo Waitress não disponível, usando Flask...
    flask run -p 8088 --with-threads --reload --debugger
)

pause