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
#   - Todas las imágenes, contenedores y volúmenes
#
# Uso:
#   make purge  (te pedirá confirmación)
#   # o directamente:
#   ./scripts/ubuntu/purge.sh
# ============================================================================

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
load_env

# Directorio de datos de Docker rootless
DOCKER_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/docker"

print_header "Purga de Docker Rootless"

print_warning "¡ATENCIÓN! Esta acción eliminará:"
echo ""
echo "  - Servicio Docker rootless"
echo "  - Todas las imágenes Docker descargadas"
echo "  - Todos los contenedores"
echo "  - Todos los volúmenes y datos"
echo "  - Directorio de datos: $DOCKER_DATA_HOME"
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
systemctl --user disable docker 2>/dev/null || true

# ============================================================================
# Desinstalar Docker rootless
# ============================================================================

print_info "Desinstalando Docker rootless..."
if command -v dockerd-rootless-setuptool.sh &>/dev/null; then
  dockerd-rootless-setuptool.sh uninstall 2>/dev/null || true
fi

# Eliminar servicio de usuario
rm -f "$HOME/.config/systemd/user/docker.service" 2>/dev/null || true
systemctl --user daemon-reload 2>/dev/null || true

# ============================================================================
# Eliminar directorio de datos
# ============================================================================

if [[ -d "$DOCKER_DATA_HOME" ]]; then
  print_info "Eliminando directorio de datos: $DOCKER_DATA_HOME"
  rm -rf "$DOCKER_DATA_HOME"
  print_success "Directorio eliminado"
else
  print_info "El directorio $DOCKER_DATA_HOME no existe"
fi

# ============================================================================
# Mensaje final
# ============================================================================

print_header "Purga completada"
echo ""
print_success "Docker rootless ha sido eliminado completamente"
echo ""
print_info "Para volver a instalar Docker, ejecuta: make install"
print_info "Para desinstalar completamente Docker del sistema:"
echo ""
echo "  sudo apt remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras"
echo ""
