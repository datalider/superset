@echo off
echo ========================================
echo    Verificação do Sistema - Superset
echo ========================================
echo.

echo Verificando sistema operacional...
ver
echo.

echo Verificando Python...
python --version 2>nul
if errorlevel 1 (
    echo [ERRO] Python não encontrado
    echo Instale Python 3.10 ou 3.11 de: https://www.python.org/downloads/
) else (
    echo [OK] Python encontrado
    python -c "import sys; print(f'Versão: {sys.version}'); print(f'Executável: {sys.executable}')"
)
echo.

echo Verificando pip...
pip --version 2>nul
if errorlevel 1 (
    echo [ERRO] pip não encontrado
) else (
    echo [OK] pip encontrado
)
echo.

echo Verificando Node.js...
node --version 2>nul
if errorlevel 1 (
    echo [ERRO] Node.js não encontrado
    echo Instale Node.js 20.16.0+ de: https://nodejs.org/
) else (
    echo [OK] Node.js encontrado
    node --version
)
echo.

echo Verificando NPM...
npm --version 2>nul
if errorlevel 1 (
    echo [ERRO] NPM não encontrado
) else (
    echo [OK] NPM encontrado
    npm --version
)
echo.

echo Verificando Git...
git --version 2>nul
if errorlevel 1 (
    echo [AVISO] Git não encontrado (opcional)
) else (
    echo [OK] Git encontrado
    git --version
)
echo.

echo Verificando ambiente virtual...
if exist "venv\Scripts\python.exe" (
    echo [OK] Ambiente virtual encontrado
    echo Versão Python no venv:
    venv\Scripts\python.exe --version
) else (
    echo [INFO] Ambiente virtual não encontrado (será criado durante build)
)
echo.

echo Verificando arquivos do projeto...
if exist "superset" (
    echo [OK] Diretório superset encontrado
) else (
    echo [ERRO] Diretório superset não encontrado
)

if exist "superset-frontend" (
    echo [OK] Diretório superset-frontend encontrado
) else (
    echo [ERRO] Diretório superset-frontend não encontrado
)

if exist "requirements" (
    echo [OK] Diretório requirements encontrado
) else (
    echo [ERRO] Diretório requirements não encontrado
)
echo.

echo Verificando espaço em disco...
for /f "tokens=3" %%a in ('dir /-c ^| find "bytes free"') do set free=%%a
echo Espaço livre: %free% bytes
echo.

echo Verificando memória...
wmic computersystem get TotalPhysicalMemory /value | find "TotalPhysicalMemory" 2>nul
if errorlevel 1 (
    echo [AVISO] Não foi possível verificar memória
) else (
    echo [INFO] Memória verificada acima
)
echo.

echo Verificando variáveis de ambiente importantes...
echo PATH contém Python: 
echo %PATH% | find "Python" >nul && echo [OK] Sim || echo [AVISO] Não
echo PATH contém Node: 
echo %PATH% | find "node" >nul && echo [OK] Sim || echo [AVISO] Não
echo.

echo Verificando portas...
netstat -an | find ":8088" >nul
if errorlevel 1 (
    echo [OK] Porta 8088 disponível
) else (
    echo [AVISO] Porta 8088 pode estar em uso
)
echo.

echo ========================================
echo    Verificação Concluída
echo ========================================
echo.
echo Se todos os itens estão [OK], você pode executar:
echo   build_windows.bat
echo.
echo Se há [ERRO], corrija os problemas antes de continuar.
echo.
pause