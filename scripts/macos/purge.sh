#!/usr/bin/env bash
# ============================================================================
# purge.sh - Eliminación completa de Docker (Colima) en macOS
# ============================================================================
# ⚠️  ADVERTENCIA: Este script elimina COMPLETAMENTE el perfil de Colima
# incluyendo TODOS los datos (imágenes, contenedores, volúmenes).
#
# Esta acción es IRREVERSIBLE. Solo úsala si:
#   - Quieres liberar espacio en disco
#   - Vas a reinstalar desde cero
#   - Ya no necesitas Docker aislado
#
# Lo que se elimina:
#   - Perfil de Colima: $COLIMA_PROFILE
#   - Todas las imágenes y volúmenes de ese perfil
#
# NOTA: Esto NO desinstala Colima ni Docker CLI, solo elimina el perfil.
#       Para desinstalar completamente, usa: brew uninstall colima docker docker-compose
#
# Uso:
#   make purge  (te pedirá confirmación)
#   # o directamente:
#   ./scripts/macos/purge.sh
# ============================================================================

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

print_header "Purga de Docker (Colima)"

print_warning "¡ATENCIÓN! Esta acción eliminará:"
echo ""
echo "  - Perfil de Colima: $COLIMA_PROFILE"
echo "  - Todas las imágenes Docker de este perfil"
echo "  - Todos los contenedores"
echo "  - Todos los volúmenes y datos"
echo ""

# ============================================================================
# Solicitar confirmación (si no viene de make purge)
# ============================================================================

if [[ "${PURGE_CONFIRMED:-}" != "yes" ]]; then
  read -r -p "¿Estás seguro de que quieres continuar? (escribe 'ELIMINAR' para confirmar): " confirm
  if [[ "$confirm" != "ELIMINAR" ]]; then
    print_info "Operación cancelada"
    exit 0
  fi
fi

# ============================================================================
# Detener Colima
# ============================================================================

print_info "Deteniendo Colima..."
colima stop --profile "$COLIMA_PROFILE" 2>/dev/null || true

# ============================================================================
# Eliminar perfil de Colima
# ============================================================================

print_info "Eliminando perfil de Colima..."
colima delete --profile "$COLIMA_PROFILE" --force 2>/dev/null || true

# ============================================================================
# Mensaje final
# ============================================================================

print_header "Purga completada"
echo ""
print_success "El perfil '$COLIMA_PROFILE' ha sido eliminado completamente"
echo ""
print_info "Para volver a instalar, ejecuta: make install && make up"
echo ""
print_info "Para desinstalar Colima y Docker completamente:"
echo ""
echo "  brew uninstall colima docker docker-compose"
echo ""
