#!/usr/bin/env bash
# ============================================================================
# purge.sh - Eliminación completa de Docker Rootless en Ubuntu
# ============================================================================
# ⚠️  ADVERTENCIA: Este script elimina COMPLETAMENTE Docker rootless
# incluyendo TODOS los datos (imágenes, contenedores, volúmenes).
#
# Esta acción es IRREVERSIBLE. Solo úsala si:
#   - Quieres liberar espacio en disco
#   - Vas a reinstalar Docker desde cero
#   - Ya no necesitas Docker aislado
#
# Lo que se elimina:
#   - Servicio Docker rootless del usuario
#   - Directorio $ISO_DOCKER_HOME con todas las imágenes y volúmenes
#
# Uso:
#   make purge  (te pedirá confirmación)
#   # o directamente:
#   ./scripts/ubuntu/purge.sh
# ============================================================================

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

print_header "Purga de Docker Rootless"

print_warning "¡ATENCIÓN! Esta acción eliminará:"
echo ""
echo "  - Servicio Docker rootless"
echo "  - Todas las imágenes Docker descargadas"
echo "  - Todos los contenedores"
echo "  - Todos los volúmenes y datos"
echo "  - Directorio: $ISO_DOCKER_HOME"
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
# Detener servicio Docker
# ============================================================================

print_info "Deteniendo servicio Docker..."
systemctl --user stop docker 2>/dev/null || true

# ============================================================================
# Desinstalar Docker rootless
# ============================================================================

print_info "Desinstalando Docker rootless..."
if command -v dockerd-rootless-setuptool.sh &>/dev/null; then
  dockerd-rootless-setuptool.sh uninstall 2>/dev/null || true
fi

# ============================================================================
# Eliminar directorio de datos
# ============================================================================

if [[ -d "$ISO_DOCKER_HOME" ]]; then
  print_info "Eliminando directorio de datos: $ISO_DOCKER_HOME"
  rm -rf "$ISO_DOCKER_HOME"
  print_success "Directorio eliminado"
else
  print_info "El directorio $ISO_DOCKER_HOME no existe"
fi

# ============================================================================
# Mensaje final
# ============================================================================

print_header "Purga completada"
echo ""
print_success "Docker rootless ha sido eliminado completamente"
echo ""
print_info "Para volver a instalar Docker, ejecuta: make install"
echo ""
