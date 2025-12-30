# ============================================================================
# Isolated Docker Runner - Makefile
# ============================================================================
# Este Makefile detecta automáticamente el sistema operativo y ejecuta
# los scripts correspondientes para gestionar Docker de forma aislada.
#
# Comandos disponibles:
#   make install  - Instala Docker de forma aislada (solo primera vez)
#   make up       - Inicia el servicio Docker aislado
#   make down     - Detiene el servicio Docker aislado
#   make purge    - Elimina completamente Docker aislado y sus datos
#   make status   - Muestra el estado actual de Docker
#   make env      - Muestra las variables de entorno necesarias
# ============================================================================

SHELL := /bin/bash
OS := $(shell uname -s)

.PHONY: install up down purge status env help

# Muestra la ayuda por defecto
help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║         Isolated Docker Runner - Comandos disponibles          ║"
	@echo "╠════════════════════════════════════════════════════════════════╣"
	@echo "║  make install  │ Instala Docker aislado (solo primera vez)     ║"
	@echo "║  make up       │ Inicia el servicio Docker                     ║"
	@echo "║  make down     │ Detiene el servicio Docker                    ║"
	@echo "║  make purge    │ Elimina Docker aislado y todos sus datos      ║"
	@echo "║  make status   │ Muestra el estado de Docker                   ║"
	@echo "║  make env      │ Muestra variables de entorno para tu shell    ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Sistema detectado: $(OS)"

install:
	@if [ "$(OS)" = "Linux" ]; then ./scripts/ubuntu/install.sh; \
	elif [ "$(OS)" = "Darwin" ]; then ./scripts/macos/install.sh; \
	else echo "❌ OS no soportado: $(OS)"; exit 1; fi

up:
	@if [ "$(OS)" = "Linux" ]; then ./scripts/ubuntu/up.sh; \
	elif [ "$(OS)" = "Darwin" ]; then ./scripts/macos/up.sh; \
	else echo "❌ OS no soportado: $(OS)"; exit 1; fi

down:
	@if [ "$(OS)" = "Linux" ]; then ./scripts/ubuntu/down.sh; \
	elif [ "$(OS)" = "Darwin" ]; then ./scripts/macos/down.sh; \
	else echo "❌ OS no soportado: $(OS)"; exit 1; fi

purge:
	@echo "⚠️  ADVERTENCIA: Esto eliminará Docker aislado y TODOS sus datos."
	@read -p "¿Estás seguro? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@if [ "$(OS)" = "Linux" ]; then ./scripts/ubuntu/purge.sh; \
	elif [ "$(OS)" = "Darwin" ]; then ./scripts/macos/purge.sh; \
	else echo "❌ OS no soportado: $(OS)"; exit 1; fi

status:
	@if [ "$(OS)" = "Linux" ]; then \
		echo "📊 Estado de Docker Rootless:"; \
		systemctl --user status docker 2>/dev/null || echo "Docker no está corriendo"; \
	elif [ "$(OS)" = "Darwin" ]; then \
		echo "📊 Estado de Colima:"; \
		colima status 2>/dev/null || echo "Colima no está corriendo"; \
	else echo "❌ OS no soportado: $(OS)"; exit 1; fi

env:
	@if [ "$(OS)" = "Linux" ]; then ./scripts/ubuntu/env.sh && echo "# Ejecuta: source scripts/ubuntu/env.sh"; \
	elif [ "$(OS)" = "Darwin" ]; then ./scripts/macos/env.sh && echo "# Ejecuta: source scripts/macos/env.sh"; \
	else echo "❌ OS no soportado: $(OS)"; exit 1; fi
