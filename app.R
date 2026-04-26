# Chat-Bot Asistente para Estación R
# Aplicación Shiny principal

# Cargar librerías necesarias
library(shiny)
library(shinyjs)
library(DT)
library(httr2)
library(jsonlite)
library(readr)
library(R6)

# Cargar módulos y funciones auxiliares
source("R/utils.R")
source("R/auth_module.R")
source("R/chat_module.R")
source("R/claude_api.R")

# Verificar configuración y paquetes al inicio
tryCatch({
  check_required_packages()
  ensure_directories()
  validate_app_config()
}, error = function(e) {
  cat("Error de configuración:", e$message, "\n")
  cat("Por favor, revisá la configuración antes de continuar.\n")
})

# Configuración global
options(shiny.maxRequestSize = 10*1024^2)  # 10MB máximo para uploads

# Crear instancia del rate limiter
rate_limiter <- RateLimiter$new(max_requests = 30, time_window = 3600)  # 30 requests por hora

# UI Principal
ui <- fluidPage(
  
  # Configurar shinyjs
  useShinyjs(),
  
  # Meta tags
  tags$head(
    tags$meta(charset = "UTF-8"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0"),
    tags$title("Estación R - Chat Asistente"),
    
    # Cargar estilos CSS
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    
    # JavaScript personalizado
    tags$script('
      // Función para scroll automático
      Shiny.addCustomMessageHandler("scrollToBottom", function(elementId) {
        var element = document.getElementById(elementId);
        if (element) {
          element.scrollTop = element.scrollHeight;
        }
      });
      
      // Manejar Enter en textarea (enviar) vs Shift+Enter (nueva línea)
      $(document).on("keydown", "textarea", function(e) {
        if (e.keyCode === 13 && !e.shiftKey) {
          e.preventDefault();
          $(this).closest(".chat-input-container").find(".send-btn").click();
        }
      });
    ')
  ),
  
  # Contenido principal
  div(
    class = "app-container",
    
    # Módulo de autenticación
    auth_ui("auth"),
    
    # Módulo de chat
    chat_ui("chat")
  )
)

# Servidor Principal
server <- function(input, output, session) {
  
  # Configurar API de Claude
  claude_api <- reactive({
    tryCatch({
      create_claude_api()
    }, error = function(e) {
      showNotification(
        paste("Error al configurar API de Claude:", e$message),
        type = "error",
        duration = 10
      )
      NULL
    })
  })
  
  # Configurar ruta del archivo de emails autorizados
  authorized_emails_path <- get_config("AUTHORIZED_EMAILS_PATH", "data/authorized_emails.csv")
  
  # Crear archivo de emails de ejemplo si no existe
  if (!file.exists(authorized_emails_path)) {
    create_sample_emails(authorized_emails_path)
  }
  
  # Servidor del módulo de autenticación
  auth <- auth_server("auth", authorized_emails_path)
  
  # Servidor del módulo de chat
  chat <- chat_server("chat", auth$user_email, claude_api)
  
  # Manejar logout desde el módulo de chat
  observeEvent(input[["chat-logout_btn"]], {
    auth$logout()
    chat$clear_history()
    
    showNotification(
      "Sesión cerrada exitosamente",
      type = "message",
      duration = 3
    )
  })
  
  # Rate limiting: verificar antes de permitir requests a la API
  observe({
    if (!is.null(auth$user_email()) && auth$authenticated()) {
      user_email <- auth$user_email()
      
      # Esta lógica se implementaría en el módulo de chat
      # para verificar rate limiting antes de cada request
    }
  })
  
  # Logging de sesiones
  observe({
    if (auth$authenticated()) {
      log_message(
        paste("Usuario autenticado:", auth$user_email()),
        level = "INFO",
        user_email = auth$user_email()
      )
    }
  })
  
  # Manejo de errores globales
  options(shiny.error = function() {
    log_message("Error en la aplicación", level = "ERROR")
  })
  
  # Cleanup al cerrar sesión
  session$onSessionEnded(function() {
    if (!is.null(auth$user_email()) && auth$user_email() != "") {
      log_message(
        paste("Sesión terminada:", auth$user_email()),
        level = "INFO",
        user_email = auth$user_email()
      )
    }
  })
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)