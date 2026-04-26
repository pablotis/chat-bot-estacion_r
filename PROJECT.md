# Proyecto: Chat-Bot Asistente para Estación R

## Objetivo General

Crear una aplicación Shiny en R que funcione como chat-bot asistente para alumnos y ex-alumnos de Estación R, brindando soporte en su aprendizaje de R con un enfoque pedagógico.

## Especificaciones Técnicas

### Stack Tecnológico

-   **Framework**: Shiny para R
-   **Lenguaje**: R
-   **Autenticación**: Sistema de validación por correo electrónico
-   **API**: Integración con API de Anthropic (Claude)
-   **UI**: Interface de chat moderna y responsiva

### Estructura de la Aplicación

#### 1. Sistema de Autenticación

-   Crear un módulo de login que valide correos electrónicos
-   Mantener una lista de correos autorizados (alumnos y ex-alumnos de Estación R)
-   Implementar sesiones de usuario para mantener el estado de autenticación
-   Incluir opción de logout

#### 2. Interface de Usuario (UI)

-   **Pantalla de Login**:
    -   Campo para correo electrónico
    -   Botón de ingreso
    -   Mensaje de error para correos no autorizados
-   **Pantalla Principal (Chat)**:
    -   Header con logo de Estación R y nombre del usuario
    -   Área de conversación con scroll automático
    -   Campo de entrada de texto para consultas
    -   Botón de envío
    -   Indicador de "escribiendo..." mientras se procesa la respuesta
    -   Botón de logout

#### 3. Backend y Lógica del Server

-   Gestión de sesiones de usuario
-   Integración con API de Claude mediante httr2 o similar
-   Almacenamiento temporal del historial de conversación por sesión
-   Manejo de errores y timeouts

## Configuración del Asistente Claude

### Prompt del Sistema

El asistente debe ser configurado con el siguiente comportamiento:

```         
Sos un asistente especializado en R para estudiantes de Estación R. Tu rol es ayudar a estudiantes principiantes e intermedios con sus consultas sobre programación en R.

REGLAS FUNDAMENTALES:
1. Respondé SIEMPRE en español rioplatense, de forma clara y didáctica
2. Si falta contexto mínimo para responder, pedí la información necesaria
3. Mostrá soluciones preferentemente con tidyverse, y cuando sea relevante, incluí el equivalente en base R
4. Proporcioná ejemplos reproducibles cortos con datos de juguete cuando no te proporcionen datos
5. IMPORTANTE: Tu primer intento NO debe ser dar la solución directa, sino ayudar a quien consulta a identificar dónde está el problema. Priorizá el proceso de aprendizaje
6. Si no podés resolver algo, explicá claramente por qué y pedí exactamente lo que necesitás para avanzar
7. NO respondas consultas que no estén relacionadas con R

ENFOQUE PEDAGÓGICO:
- Hacé preguntas guía como "¿Qué error te está mostrando R?" o "¿Podés mostrarme qué intentaste hasta ahora?"
- Explicá el "por qué" detrás de los errores comunes
- Usá analogías cuando sea útil para explicar conceptos
- Fomentá las buenas prácticas de programación
```

### Manejo de Consultas

#### Estructura de Respuesta Típica:

1.  **Validación**: Verificar que la consulta sea sobre R
2.  **Comprensión**: Asegurar que se entiende el problema
3.  **Guía**: Hacer preguntas para que el estudiante reflexione
4.  **Ejemplo**: Si corresponde, mostrar un ejemplo mínimo
5.  **Explicación**: Detallar el concepto subyacente
6.  **Práctica**: Sugerir ejercicios o variaciones

## Características Adicionales

### Funcionalidades Recomendadas:

1.  **Historial de Conversación**:
    -   Permitir al usuario ver conversaciones anteriores en la sesión actual
    -   Opción de limpiar el historial
2.  **Ejemplos Predefinidos**:
    -   Botones con consultas comunes para nuevos usuarios
    -   Ej: "¿Cómo cargo un CSV?", "¿Qué es el pipe %\>%?", "Error: object not found"
3.  **Formato de Código**:
    -   Resaltar sintaxis de R en las respuestas
    -   Permitir copiar código con un click
4.  **Límites y Seguridad**:
    -   Límite de caracteres por consulta (ej: 1000 caracteres)
    -   Rate limiting por usuario
    -   Timeout para respuestas largas

## Configuración y Deployment

### Variables de Entorno Necesarias:

``` r
# .Renviron
ANTHROPIC_API_KEY="tu-api-key-aqui"
AUTHORIZED_EMAILS_PATH="path/to/authorized_emails.csv"
APP_SECRET_KEY="clave-secreta-para-sesiones"
```

### Estructura de Archivos Sugerida:

```         
estacion-r-chatbot/
├── app.R                 # Archivo principal de Shiny
├── R/
│   ├── auth_module.R     # Módulo de autenticación
│   ├── chat_module.R     # Módulo del chat
│   ├── claude_api.R      # Funciones para API de Claude
│   └── utils.R           # Funciones auxiliares
├── www/
│   ├── styles.css        # Estilos personalizados
│   └── logo.png          # Logo de Estación R
├── data/
│   └── authorized_emails.csv
├── .Renviron
└── README.md
```

## Ejemplo de Interacción

**Usuario**: "me sale error cuando intento hacer un gráfico"

**Asistente**: "¡Hola! Veo que tenés un problema con un gráfico. Para poder ayudarte mejor, ¿me podrías contar: 1. ¿Qué tipo de gráfico estás intentando hacer? (barras, puntos, líneas, etc.) 2. ¿Qué mensaje de error específico te muestra R? 3. ¿Estás usando ggplot2 o las funciones base de R?

Mientras tanto, te dejo un tip: los errores más comunes con gráficos suelen estar relacionados con el formato de los datos o con escribir mal el nombre de alguna variable."

## Testing y Validación

### Casos de Prueba Esenciales:

1.  Login con correo autorizado/no autorizado
2.  Consulta válida sobre R
3.  Consulta no relacionada con R
4.  Manejo de timeout en respuestas
5.  Formato correcto de código R
6.  Persistencia de conversación durante la sesión

### Métricas de Éxito:

-   Tiempo de respuesta \< 5 segundos
-   Tasa de respuestas pedagógicas vs directas \> 70%
-   Satisfacción del usuario con la calidad de las respuestas

## Notas para el Desarrollo con Claude-Code

Al usar Claude-Code para desarrollar esta aplicación:

1.  **Comenzá con el módulo de autenticación** para asegurar que solo usuarios autorizados accedan
2.  **Implementá la UI básica del chat** antes de integrar la API
3.  **Testeá la integración con Claude API** con consultas simples primero
4.  **Refiná el prompt del sistema** basándote en las respuestas obtenidas
5.  **Agregá features adicionales** una vez que el chat básico funcione

### Comandos Sugeridos para Claude-Code:

``` bash
# Iniciar el proyecto
claude-code "Crear estructura básica de app Shiny con autenticación por email"

# Desarrollar el chat
claude-code "Implementar interface de chat con integración a API de Claude"

# Refinar el asistente
claude-code "Ajustar prompt del sistema para respuestas más pedagógicas"

# Testing
claude-code "Crear tests para validar comportamiento del chat-bot"
```

## Consideraciones Finales

-   Asegurate de que el asistente mantenga siempre un tono amigable y motivador
-   El foco debe estar en el aprendizaje, no en resolver rápidamente
-   Considerá agregar un sistema de feedback para mejorar las respuestas
-   Mantenté un log de consultas frecuentes para crear una FAQ

## Estado de Desarrollo

### ✅ COMPLETADO (Versión 1.0)

#### Estructura del Proyecto
- [x] Creación de directorios principales (`R/`, `www/`, `data/`)
- [x] Estructura modular de la aplicación implementada

#### Módulo de Autenticación (`R/auth_module.R`)
- [x] UI de login con campo de email y validación
- [x] Validación de correos autorizados desde archivo CSV
- [x] Sistema de sesiones de usuario
- [x] Manejo de errores de autenticación
- [x] Función de logout implementada

#### Módulo de Chat (`R/chat_module.R`)
- [x] Interfaz de chat completa con header, área de mensajes y entrada de texto
- [x] Botones de consultas predefinidas
- [x] Indicador de "escribiendo..." durante procesamiento
- [x] Manejo de historial de conversación
- [x] Scroll automático en área de mensajes
- [x] Límite de caracteres por mensaje (1000)

#### Integración con API Claude (`R/claude_api.R`)
- [x] Clase `ClaudeAPI` con método R6 para comunicación con Anthropic
- [x] Validación de consultas relacionadas con R
- [x] Prompt del sistema configurado según especificaciones pedagógicas
- [x] Procesamiento de respuestas con formato HTML
- [x] Manejo de errores de API (timeouts, autenticación, rate limits)
- [x] Formateo automático de código R en respuestas

#### Funciones Auxiliares (`R/utils.R`)
- [x] Validación de emails
- [x] Sanitización de inputs de usuario  
- [x] Sistema de logging básico
- [x] Clase `RateLimiter` para control de requests por hora
- [x] Funciones de configuración y validación de entorno

#### Aplicación Principal (`app.R`)
- [x] Integración de todos los módulos
- [x] Configuración de UI responsiva
- [x] Manejo global de errores
- [x] JavaScript personalizado para funcionalidades del chat
- [x] Logging de sesiones de usuario

#### Configuración y Datos
- [x] Archivo `.Renviron` con variables de entorno necesarias
- [x] Archivo `data/authorized_emails.csv` con usuarios de ejemplo
- [x] Documentación de configuración incluida

#### Estilos y UI (`www/styles.css`)
- [x] Diseño moderno y responsivo
- [x] Tema de colores consistente con Estación R
- [x] Animaciones y transiciones suaves
- [x] Formateo específico para código R
- [x] Diseño móvil optimizado
- [x] Indicadores visuales de estado (typing, errores, etc.)

### 📝 Instrucciones de Instalación y Uso

#### Prerequisitos
- R (versión 4.0 o superior)
- RStudio (recomendado)
- Cuenta de Anthropic con API Key

#### Instalación
1. **Clonar/Descargar** el proyecto en tu directorio de trabajo
2. **Configurar API Key**: Editar `.Renviron` y reemplazar `"sk-ant-api03-YOUR-API-KEY-HERE"` con tu API key real de Anthropic
3. **Personalizar emails**: Editar `data/authorized_emails.csv` con los correos de usuarios autorizados
4. **Instalar paquetes**: La aplicación verificará e instalará automáticamente los paquetes requeridos al inicio

#### Ejecución
```r
# Desde RStudio o consola R
shiny::runApp()
```

La aplicación se abrirá en tu navegador por defecto en `http://127.0.0.1:XXXX`

#### Paquetes Requeridos
- `shiny`: Framework web para R  
- `shinyjs`: Funcionalidades JavaScript en Shiny
- `DT`: Tablas interactivas 
- `httr2`: Cliente HTTP para API calls
- `jsonlite`: Manejo de JSON
- `readr`: Lectura eficiente de archivos CSV
- `R6`: Sistema de clases orientado a objetos

### 🚀 Próximas Mejoras Sugeridas

#### Funcionalidades Adicionales
- [ ] Sistema de feedback para mejorar respuestas
- [ ] Historial persistente de conversaciones entre sesiones  
- [ ] Exportación de conversaciones a PDF/HTML
- [ ] Panel administrativo para gestión de usuarios
- [ ] Métricas de uso y analíticas
- [ ] Integración con sistema de ticketing

#### Mejoras Técnicas  
- [ ] Base de datos para almacenar usuarios y conversaciones
- [ ] Sistema de cache para respuestas frecuentes
- [ ] Optimización de rendimiento para múltiples usuarios
- [ ] Tests automatizados unitarios e integración
- [ ] Logging avanzado con rotación de archivos
- [ ] Deployment en servidor de producción (Docker, Shiny Server)

#### UX/UI
- [ ] Tema oscuro opcional
- [ ] Personalización de colores por usuario
- [ ] Notificaciones push para respuestas
- [ ] Búsqueda en historial de conversaciones
- [ ] Shortcuts de teclado avanzados

### 🛠️ Comandos Git Sugeridos

```bash
# Inicializar repositorio
git init
git add .
git commit -m "Initial commit: Chat-Bot Estación R v1.0

- Implement complete authentication system
- Add interactive chat interface with Claude API integration  
- Include responsive design with custom CSS
- Add rate limiting and error handling
- Configure environment variables and sample data"

# Para actualizaciones futuras
git add .
git commit -m "Update: [descripción específica de cambios]"
```

**IMPORTANTE**: Antes de hacer commits, asegurate de:
1. Remover tu API key real del archivo `.Renviron`
2. Verificar que no hay información sensible en los archivos
3. Probar la aplicación localmente

------------------------------------------------------------------------