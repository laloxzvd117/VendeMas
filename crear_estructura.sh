#!/bin/bash
# VendeMas - Crear estructura completa de carpetas
# Ejecutar desde la raíz del proyecto Flutter (dentro de frontend/)
# Uso: cd vendemas/frontend && bash ../crear_estructura.sh

echo "Creando estructura de carpetas VendeMas..."

# Core
mkdir -p lib/core/constants
mkdir -p lib/core/theme
mkdir -p lib/core/utils
mkdir -p lib/core/errors
mkdir -p lib/core/router

# Domain
mkdir -p lib/domain/entities
mkdir -p lib/domain/repositories
mkdir -p lib/domain/usecases

# Data
mkdir -p lib/data/datasources/local
mkdir -p lib/data/datasources/remote
mkdir -p lib/data/models
mkdir -p lib/data/repositories

# Presentation - Screens
mkdir -p lib/presentation/screens/onboarding
mkdir -p lib/presentation/screens/home
mkdir -p lib/presentation/screens/sell
mkdir -p lib/presentation/screens/pay
mkdir -p lib/presentation/screens/products
mkdir -p lib/presentation/screens/reports/rank
mkdir -p lib/presentation/screens/reports/abc
mkdir -p lib/presentation/screens/reports/matrix
mkdir -p lib/presentation/screens/reports/dead
mkdir -p lib/presentation/screens/reports/hours
mkdir -p lib/presentation/screens/reports/pairs
mkdir -p lib/presentation/screens/reports/trend
mkdir -p lib/presentation/screens/reports/weekly
mkdir -p lib/presentation/screens/settings

# Presentation - Widgets y Providers
mkdir -p lib/presentation/widgets
mkdir -p lib/presentation/providers

# Assets
mkdir -p assets/icons
mkdir -p assets/images
mkdir -p assets/fonts

# Tests
mkdir -p test/unit
mkdir -p test/widget
mkdir -p test/integration

echo "Estructura creada correctamente."
echo ""
echo "Carpetas generadas:"
find lib -type d | sort
