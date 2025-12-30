#!/usr/bin/env bash
# ============================================================================
# up.sh - Iniciar Docker (Colima) en macOS
# ============================================================================
# Este script inicia Colima con un perfil aislado y configura las
# variables de entorno para usar Docker.
#
# Recursos por defecto:
#   - CPU: 2 núcleos
#   - Memoria: 4 GB
#   - Disco: 30 GB
#
# Puedes personalizar estos valores modificando este script o creando
# un archivo config/.env con variables personalizadas.
#
# Uso:
#   make up
#   # o directamente:
#   ./scripts/macos/up.sh
# ============================================================================

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../common.sh"
load_env

print_header "Iniciando Docker (Colima)"

# ============================================================================
# Configuración de recursos
# ============================================================================

COLIMA_CPU="${COLIMA_CPU:-2}"
COLIMA_MEMORY="${COLIMA_MEMORY:-4}"
COLIMA_DISK="${COLIMA_DISK:-30}"

print_info "Configuración:"
echo "  - Perfil: $COLIMA_PROFILE"
echo "  - CPU: $COLIMA_CPU núcleos"
echo "  - Memoria: $COLIMA_MEMORY GB"
echo "  - Disco: $COLIMA_DISK GB"

# ============================================================================
# Verificar si ya está corriendo
# ============================================================================

if colima status --profile "$COLIMA_PROFILE" &>/dev/null; then
  print_info "Colima ya está corriendo con el perfil '$COLIMA_PROFILE'"
else
  # ============================================================================
  # Iniciar Colima
  # ============================================================================

  print_info "Iniciando Colima..."
  colima start \
    --profile "$COLIMA_PROFILE" \
    --cpu "$COLIMA_CPU" \
    --memory "$COLIMA_MEMORY" \
    --disk "$COLIMA_DISK"
fi

# ============================================================================
# Configurar variables de entorno
# ============================================================================

print_info "Configurando variables de entorno..."
eval "$(colima docker-env --profile "$COLIMA_PROFILE")"

# ============================================================================
# Verificar Docker
# ============================================================================

print_info "Verificando Docker..."
if docker info &>/dev/null; then
  print_success "Docker está listo"
else
  print_error "Docker no responde correctamente"
  exit 1
fi

# Verificar Docker Compose
if docker compose version &>/dev/null; then
  print_success "Docker Compose (plugin) disponible"
elif docker-compose version &>/dev/null; then
  print_success "Docker Compose (standalone) disponible"
else
  print_warning "Docker Compose no está disponible"
fi

# ============================================================================
# Mensaje final
# ============================================================================

print_success "Colima iniciado correctamente (perfil: $COLIMA_PROFILE)"
echo ""
print_info "Para usar Docker en otros terminales, ejecuta:"
echo ""
echo "  source scripts/macos/env.sh"
echo ""
echo "O usa eval directamente:"
echo ""
echo "  eval \"\$(colima docker-env --profile $COLIMA_PROFILE)\""
echo ""
