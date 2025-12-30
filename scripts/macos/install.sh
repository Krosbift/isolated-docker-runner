#!/usr/bin/env bash
# ============================================================================
# install.sh - Instalación de Docker con Colima en macOS
# ============================================================================
# Este script instala Docker usando Colima como runtime, lo cual permite
# ejecutar contenedores de forma aislada sin necesidad de Docker Desktop.
#
# ¿Por qué Colima en lugar de Docker Desktop?
#   - Es gratuito y open source (Docker Desktop requiere licencia comercial)
#   - Menor consumo de recursos
#   - Perfiles aislados para diferentes proyectos
#   - Sin telemetría ni actualizaciones forzadas
#
# Requisitos:
#   - macOS 10.15 (Catalina) o superior
#   - Homebrew instalado (https://brew.sh)
#   - Conexión a internet
#
# Lo que hace este script:
#   1. Verifica que Homebrew esté instalado
#   2. Instala Colima (runtime de contenedores)
#   3. Instala Docker CLI y Docker Compose
#
# Uso:
#   make install
#   # o directamente:
#   ./scripts/macos/install.sh
# ============================================================================

set -euo pipefail

# Cargar funciones comunes y variables de entorno
# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

print_header "Instalación de Docker con Colima en macOS"

# ============================================================================
# Verificar requisitos previos
# ============================================================================

print_info "Verificando requisitos del sistema..."

# Verificar Homebrew
if ! command -v brew &>/dev/null; then
  print_error "Homebrew no está instalado"
  echo ""
  echo "Homebrew es necesario para instalar Colima y Docker."
  echo "Puedes instalarlo ejecutando:"
  echo ""
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo ""
  echo "Más información: https://brew.sh"
  exit 1
fi

print_success "Homebrew encontrado: $(brew --version | head -1)"

# Verificar arquitectura
ARCH=$(uname -m)
print_info "Arquitectura detectada: $ARCH"

# ============================================================================
# Actualizar Homebrew e instalar paquetes
# ============================================================================

print_info "Actualizando Homebrew..."
brew update

print_info "Instalando Colima (runtime de contenedores)..."
brew install colima

print_info "Instalando Docker CLI..."
brew install docker

print_info "Instalando Docker Compose..."
brew install docker-compose

# ============================================================================
# Verificar instalación
# ============================================================================

print_success "Instalación completada"
echo ""
echo "Versiones instaladas:"
echo "  - Colima: $(colima version | head -1)"
echo "  - Docker: $(docker --version)"
echo "  - Docker Compose: $(docker-compose --version)"

# ============================================================================
# Instrucciones finales
# ============================================================================

print_header "¡Instalación completada!"
echo ""
echo "Para iniciar Docker, ejecuta:"
echo ""
echo "  make up"
echo ""
echo "Esto iniciará Colima con el perfil '$COLIMA_PROFILE' usando:"
echo "  - 2 CPUs"
echo "  - 4 GB de memoria"
echo "  - 30 GB de disco"
echo ""
echo "Puedes personalizar estos valores en config/.env"
echo ""
echo "Comandos disponibles:"
echo "  make up     - Iniciar Docker (Colima)"
echo "  make down   - Detener Docker (Colima)"
echo "  make status - Ver estado"
echo "  make purge  - Eliminar completamente"
echo ""
