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
#   1. Instala paquetes necesarios (docker.io, uidmap, slirp4netns, etc.)
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
# Instalación de paquetes necesarios
# ============================================================================

print_info "Instalando paquetes necesarios..."
sudo apt update
sudo apt install -y \
  docker.io \
  docker-compose-v2 \
  uidmap \
  slirp4netns \
  fuse-overlayfs \
  dbus-user-session

print_success "Paquetes instalados correctamente"

# ============================================================================
# Desactivar Docker del sistema
# ============================================================================
# Esto es importante para evitar conflictos entre Docker rootless y Docker root.
# Docker rootless funcionará de forma completamente independiente.
# ============================================================================

print_info "Desactivando Docker del sistema (evita conflictos)..."
sudo systemctl disable --now docker 2>/dev/null || true
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

export DOCKERD_ROOTLESS_ROOTLESSKIT_STATE_DIR="$ISO_DOCKER_HOME/state"
export XDG_DATA_HOME="$ISO_DOCKER_HOME/data"
export XDG_RUNTIME_DIR="$ISO_DOCKER_HOME/run"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

print_info "Configuración de Docker rootless:"
echo "  DOCKERD_ROOTLESS_ROOTLESSKIT_STATE_DIR=$DOCKERD_ROOTLESS_ROOTLESSKIT_STATE_DIR"
echo "  XDG_DATA_HOME=$XDG_DATA_HOME"
echo "  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
echo "  DOCKER_HOST=$DOCKER_HOST"

# ============================================================================
# Instalar y habilitar Docker rootless
# ============================================================================

print_info "Instalando Docker rootless..."
dockerd-rootless-setuptool.sh install

print_info "Habilitando servicio Docker para el usuario..."
systemctl --user enable --now docker

# ============================================================================
# Verificar instalación
# ============================================================================

print_info "Verificando instalación..."
if docker version &>/dev/null; then
  print_success "Docker instalado correctamente"
  docker version
else
  print_error "Error al verificar Docker"
  exit 1
fi

if docker compose version &>/dev/null; then
  print_success "Docker Compose instalado correctamente"
  docker compose version
else
  print_warning "Docker Compose v2 no disponible, verificando docker-compose..."
  docker-compose version || print_warning "Docker Compose no disponible"
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
