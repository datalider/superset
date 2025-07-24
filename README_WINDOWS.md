# Apache Superset - Build para Windows

Este guia fornece instruções específicas para compilar e executar o Apache Superset no Windows usando Python e Node.js nativos (sem Docker).

## 🎯 Resumo Rápido

```powershell
# 1. Execute o build (primeira vez)
PowerShell -ExecutionPolicy Bypass -File build_windows.ps1

# 2. Execute o Superset
PowerShell -ExecutionPolicy Bypass -File run_superset.ps1

# 3. Acesse: http://localhost:8088
# Usuário: admin | Senha: admin
```

## 📋 Pré-requisitos

### Software Necessário
- **Python 3.10 ou 3.11** (recomendado: 3.11)
- **Node.js 20.16.0+** (recomendado: LTS mais recente)
- **Git** (para clonar o repositório)
- **PowerShell** (incluído no Windows)

### Verificação do Sistema
Execute o script de verificação:
```cmd
check_system.bat
```

## 🚀 Instalação Rápida

### 1. Clone o Repositório
```bash
git clone https://github.com/apache/superset.git
cd superset
```

### 2. Execute o Build
```powershell
PowerShell -ExecutionPolicy Bypass -File build_windows.ps1
```

O script irá:
- ✅ Verificar Python e Node.js
- ✅ Criar ambiente virtual Python
- ��� Instalar dependências Python essenciais
- ✅ Instalar Superset em modo desenvolvimento
- ✅ Configurar banco de dados SQLite
- ✅ Criar usuário administrador
- ✅ Carregar dados de exemplo
- ✅ Compilar frontend React/TypeScript

### 3. Execute o Superset
```powershell
PowerShell -ExecutionPolicy Bypass -File run_superset.ps1
```

### 4. Acesse a Interface
- **URL**: http://localhost:8088
- **Usuário**: `admin`
- **Senha**: `admin`

## 🔧 Problemas Resolvidos

Esta build resolve os seguintes problemas comuns no Windows:

### ✅ Erro de psycopg2-binary
- **Problema**: Falha na compilação do driver PostgreSQL
- **Solução**: Usa SQLite como banco padrão e evita dependências problemáticas

### ✅ Erro de simple-zstd
- **Problema**: Módulo de compressão não disponível no Windows
- **Solução**: Import condicional no webpack, funciona sem o módulo

### ✅ Problemas de memória no build
- **Problema**: "JavaScript heap out of memory" durante npm build
- **Solução**: Aumenta automaticamente limite de memória do Node.js

### ✅ Dependências conflitantes
- **Problema**: Algumas dependências de desenvolvimento falhavam
- **Solução**: Instala apenas dependências essenciais para funcionamento

## 📁 Estrutura de Arquivos

```
superset/
├── build_windows.ps1          # Script de build principal
├── run_superset.ps1           # Script para executar o servidor
├── check_system.bat           # Verificação de pré-requisitos
├── TROUBLESHOOTING_WINDOWS.md # Guia de solução de problemas
├── README_WINDOWS.md          # Este arquivo
├── venv/                      # Ambiente virtual Python
├── superset-frontend/         # Código fonte do frontend
│   ├── dist/                  # Frontend compilado
│   └── webpack.proxy-config.js # Configuração corrigida
└── superset/                  # Código fonte do backend
```

## ⚙️ Configuração

### Banco de Dados
- **Tipo**: SQLite (padrão)
- **Localização**: `C:\Users\{user}\.superset\examples.db`
- **Configuração**: `C:\ProgramData\super\superset_config.py`

### Usuário Padrão
- **Usuário**: `admin`
- **Senha**: `admin`
- **Email**: `admin@superset.com`
- **Permissões**: Administrador completo

### Dados de Exemplo
O build carrega automaticamente:
- 📊 World Bank Health Nutrition and Population Stats
- 👶 Birth names dataset
- 🗺️ Geographic data (countries, flights, etc.)
- 📈 Dashboards de exemplo

## 🔄 Comandos Úteis

### Desenvolvimento
```powershell
# Ativar ambiente virtual
venv\Scripts\Activate.ps1

# Executar em modo debug
superset run -p 8088 --with-threads --reload --debugger

# Rebuild apenas do frontend
cd superset-frontend
npm run build
cd ..

# Atualizar banco de dados
superset db upgrade

# Recriar usuário admin
superset fab create-admin --username admin --firstname Admin --lastname User --email admin@superset.com --password admin
```

### Manutenção
```powershell
# Limpar cache Python
pip cache purge

# Limpar cache Node.js
cd superset-frontend
npm cache clean --force
cd ..

# Reset completo (cuidado!)
Remove-Item -Recurse -Force venv, superset-frontend\node_modules, superset-frontend\dist
```

## 🐛 Solução de Problemas

### Logs
```powershell
# Ver logs do servidor
Get-Content superset.log -Tail 50

# Executar com mais verbosidade
$env:FLASK_ENV="development"
superset run -p 8088 --debug
```

### Problemas Comuns
1. **Porta 8088 em uso**: Use `netstat -ano | findstr :8088` para identificar
2. **Erro de permissão**: Execute PowerShell como Administrador
3. **Frontend não carrega**: Limpe cache do navegador (Ctrl+F5)
4. **Erro de memória**: Feche outros programas para liberar RAM

Para problemas detalhados, consulte: `TROUBLESHOOTING_WINDOWS.md`

## 📊 Performance

### Requisitos Mínimos
- **RAM**: 4GB (recomendado: 8GB+)
- **CPU**: 2 cores (recomendado: 4+ cores)
- **Disco**: 2GB livres (recomendado: SSD)

### Otimizações
```python
# Adicionar ao superset_config.py para melhor performance

# Reduzir workers se pouca RAM
SUPERSET_WEBSERVER_WORKERS = 2

# Cache mais agressivo
CACHE_CONFIG = {
    'CACHE_TYPE': 'simple',
    'CACHE_DEFAULT_TIMEOUT': 600
}

# Timeout otimizado
SUPERSET_WEBSERVER_TIMEOUT = 60
```

## 🔒 Segurança

### Para Produção
⚠️ **Esta build é para desenvolvimento/teste. Para produção:**

1. Altere a `SECRET_KEY` no `superset_config.py`
2. Use banco de dados dedicado (PostgreSQL/MySQL)
3. Configure HTTPS
4. Altere senha do usuário admin
5. Configure autenticação adequada
6. Use servidor web dedicado (nginx + gunicorn)

### Configuração Básica de Segurança
```python
# superset_config.py para produção
SECRET_KEY = 'sua-chave-secreta-muito-forte-aqui'
WTF_CSRF_ENABLED = True
TALISMAN_ENABLED = True
```

## 📚 Recursos Adicionais

- **Documentação Oficial**: https://superset.apache.org/docs/
- **GitHub**: https://github.com/apache/superset
- **Community Slack**: https://join.slack.com/t/apache-superset/
- **Stack Overflow**: Tag `apache-superset`

## 🤝 Contribuindo

Para contribuir com melhorias na build para Windows:

1. Fork o repositório
2. Crie uma branch para sua feature
3. Teste no Windows
4. Submeta um Pull Request

## 📝 Changelog

### v1.0 (2025-01-24)
- ✅ Build inicial funcionando no Windows
- ✅ Correção do erro psycopg2-binary
- ✅ Correção do erro simple-zstd
- ✅ Otimização de memória para build do frontend
- ✅ Scripts PowerShell automatizados
- ✅ Documentação completa

## 📄 Licença

Apache License 2.0 - veja o arquivo LICENSE para detalhes.

---

**Desenvolvido e testado no Windows 10/11 com Python 3.11 e Node.js 20.x**