#!/usr/bin/env bash
# ============================================================================
# env.sh - Variables de entorno para Docker Rootless en Ubuntu
# ============================================================================
# Este script configura las variables de entorno necesarias para que
# los comandos docker y docker-compose apunten a la instalación aislada.
#
# IMPORTANTE: Este script debe ejecutarse con 'source' para que las
# variables se exporten al shell actual:
#
#   source scripts/ubuntu/env.sh
#
# Si lo ejecutas directamente (./scripts/ubuntu/env.sh), las variables
# solo existirán en el subshell y no estarán disponibles después.
#
# Variables exportadas:
#   - DOCKERD_ROOTLESS_ROOTLESSKIT_STATE_DIR: Directorio de estado
#   - XDG_DATA_HOME: Directorio de datos de Docker
#   - XDG_RUNTIME_DIR: Directorio de runtime (sockets, etc.)
#   - DOCKER_HOST: Socket de Docker para conexión
# ============================================================================

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

# ============================================================================
# Crear directorios si no existen
# ============================================================================

mkdir -p "$ISO_DOCKER_HOME"/{data,run,state}

# ============================================================================
# Exportar variables de entorno
# ============================================================================

export DOCKERD_ROOTLESS_ROOTLESSKIT_STATE_DIR="$ISO_DOCKER_HOME/state"
export XDG_DATA_HOME="$ISO_DOCKER_HOME/data"
export XDG_RUNTIME_DIR="$ISO_DOCKER_HOME/run"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

# ============================================================================
# Mostrar configuración actual (solo si se ejecuta directamente)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo ""
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  Variables de entorno para Docker Rootless                     ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  ISO_DOCKER_HOME=$ISO_DOCKER_HOME"
  echo "  DOCKERD_ROOTLESS_ROOTLESSKIT_STATE_DIR=$DOCKERD_ROOTLESS_ROOTLESSKIT_STATE_DIR"
  echo "  XDG_DATA_HOME=$XDG_DATA_HOME"
  echo "  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
  echo "  DOCKER_HOST=$DOCKER_HOST"
  echo ""
  echo "⚠️  NOTA: Para usar estas variables en tu terminal actual, ejecuta:"
  echo ""
  echo "    source scripts/ubuntu/env.sh"
  echo ""
fi
