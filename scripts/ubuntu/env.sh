#!/usr/bin/env bash
# ============================================================================
# env.sh - Variables de entorno para Docker Rootless en Ubuntu
# ============================================================================
# Este script configura las variables de entorno necesarias para que
# los comandos docker y docker-compose apunten a la instalación rootless.
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
#   - XDG_RUNTIME_DIR: Directorio de runtime (sockets, etc.)
#   - DOCKER_HOST: Socket de Docker para conexión
# ============================================================================

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
load_env

# ============================================================================
# Configurar XDG_RUNTIME_DIR si no existe
# ============================================================================

if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# ============================================================================
# Exportar DOCKER_HOST apuntando al socket rootless
# ============================================================================

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
  echo "  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
  echo "  DOCKER_HOST=$DOCKER_HOST"
  echo ""
  echo "⚠️  NOTA: Para usar estas variables en tu terminal actual, ejecuta:"
  echo ""
  echo "    source scripts/ubuntu/env.sh"
  echo ""
fi
