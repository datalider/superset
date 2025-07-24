# Guia de Build do Apache Superset para Windows

Este guia fornece instruções detalhadas para fazer a build e executar o Apache Superset no Windows usando Python e Node.js diretamente, sem Docker.

## Pré-requisitos

### 1. Python
- **Versão requerida**: Python 3.10 ou 3.11
- Baixe em: https://www.python.org/downloads/
- **Importante**: Durante a instalação, marque "Add Python to PATH"

### 2. Node.js
- **Versão requerida**: Node.js 20.16.0 ou superior
- **NPM**: 10.8.1 ou superior
- Baixe em: https://nodejs.org/

### 3. Git
- Para clonar o repositório
- Baixe em: https://git-scm.com/download/win

### 4. Visual Studio Build Tools (Opcional mas recomendado)
- Necessário para compilar algumas dependências nativas
- Baixe: Visual Studio Build Tools 2019 ou superior
- Ou instale via: `npm install --global windows-build-tools`

## Instalação Passo a Passo

### 1. Verificar Versões
Abra o PowerShell ou Command Prompt e verifique:

```cmd
python --version
node --version
npm --version
git --version
```

### 2. Criar Ambiente Virtual Python
```cmd
# Navegar para o diretório do projeto
cd d:\superset\superset

# Criar ambiente virtual
python -m venv venv

# Ativar ambiente virtual (Windows)
venv\Scripts\activate

# Verificar se o ambiente está ativo (deve mostrar (venv) no prompt)
```

### 3. Atualizar pip e instalar dependências Python
```cmd
# Atualizar pip
python -m pip install --upgrade pip

# Instalar wheel e setuptools
pip install wheel setuptools

# Instalar dependências de desenvolvimento
pip install -r requirements/development.txt

# Instalar Superset em modo desenvolvimento
pip install -e .
```

### 4. Configurar Banco de Dados
```cmd
# Inicializar banco de dados
superset db upgrade

# Criar usuário admin
superset fab create-admin --username admin --firstname Admin --lastname User --email admin@superset.com --password admin

# Inicializar roles e permissões
superset init

# Carregar dados de exemplo (opcional)
superset load-examples
```

### 5. Instalar Dependências do Frontend
```cmd
# Navegar para o diretório frontend
cd superset-frontend

# Instalar dependências Node.js
npm ci

# Voltar para o diretório raiz
cd ..
```

### 6. Build do Frontend
```cmd
cd superset-frontend

# Build de produção
npm run build

# Ou para desenvolvimento (com watch)
npm run dev

cd ..
```

## Executando o Superset

### Método 1: Usando Flask (Desenvolvimento)
```cmd
# Ativar ambiente virtual se não estiver ativo
venv\Scripts\activate

# Definir variáveis de ambiente
set FLASK_APP=superset
set FLASK_ENV=development
set SUPERSET_CONFIG_PATH=superset_config.py

# Executar servidor Flask
flask run -p 8088 --with-threads --reload --debugger
```

### Método 2: Usando Waitress (Produção - Windows)
```cmd
# Ativar ambiente virtual
venv\Scripts\activate

# Executar com Waitress (servidor WSGI para Windows)
waitress-serve --port=8088 --threads=4 superset.app:create_app
```

### Método 3: Executar Frontend e Backend Separadamente (Desenvolvimento)
Terminal 1 (Backend):
```cmd
venv\Scripts\activate
set FLASK_APP=superset
set FLASK_ENV=development
flask run -p 8088 --with-threads --reload --debugger
```

Terminal 2 (Frontend):
```cmd
cd superset-frontend
npm run dev-server
```

## Configuração Adicional

### Arquivo de Configuração (superset_config.py)
Crie um arquivo `superset_config.py` na raiz do projeto:

```python
# superset_config.py
import os

# Configurações básicas
SECRET_KEY = 'your-secret-key-here'
SQLALCHEMY_DATABASE_URI = 'sqlite:///superset.db'

# Configurações para Windows
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None

# Cache
CACHE_CONFIG = {
    'CACHE_TYPE': 'simple',
}

# Configurações de segurança
TALISMAN_ENABLED = False
```

### Variáveis de Ambiente
Crie um arquivo `.env` na raiz do projeto:

```env
FLASK_APP=superset
FLASK_ENV=development
SUPERSET_CONFIG_PATH=superset_config.py
PYTHONPATH=.
```

## Scripts de Automação

### Script de Build Completo (build_windows.bat)
```batch
@echo off
echo Iniciando build do Superset para Windows...

echo Ativando ambiente virtual...
call venv\Scripts\activate

echo Atualizando pip...
python -m pip install --upgrade pip

echo Instalando dependências Python...
pip install -r requirements/development.txt
pip install -e .

echo Configurando banco de dados...
superset db upgrade
superset init

echo Instalando dependências Node.js...
cd superset-frontend
npm ci

echo Fazendo build do frontend...
npm run build

cd ..

echo Build concluído! Execute 'run_superset.bat' para iniciar o servidor.
pause
```

### Script de Execução (run_superset.bat)
```batch
@echo off
echo Iniciando Apache Superset...

call venv\Scripts\activate

set FLASK_APP=superset
set FLASK_ENV=development
set SUPERSET_CONFIG_PATH=superset_config.py

echo Superset será executado em: http://localhost:8088
echo Usuário: admin
echo Senha: admin

waitress-serve --port=8088 --threads=4 superset.app:create_app
```

## Solução de Problemas Comuns

### 1. Erro de Compilação de Dependências
```cmd
# Instalar Visual Studio Build Tools
npm install --global windows-build-tools

# Ou usar conda para dependências problemáticas
conda install -c conda-forge some-package
```

### 2. Erro de Memória durante Build
```cmd
# Aumentar limite de memória do Node.js
set NODE_OPTIONS=--max_old_space_size=8192
npm run build
```

### 3. Problemas com Paths no Windows
- Use barras invertidas (`\`) ou barras duplas (`\\`) em paths
- Ou use paths relativos quando possível

### 4. Erro de Permissões
- Execute o Command Prompt como Administrador
- Ou use PowerShell com privilégios elevados

### 5. Problemas com SSL/TLS
```python
# Adicionar ao superset_config.py
import ssl
ssl._create_default_https_context = ssl._create_unverified_context
```

## Estrutura de Diretórios Após Build

```
d:\superset\superset\
├── venv\                    # Ambiente virtual Python
├── superset\               # Código fonte Python
├── superset-frontend\      # Código fonte Frontend
│   ├── dist\              # Build do frontend
│   └── node_modules\      # Dependências Node.js
├── superset_config.py     # Configuração personalizada
├── superset.db           # Banco de dados SQLite
└── build_windows.bat     # Script de build
```

## Comandos Úteis

```cmd
# Verificar status do ambiente
pip list
npm list --depth=0

# Limpar cache
pip cache purge
npm cache clean --force

# Reinstalar dependências
pip install -r requirements/development.txt --force-reinstall
npm ci --clean-install

# Verificar logs
superset --help
flask --help
```

## Próximos Passos

1. Acesse http://localhost:8088
2. Faça login com admin/admin
3. Explore os dashboards de exemplo
4. Configure suas fontes de dados
5. Crie seus próprios dashboards

## Notas Importantes

- O Superset usa SQLite por padrão, mas para produção recomenda-se PostgreSQL ou MySQL
- Para produção, configure um servidor web como IIS ou Apache
- Mantenha o ambiente virtual sempre ativo ao trabalhar com Superset
- Faça backup regular do banco de dados e configurações

## Suporte

Para problemas específicos do Windows:
- Verifique os logs em `superset.log`
- Consulte a documentação oficial: https://superset.apache.org/docs/
- Issues no GitHub: https://github.com/apache/superset/issues