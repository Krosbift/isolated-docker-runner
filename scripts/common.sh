#!/usr/bin/env bash
# ============================================================================
# common.sh - Funciones compartidas para Isolated Docker Runner
# ============================================================================
# Este script contiene funciones comunes utilizadas por todos los scripts
# del proyecto. No debe ejecutarse directamente.
#
# Funciones disponibles:
#   load_env()     - Carga las variables de entorno desde config/.env
#   print_header() - Imprime un encabezado formateado
#   print_success()- Imprime un mensaje de éxito
#   print_error()  - Imprime un mensaje de error
#   print_warning()- Imprime un mensaje de advertencia
#   print_info()   - Imprime un mensaje informativo
# ============================================================================

set -euo pipefail

# Obtiene la ruta raíz del repositorio
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ============================================================================
# Funciones de utilidad para mensajes
# ============================================================================

print_header() {
  echo ""
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  $1"
  echo "╚════════════════════════════════════════════════════════════════╝"
}

print_success() {
  echo "✅ $1"
}

print_error() {
  echo "❌ $1" >&2
}

print_warning() {
  echo "⚠️  $1"
}

print_info() {
  echo "ℹ️  $1"
}

# ============================================================================
# Carga de variables de entorno
# ============================================================================
# Carga las variables desde config/.env si existe, o desde .env.example
# Variables soportadas:
#   - ISO_DOCKER_HOME: Directorio donde se almacenan los datos de Docker
#   - COLIMA_PROFILE: Nombre del perfil de Colima (solo macOS)
# ============================================================================

load_env() {
  local env_file="$REPO_ROOT/config/.env"
  local env_example="$REPO_ROOT/config/.env.example"

  if [[ -f "$env_file" ]]; then
    print_info "Cargando configuración desde config/.env"
    # shellcheck disable=SC1090
    source "$env_file"
  elif [[ -f "$env_example" ]]; then
    print_warning "No existe config/.env, usando config/.env.example"
    # shellcheck disable=SC1090
    source "$env_example"
  else
    print_warning "No se encontró archivo de configuración, usando valores por defecto"
  fi

  # Valores por defecto
  export ISO_DOCKER_HOME="${ISO_DOCKER_HOME:-$HOME/.isodocker}"
  export COLIMA_PROFILE="${COLIMA_PROFILE:-isodocker}"
}
