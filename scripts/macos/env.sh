#!/usr/bin/env bash
# ============================================================================
# env.sh - Variables de entorno para Docker con Colima en macOS
# ============================================================================
# Este script configura las variables de entorno necesarias para que
# los comandos docker y docker-compose apunten al perfil de Colima.
#
# IMPORTANTE: Este script debe ejecutarse con 'source' para que las
# variables se exporten al shell actual:
#
#   source scripts/macos/env.sh
#
# Si lo ejecutas directamente (./scripts/macos/env.sh), las variables
# solo existirán en el subshell y no estarán disponibles después.
#
# Variables exportadas:
#   - DOCKER_HOST: Socket de Docker para conexión con Colima
# ============================================================================

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

# ============================================================================
# Verificar que Colima esté corriendo
# ============================================================================

if ! colima status --profile "$COLIMA_PROFILE" &>/dev/null; then
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_warning "Colima no está corriendo con el perfil '$COLIMA_PROFILE'"
    echo ""
    echo "Para iniciar Colima, ejecuta: make up"
    echo ""
  fi
  # No salimos con error para permitir cargar las variables de todas formas
fi

# ============================================================================
# Exportar variables de entorno
# ============================================================================

# Exporta DOCKER_HOST apuntando al perfil de Colima
eval "$(colima docker-env --profile "$COLIMA_PROFILE" 2>/dev/null)" || true

# ============================================================================
# Mostrar configuración actual (solo si se ejecuta directamente)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo ""
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  Variables de entorno para Docker (Colima)                     ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  COLIMA_PROFILE=$COLIMA_PROFILE"
  echo "  DOCKER_HOST=${DOCKER_HOST:-<no configurado>}"
  echo ""
  echo "⚠️  NOTA: Para usar estas variables en tu terminal actual, ejecuta:"
  echo ""
  echo "    source scripts/macos/env.sh"
  echo ""
fi
