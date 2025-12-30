#!/usr/bin/env bash
# ============================================================================
# down.sh - Detener Docker Rootless en Ubuntu
# ============================================================================
# Este script detiene el servicio Docker rootless. Los contenedores
# en ejecución serán detenidos, pero los datos (imágenes, volúmenes)
# se conservan para la próxima vez que inicies Docker.
#
# Uso:
#   make down
#   # o directamente:
#   ./scripts/ubuntu/down.sh
#
# NOTA: Para eliminar completamente Docker y sus datos, usa 'make purge'
# ============================================================================

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

print_header "Deteniendo Docker Rootless"

# ============================================================================
# Detener contenedores en ejecución (opcional, Docker lo hace automáticamente)
# ============================================================================

# Cargar variables de entorno
if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

# Verificar si hay contenedores en ejecución
if docker ps -q 2>/dev/null | grep -q .; then
  print_warning "Hay contenedores en ejecución. Serán detenidos."
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
fi

# ============================================================================
# Detener servicio Docker
# ============================================================================

print_info "Deteniendo servicio Docker..."
systemctl --user stop docker 2>/dev/null || true

print_success "Docker detenido"
echo ""
print_info "Los datos (imágenes, volúmenes) se conservan."
print_info "Para iniciar Docker nuevamente: make up"
echo ""
