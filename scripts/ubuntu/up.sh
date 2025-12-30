#!/usr/bin/env bash
# ============================================================================
# up.sh - Iniciar Docker Rootless en Ubuntu
# ============================================================================
# Este script inicia el servicio Docker rootless y verifica que esté
# funcionando correctamente.
#
# Uso:
#   make up
#   # o directamente:
#   ./scripts/ubuntu/up.sh
#
# El script:
#   1. Carga las variables de entorno
#   2. Inicia el servicio Docker del usuario
#   3. Verifica que Docker esté respondiendo
#   4. Muestra información del socket para usar en otros terminales
# ============================================================================

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

print_header "Iniciando Docker Rootless"

# ============================================================================
# Iniciar servicio Docker
# ============================================================================

print_info "Iniciando servicio Docker..."
systemctl --user start docker

# Esperar a que Docker esté listo (máximo 30 segundos)
print_info "Esperando a que Docker esté listo..."
for i in {1..30}; do
  if docker info &>/dev/null; then
    break
  fi
  sleep 1
  if [[ $i -eq 30 ]]; then
    print_error "Docker no respondió después de 30 segundos"
    exit 1
  fi
done

# ============================================================================
# Verificar estado
# ============================================================================

print_success "Docker rootless iniciado correctamente"
echo ""
echo "Socket: $DOCKER_HOST"
echo ""
print_info "Para usar Docker en otros terminales, ejecuta:"
echo ""
echo "  source scripts/ubuntu/env.sh"
echo ""
echo "O exporta directamente:"
echo ""
echo "  export DOCKER_HOST=\"$DOCKER_HOST\""
echo ""
