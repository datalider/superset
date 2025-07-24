# Troubleshooting - Apache Superset no Windows

Este guia contém soluções para problemas comuns ao executar o Apache Superset no Windows.

## 🔧 Verificação Inicial

Antes de começar, execute o script de verificação:
```cmd
check_system.bat
```

## ❌ Problemas Comuns e Soluções

### 1. Python não encontrado

**Erro**: `'python' is not recognized as an internal or external command`

**Soluções**:
```cmd
# Verificar se Python está instalado
where python

# Se não estiver no PATH, adicionar manualmente:
# 1. Abrir "Variáveis de Ambiente"
# 2. Adicionar ao PATH: C:\Python310 (ou sua versão)
# 3. Adicionar ao PATH: C:\Python310\Scripts

# Ou reinstalar Python marcando "Add Python to PATH"
```

### 2. Node.js não encontrado

**Erro**: `'node' is not recognized as an internal or external command`

**Soluções**:
```cmd
# Verificar instalação
where node

# Reinstalar Node.js de: https://nodejs.org/
# Reiniciar terminal após instalação
```

### 3. Erro de Permissões

**Erro**: `Access denied` ou `Permission denied`

**Soluções**:
```cmd
# Executar como Administrador
# Ou verificar permissões da pasta:
icacls . /grant %USERNAME%:F /T

# Verificar antivírus não está bloqueando
```

### 4. Erro de Compilação (Visual Studio Build Tools)

**Erro**: `Microsoft Visual C++ 14.0 is required`

**Soluções**:
```cmd
# Opção 1: Instalar Build Tools
# Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/

# Opção 2: Usar conda para dependências problemáticas
conda install -c conda-forge some-package

# Opção 3: Usar wheels pré-compilados
pip install --only-binary=all package-name
```

### 5. Erro de Memória durante Build

**Erro**: `JavaScript heap out of memory`

**Soluções**:
```cmd
# Aumentar limite de memória do Node.js
set NODE_OPTIONS=--max_old_space_size=8192
npm run build

# Ou fechar outros programas para liberar RAM
```

### 6. Porta 8088 em uso

**Erro**: `Address already in use`

**Soluções**:
```cmd
# Verificar o que está usando a porta
netstat -ano | findstr :8088

# Matar processo se necessário
taskkill /PID <PID_NUMBER> /F

# Ou usar porta diferente
flask run -p 8089
```

### 7. Erro de SSL/TLS

**Erro**: `SSL: CERTIFICATE_VERIFY_FAILED`

**Soluções**:
Adicionar ao `superset_config.py`:
```python
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

# Ou configurar certificados
import certifi
import os
os.environ['SSL_CERT_FILE'] = certifi.where()
```

### 8. Erro de Banco de Dados

**Erro**: `database is locked` ou `no such table`

**Soluções**:
```cmd
# Recriar banco de dados
del superset.db
superset db upgrade
superset init

# Verificar permissões do arquivo
attrib superset.db
```

### 9. Erro de Importação Python

**Erro**: `ModuleNotFoundError: No module named 'superset'`

**Soluções**:
```cmd
# Verificar ambiente virtual ativo
echo %VIRTUAL_ENV%

# Reativar se necessário
venv\Scripts\activate

# Reinstalar em modo desenvolvimento
pip install -e .
```

### 10. Frontend não carrega

**Erro**: Página em branco ou erro 404 para assets

**Soluções**:
```cmd
# Rebuild do frontend
cd superset-frontend
npm run build
cd ..

# Verificar se dist/ foi criado
dir superset-frontend\dist

# Limpar cache do navegador (Ctrl+F5)
```

## 🔍 Diagnóstico Avançado

### Verificar Logs
```cmd
# Logs do Python
type superset.log

# Logs do Flask (se usando)
set FLASK_ENV=development
flask run -p 8088 --debug

# Logs do NPM
npm run build --verbose
```

### Verificar Configuração
```cmd
# Testar configuração Python
python -c "import superset; print('OK')"

# Verificar variáveis de ambiente
echo %FLASK_APP%
echo %SUPERSET_CONFIG_PATH%

# Testar conexão com banco
python -c "from superset import db; print(db.engine.url)"
```

### Verificar Dependências
```cmd
# Listar pacotes Python instalados
pip list

# Verificar conflitos
pip check

# Listar pacotes Node.js
npm list --depth=0
```

## 🛠️ Scripts de Limpeza

### Limpar Instalação Python
```cmd
# Remover ambiente virtual
rmdir /s venv

# Limpar cache pip
pip cache purge

# Recriar ambiente
python -m venv venv
venv\Scripts\activate
```

### Limpar Instalação Node.js
```cmd
cd superset-frontend

# Remover node_modules
rmdir /s node_modules

# Limpar cache npm
npm cache clean --force

# Reinstalar
npm ci
```

### Reset Completo
```cmd
# CUIDADO: Remove tudo!
rmdir /s venv
rmdir /s superset-frontend\node_modules
rmdir /s superset-frontend\dist
del superset.db
del superset.log

# Executar build novamente
build_windows.bat
```

## 🔧 Configurações Específicas do Windows

### Configurar Proxy (se necessário)
```cmd
# Para pip
pip config set global.proxy http://proxy:port

# Para npm
npm config set proxy http://proxy:port
npm config set https-proxy http://proxy:port
```

### Configurar Firewall
```cmd
# Permitir Python no firewall
netsh advfirewall firewall add rule name="Python" dir=in action=allow program="C:\Python310\python.exe"

# Permitir Node.js no firewall
netsh advfirewall firewall add rule name="Node.js" dir=in action=allow program="C:\Program Files\nodejs\node.exe"
```

### Configurar Antivírus
- Adicionar pasta do projeto às exceções
- Adicionar `python.exe` e `node.exe` às exceções
- Desabilitar verificação em tempo real temporariamente

## 📊 Monitoramento de Performance

### Verificar Uso de Recursos
```cmd
# CPU e Memória
tasklist /fi "imagename eq python.exe"
tasklist /fi "imagename eq node.exe"

# Espaço em disco
dir /-c

# Processos do Superset
wmic process where "name='python.exe'" get processid,commandline
```

### Otimizar Performance
```python
# Adicionar ao superset_config.py

# Reduzir workers se pouca RAM
SUPERSET_WEBSERVER_WORKERS = 2

# Timeout menor
SUPERSET_WEBSERVER_TIMEOUT = 60

# Cache mais agressivo
CACHE_CONFIG = {
    'CACHE_TYPE': 'simple',
    'CACHE_DEFAULT_TIMEOUT': 600
}
```

## 🆘 Quando Pedir Ajuda

Antes de abrir uma issue, colete estas informações:

```cmd
# Informações do sistema
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"

# Versões
python --version
node --version
npm --version

# Logs de erro
type superset.log

# Configuração
type superset_config.py

# Pacotes instalados
pip list > packages.txt
npm list --depth=0 > npm_packages.txt
```

## 📞 Recursos de Suporte

- **Documentação Oficial**: https://superset.apache.org/docs/
- **GitHub Issues**: https://github.com/apache/superset/issues
- **Stack Overflow**: Tag `apache-superset`
- **Slack Community**: https://join.slack.com/t/apache-superset/

## ✅ Problemas Resolvidos na Build para Windows

### 1. Erro de psycopg2-binary
**Status**: ✅ **RESOLVIDO**
- Script `build_windows.ps1` atualizado para usar `requirements/base.txt`
- Evita dependências problemáticas no Windows
- SQLite configurado como banco padrão

### 2. Erro de simple-zstd
**Status**: ✅ **RESOLVIDO**
- Arquivo `webpack.proxy-config.js` modificado para import condicional
- Build do frontend funciona corretamente no Windows
- Warning exibido mas não impede funcionamento

### 3. Problemas de memória no build
**Status**: ✅ **RESOLVIDO**
- Script define automaticamente `NODE_OPTIONS=--max_old_space_size=8192`
- Build do frontend concluído com sucesso
- Warnings de tamanho são normais

### 4. Configuração de banco de dados
**Status**: ✅ **RESOLVIDO**
- Usando configuração padrão em `C:\ProgramData\super\superset_config.py`
- SQLite configurado e funcionando
- Dados de exemplo carregados com sucesso
- Usuário admin criado (admin/admin)

### 5. Dependências de desenvolvimento
**Status**: ✅ **RESOLVIDO**
- Script instala apenas dependências essenciais
- Superset funcionando em modo desenvolvimento
- Frontend compilado e servindo corretamente

## 🚀 Como Usar a Build Corrigida

### Primeira Execução
```powershell
# 1. Execute o build (uma vez)
PowerShell -ExecutionPolicy Bypass -File build_windows.ps1

# 2. Execute o Superset
PowerShell -ExecutionPolicy Bypass -File run_superset.ps1
```

### Execuções Subsequentes
```powershell
# Apenas execute o servidor
PowerShell -ExecutionPolicy Bypass -File run_superset.ps1
```

### Acesso
- **URL**: http://localhost:8088
- **Usuário**: admin
- **Senha**: admin

## 💡 Dicas Gerais

1. **Sempre use ambiente virtual** para evitar conflitos
2. **Mantenha versões atualizadas** do Python e Node.js
3. **Faça backup** do banco de dados antes de atualizações
4. **Use SSD** para melhor performance
5. **Monitore logs** regularmente para detectar problemas
6. **Teste em ambiente limpo** se houver problemas persistentes
7. **Use os scripts PowerShell fornecidos** para facilitar o processo