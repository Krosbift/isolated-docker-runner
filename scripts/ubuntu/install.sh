#!/usr/bin/env bash
# ============================================================================
# install.sh - Instalación de Docker Rootless en Ubuntu
# ============================================================================
# Este script instala Docker en modo rootless (sin privilegios de root),
# lo cual permite ejecutar contenedores de forma aislada sin afectar
# el sistema principal ni requerir permisos de administrador continuos.
#
# Requisitos:
#   - Ubuntu 20.04 o superior
#   - Usuario con permisos sudo (solo para instalación inicial)
#   - Conexión a internet
#
# Lo que hace este script:
#   1. Instala Docker desde el repositorio oficial de Docker
#   2. Desactiva Docker del sistema para evitar conflictos
#   3. Configura Docker rootless en un directorio aislado
#   4. Habilita el servicio Docker para el usuario actual
#
# Uso:
#   make install
#   # o directamente:
#   ./scripts/ubuntu/install.sh
# ============================================================================

set -euo pipefail

# Cargar funciones comunes y variables de entorno
# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

print_header "Instalación de Docker Rootless en Ubuntu"

# ============================================================================
# Verificar requisitos previos
# ============================================================================

print_info "Verificando requisitos del sistema..."

# Verificar que estamos en Ubuntu/Debian
if ! command -v apt &>/dev/null; then
  print_error "Este script solo funciona en sistemas basados en Debian/Ubuntu"
  exit 1
fi

# Verificar versión del kernel (mínimo 5.11 para mejor soporte rootless)
KERNEL_VERSION=$(uname -r | cut -d. -f1-2)
print_info "Versión del kernel: $KERNEL_VERSION"

# ============================================================================
# Eliminar versiones antiguas de Docker (si existen)
# ============================================================================

print_info "Eliminando versiones anteriores de Docker (si existen)..."
sudo apt remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc 2>/dev/null || true

# ============================================================================
# Instalación de dependencias y repositorio oficial de Docker
# ============================================================================

print_info "Instalando dependencias..."
sudo apt update
sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  uidmap \
  slirp4netns \
  fuse-overlayfs \
  dbus-user-session

# Añadir clave GPG oficial de Docker
print_info "Configurando repositorio oficial de Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Añadir repositorio de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker desde el repositorio oficial
print_info "Instalando Docker desde repositorio oficial..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

print_success "Paquetes instalados correctamente"

# ============================================================================
# Desactivar Docker del sistema
# ============================================================================
# Esto es importante para evitar conflictos entre Docker rootless y Docker root.
# Docker rootless funcionará de forma completamente independiente.
# ============================================================================

print_info "Desactivando Docker del sistema (evita conflictos)..."
sudo systemctl disable --now docker.service 2>/dev/null || true
sudo systemctl disable --now docker.socket 2>/dev/null || true
sudo systemctl disable --now containerd 2>/dev/null || true
print_success "Docker del sistema desactivado"

# ============================================================================
# Crear estructura de directorios aislada
# ============================================================================

print_info "Creando directorio aislado en: $ISO_DOCKER_HOME"
mkdir -p "$ISO_DOCKER_HOME"/{data,run,state}

# ============================================================================
# Configurar variables de entorno para Docker rootless
# ============================================================================

# Usamos la ruta estándar de Docker rootless
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

print_info "Configuración de Docker rootless:"
echo "  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
echo "  DOCKER_HOST=$DOCKER_HOST"

# ============================================================================
# Instalar Docker rootless
# ============================================================================

print_info "Instalando Docker rootless..."

# Verificar que el script de instalación existe
ROOTLESS_SETUP="/usr/bin/dockerd-rootless-setuptool.sh"
if [[ ! -x "$ROOTLESS_SETUP" ]]; then
  print_error "No se encontró dockerd-rootless-setuptool.sh"
  print_info "Intentando instalación alternativa..."
  
  # Descargar e instalar rootless directamente
  curl -fsSL https://get.docker.com/rootless | sh
else
  "$ROOTLESS_SETUP" install
fi

print_info "Habilitando servicio Docker para el usuario..."
systemctl --user enable --now docker

# ============================================================================
# Verificar instalación
# ============================================================================

print_info "Verificando instalación..."

# Esperar a que Docker esté listo
sleep 3

if docker version &>/dev/null; then
  print_success "Docker instalado correctamente"
  docker version
else
  print_error "Error al verificar Docker"
  print_info "Puede que necesites reiniciar la sesión. Intenta:"
  echo "  1. Cierra sesión y vuelve a iniciar"
  echo "  2. Ejecuta: make up"
  exit 1
fi

if docker compose version &>/dev/null; then
  print_success "Docker Compose instalado correctamente"
  docker compose version
else
  print_warning "Docker Compose no disponible como plugin"
fi

# ============================================================================
# Instrucciones finales
# ============================================================================

print_header "¡Instalación completada!"
echo ""
echo "Para usar Docker, necesitas cargar las variables de entorno en tu shell:"
echo ""
echo "  source scripts/ubuntu/env.sh"
echo ""
echo "O añade esto a tu ~/.bashrc o ~/.zshrc para cargarlo automáticamente:"
echo ""
echo "  # Isolated Docker Runner"
echo "  export DOCKER_HOST=\"unix://$XDG_RUNTIME_DIR/docker.sock\""
echo ""
echo "Comandos disponibles:"
echo "  make up     - Iniciar Docker"
echo "  make down   - Detener Docker"
echo "  make status - Ver estado"
echo ""
