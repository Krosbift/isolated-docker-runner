#!/usr/bin/env bash
# ============================================================================
# down.sh - Detener Docker (Colima) en macOS
# ============================================================================
# Este script detiene Colima, liberando recursos del sistema.
# Los datos (imágenes, volúmenes) se conservan para la próxima vez.
#
# Uso:
#   make down
#   # o directamente:
#   ./scripts/macos/down.sh
#
# NOTA: Para eliminar completamente Colima y sus datos, usa 'make purge'
# ============================================================================

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

print_header "Deteniendo Docker (Colima)"

# ============================================================================
# Verificar estado actual
# ============================================================================

if ! colima status --profile "$COLIMA_PROFILE" &>/dev/null; then
  print_info "Colima no está corriendo con el perfil '$COLIMA_PROFILE'"
  exit 0
fi

# ============================================================================
# Mostrar contenedores en ejecución
# ============================================================================

eval "$(colima docker-env --profile "$COLIMA_PROFILE" 2>/dev/null)" || true

if docker ps -q 2>/dev/null | grep -q .; then
  print_warning "Hay contenedores en ejecución. Serán detenidos."
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
  echo ""
fi

# ============================================================================
# Detener Colima
# ============================================================================

print_info "Deteniendo Colima..."
colima stop --profile "$COLIMA_PROFILE" 2>/dev/null || true

print_success "Colima detenido"
echo ""
print_info "Los datos (imágenes, volúmenes) se conservan."
print_info "Para iniciar Docker nuevamente: make up"
echo ""
