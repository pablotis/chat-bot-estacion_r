# 🤖 Chat-Bot Asistente para Estación R

> Aplicación Shiny interactiva que proporciona asistencia pedagógica especializada en R para estudiantes de Estación R.

## 📋 Descripción

Este chat-bot está diseñado específicamente para ayudar a estudiantes principiantes e intermedios de R con un enfoque pedagógico. En lugar de dar respuestas directas, guía a los estudiantes a través del proceso de aprendizaje, ayudándolos a identificar problemas y comprender conceptos fundamentales.

## ✨ Características Principales

- **🔐 Autenticación segura** por correo electrónico
- **💬 Chat interactivo** con integración a Claude AI
- **🎯 Enfoque pedagógico** especializado en enseñanza de R
- **📱 Diseño responsivo** optimizado para móviles y escritorio
- **⚡ Respuestas en tiempo real** con indicadores visuales
- **🛡️ Control de rate limiting** para uso responsable
- **📊 Formateo automático** de código R en respuestas

## 🚀 Inicio Rápido

### Prerequisitos
- R (versión 4.0+)
- RStudio (recomendado)
- API Key de Anthropic ([obtener aquí](https://console.anthropic.com/))

### Instalación

1. **Clona o descarga** este repositorio
2. **Configura tu API Key** en `.Renviron`:
   ```
   ANTHROPIC_API_KEY="tu-api-key-real-aqui"
   ```
3. **Personaliza usuarios autorizados** en `data/authorized_emails.csv`
4. **Ejecuta la aplicación**:
   ```r
   shiny::runApp()
   ```

## 📁 Estructura del Proyecto

```
chat-bot-estacion_r/
├── app.R                     # Aplicación principal
├── R/
│   ├── auth_module.R         # Módulo de autenticación
│   ├── chat_module.R         # Módulo del chat
│   ├── claude_api.R          # Integración con API Claude
│   └── utils.R               # Funciones auxiliares
├── www/
│   ├── styles.css            # Estilos personalizados
│   └── logo.png              # Logo de Estación R (agregar)
├── data/
│   └── authorized_emails.csv # Usuarios autorizados
├── .Renviron                 # Variables de entorno
├── PROJECT.md                # Documentación técnica detallada
└── README.md                 # Este archivo
```

## 🔧 Configuración

### Variables de Entorno (`.Renviron`)
```bash
# API Key de Anthropic (REQUERIDO)
ANTHROPIC_API_KEY="sk-ant-api03-YOUR-API-KEY-HERE"

# Configuración opcional
AUTHORIZED_EMAILS_PATH="data/authorized_emails.csv"
APP_SECRET_KEY="tu-clave-secreta-aqui"
MAX_REQUESTS_PER_HOUR=30
```

### Usuarios Autorizados (`data/authorized_emails.csv`)
```csv
email,nombre,activo,fecha_registro
alumno@ejemplo.com,Nombre Alumno,TRUE,2024-01-15
profesor@estacionr.com,Profesor,TRUE,2024-01-10
```

## 🎯 Uso de la Aplicación

1. **Autenticación**: Ingresa tu correo electrónico registrado
2. **Consulta**: Escribe tu pregunta sobre R
3. **Interacción**: El asistente te guiará pedagógicamente
4. **Ejemplos predefinidos**: Usa botones de consultas comunes

### Ejemplos de Consultas
- "¿Cómo cargo un archivo CSV?"
- "Me aparece error 'object not found'"
- "¿Qué diferencia hay entre data.frame y tibble?"
- "No entiendo cómo usar el pipe %>%"

## 🧠 Enfoque Pedagógico

El asistente está configurado para:
- ✅ **Hacer preguntas guía** antes de dar respuestas
- ✅ **Explicar el "por qué"** de los errores
- ✅ **Promover buenas prácticas** de programación
- ✅ **Usar ejemplos reproducibles** con datos de juguete
- ✅ **Priorizar tidyverse** con equivalentes en base R
- ❌ **NO dar soluciones directas** sin proceso de aprendizaje

## 🔧 Paquetes Requeridos

La aplicación instala automáticamente:
- `shiny`: Framework web
- `shinyjs`: JavaScript integrado
- `httr2`: Cliente HTTP
- `jsonlite`: Manejo JSON
- `readr`: Lectura de archivos
- `R6`: Clases orientadas a objetos
- `DT`: Tablas interactivas

## 📝 Desarrollo y Contribución

Ver `PROJECT.md` para documentación técnica detallada incluyendo:
- Especificaciones completas del sistema
- Detalles de implementación de cada módulo
- Roadmap de mejoras futuras
- Guías de testing y deployment

## 🔒 Seguridad

- ✅ Autenticación por lista de correos autorizados
- ✅ Rate limiting por usuario (30 requests/hora)
- ✅ Validación y sanitización de inputs
- ✅ Manejo seguro de API keys
- ✅ No almacenamiento de conversaciones sensibles

## 📄 Licencia

Este proyecto es desarrollado para uso educativo en Estación R.

## 🆘 Soporte

Para problemas técnicos o sugerencias:
1. Revisa la documentación en `PROJECT.md`
2. Verifica tu configuración de API key
3. Contacta al equipo de Estación R

---

**Desarrollado con ❤️ para la comunidad de Estación R**