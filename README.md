# 🐳 Isolated Docker Runner

> Instala y ejecuta Docker de forma **aislada** en Ubuntu o macOS, sin afectar tu sistema ni requerir Docker Desktop.

## 📋 ¿Qué es esto?

**Isolated Docker Runner** es un conjunto de scripts que te permiten tener Docker instalado de forma completamente aislada del resto de tu sistema. Esto es especialmente útil cuando:

- 🏢 **Proyectos de trabajo**: Necesitas ejecutar `docker-compose.yml` y `Dockerfile` de proyectos de tu empresa sin instalar todo globalmente.
- 🧪 **Pruebas con bases de datos**: Quieres levantar PostgreSQL, MySQL, Redis, etc. sin instalarlos directamente en tu máquina.
- 📦 **Ambientes controlados**: Prefieres tener control total sobre dónde se guardan los datos de Docker.
- 💰 **Evitar Docker Desktop** (macOS): Docker Desktop requiere licencia comercial. Colima es gratuito y open source.

## ✨ Características

| Característica | Ubuntu | macOS |
|---------------|--------|-------|
| Sin Docker Desktop | ✅ | ✅ |
| Instalación aislada | ✅ | ✅ |
| Sin permisos root continuos | ✅ | ✅ |
| Docker Compose incluido | ✅ | ✅ |
| Fácil de eliminar | ✅ | ✅ |

## � Requisitos Previos

### Ubuntu / Linux

```bash
# Instalar make (necesario para ejecutar los comandos)
sudo apt update
sudo apt install -y make
```

### macOS

```bash
# Instalar Homebrew (si no lo tienes)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# make ya viene incluido con Xcode Command Line Tools
xcode-select --install
```

## 🚀 Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/isolated-docker-runner.git
cd isolated-docker-runner
```

### 2. Dar permisos de ejecución a los scripts

```bash
chmod +x scripts/**/*.sh
```

### 3. Instalar requisitos (si no los tienes)

```bash
# Solo Ubuntu - instalar make
sudo apt install -y make
```

### 4. Instalar Docker aislado

```bash
make install
```

### 5. Iniciar Docker

```bash
make up
```

### 6. ¡Listo! Usa Docker normalmente

```bash
# Cargar variables de entorno (necesario en cada terminal nueva)
source scripts/ubuntu/env.sh   # Ubuntu
source scripts/macos/env.sh    # macOS

# Ahora puedes usar docker normalmente
docker ps
docker run hello-world
docker compose up
```

## 📖 Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `make install` | Instala Docker aislado (solo la primera vez) |
| `make up` | Inicia el servicio Docker |
| `make down` | Detiene el servicio Docker (conserva datos) |
| `make status` | Muestra el estado actual de Docker |
| `make env` | Muestra las variables de entorno necesarias |
| `make purge` | ⚠️ Elimina Docker aislado y TODOS sus datos |
| `make help` | Muestra la ayuda |

## 🖥️ Guía por Sistema Operativo

### Ubuntu / Linux

En Ubuntu se utiliza **Docker Rootless**, que permite ejecutar Docker sin privilegios de root después de la instalación inicial.

#### Requisitos
- Ubuntu 20.04 o superior
- Usuario con permisos sudo (solo para instalación)
- Paquetes: se instalan automáticamente

#### ¿Cómo funciona?
1. Instala Docker desde el repositorio oficial de Docker
2. Desactiva Docker del sistema para evitar conflictos
3. Configura Docker Rootless para tu usuario
4. Habilita el servicio Docker del usuario

#### Dónde se guardan los datos
```
~/.local/share/docker/     # Imágenes, contenedores, volúmenes
/run/user/<UID>/docker.sock  # Socket de Docker (runtime)
~/.config/systemd/user/docker.service  # Servicio de usuario
```

#### Usar Docker en cada terminal

Cada vez que abras una terminal nueva, necesitas cargar las variables:

```bash
source scripts/ubuntu/env.sh
```

O añade esto a tu `~/.bashrc` o `~/.zshrc`:

```bash
# Isolated Docker Runner
export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
```

---

### macOS

En macOS se utiliza **Colima**, un runtime de contenedores ligero que reemplaza a Docker Desktop.

#### Requisitos
- macOS 10.15 (Catalina) o superior
- Homebrew instalado ([brew.sh](https://brew.sh))

#### ¿Por qué Colima en lugar de Docker Desktop?
| Aspecto | Docker Desktop | Colima |
|---------|---------------|--------|
| Licencia | Requiere pago para empresas | Gratuito y open source |
| Recursos | Mayor consumo | Menor consumo |
| Actualizaciones | Forzadas | A tu ritmo |
| Perfiles | No | Sí, múltiples aislados |

#### Recursos asignados por defecto
- **CPU**: 2 núcleos
- **Memoria**: 4 GB
- **Disco**: 30 GB

Puedes personalizar estos valores en `config/.env`.

#### Usar Docker en cada terminal

```bash
source scripts/macos/env.sh
```

O usa el comando eval directamente:

```bash
eval "$(colima docker-env --profile isodocker)"
```

## ⚙️ Configuración Personalizada

### Crear archivo de configuración

```bash
cp config/.env.example config/.env
```

### Opciones disponibles

```bash
# config/.env

# Directorio de datos (solo Ubuntu)
ISO_DOCKER_HOME="$HOME/.isodocker"

# Nombre del perfil (solo macOS)
COLIMA_PROFILE="isodocker"

# Recursos de Colima (solo macOS)
COLIMA_CPU=2
COLIMA_MEMORY=4
COLIMA_DISK=30
```

## 💡 Casos de Uso

### Ejecutar un proyecto con docker-compose

```bash
# 1. Iniciar Docker
make up

# 2. Cargar variables
source scripts/ubuntu/env.sh  # o macos

# 3. Ir al proyecto
cd /ruta/a/mi/proyecto

# 4. Levantar los servicios
docker compose up -d

# 5. Ver logs
docker compose logs -f

# 6. Al terminar
docker compose down
make down  # Opcional: detener Docker completamente
```

### Levantar una base de datos para pruebas

```bash
# Iniciar Docker
make up
source scripts/ubuntu/env.sh

# PostgreSQL
docker run -d \
  --name postgres-test \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:15

# MySQL
docker run -d \
  --name mysql-test \
  -e MYSQL_ROOT_PASSWORD=secret \
  -p 3306:3306 \
  mysql:8

# Redis
docker run -d \
  --name redis-test \
  -p 6379:6379 \
  redis:alpine

# MongoDB
docker run -d \
  --name mongo-test \
  -p 27017:27017 \
  mongo:6
```

### Ejecutar Node.js sin instalarlo

```bash
# Ejecutar un script
docker run --rm -v "$PWD:/app" -w /app node:20 node script.js

# Instalar dependencias
docker run --rm -v "$PWD:/app" -w /app node:20 npm install

# Shell interactivo
docker run --rm -it -v "$PWD:/app" -w /app node:20 bash
```

## 🔧 Solución de Problemas

### "Permission denied" al ejecutar make install

Los scripts necesitan permisos de ejecución:
```bash
chmod +x scripts/**/*.sh
```

### "Command 'make' not found"

Instala make primero:
```bash
sudo apt install -y make
```

### "Cannot connect to the Docker daemon"

Asegúrate de haber cargado las variables de entorno:
```bash
source scripts/ubuntu/env.sh  # o macos/env.sh
```

### Docker no inicia en Ubuntu

Verifica el estado del servicio:
```bash
systemctl --user status docker
```

Si hay errores, revisa los logs:
```bash
journalctl --user -u docker
```

### Colima no inicia en macOS

Verifica el estado:
```bash
colima status --profile isodocker
```

Intenta reiniciar:
```bash
make down
make up
```

### Sin espacio en disco

Los datos de Docker pueden ocupar mucho espacio. Para limpiar:
```bash
# Limpiar recursos no utilizados
docker system prune -a

# Ver uso de disco
docker system df
```

### Permisos denegados (Ubuntu)

Si obtienes errores de permisos, asegúrate de que tu usuario tenga los subuid/subgid configurados:
```bash
cat /etc/subuid | grep $USER
cat /etc/subgid | grep $USER
```

Si están vacíos, agrégalos:
```bash
sudo usermod --add-subuids 100000-165535 $USER
sudo usermod --add-subgids 100000-165535 $USER
```

## 🗑️ Desinstalación

### Eliminar Docker aislado (conserva los binarios)

```bash
make purge
```

### Desinstalación completa en macOS

```bash
make purge
brew uninstall colima docker docker-compose
```

### Desinstalación completa en Ubuntu

```bash
make purge
sudo apt remove docker.io docker-compose-v2
```

## 📁 Estructura del Proyecto

```
isolated-docker-runner/
├── Makefile              # Comandos principales (make install, up, down, etc.)
├── README.md             # Esta documentación
├── config/
│   └── .env.example      # Configuración de ejemplo
└── scripts/
    ├── common.sh         # Funciones compartidas
    ├── macos/
    │   ├── install.sh    # Instalación para macOS
    │   ├── up.sh         # Iniciar Docker (Colima)
    │   ├── down.sh       # Detener Docker
    │   ├── env.sh        # Variables de entorno
    │   └── purge.sh      # Eliminar completamente
    └── ubuntu/
        ├── install.sh    # Instalación para Ubuntu
        ├── up.sh         # Iniciar Docker Rootless
        ├── down.sh       # Detener Docker
        ├── env.sh        # Variables de entorno
        └── purge.sh      # Eliminar completamente
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si encuentras un bug o tienes una mejora:

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/mejora`)
3. Haz commit de tus cambios (`git commit -am 'Agrega mejora'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

## 📄 Licencia

MIT License - siéntete libre de usar, modificar y distribuir.

---

**Hecho con ❤️ para desarrolladores que quieren Docker sin complicaciones.**