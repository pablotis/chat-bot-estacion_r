# Módulo de Autenticación
# Este módulo maneja el login por correo electrónico y validación de usuarios autorizados

library(shiny)
library(DT)
library(readr)

# UI del módulo de autenticación
auth_ui <- function(id) {
  ns <- NS(id)
  
  div(
    id = ns("login_panel"),
    class = "login-container",
    
    div(
      class = "login-box",
      
      h2("Estación R - Chat Asistente", class = "login-title"),
      p("Ingresá tu correo electrónico para acceder", class = "login-subtitle"),
      
      textInput(
        ns("email_input"),
        label = NULL,
        placeholder = "tu.email@ejemplo.com",
        width = "100%"
      ),
      
      actionButton(
        ns("login_btn"),
        "Ingresar",
        class = "btn-primary login-btn",
        width = "100%"
      ),
      
      div(
        id = ns("error_message"),
        class = "error-message",
        style = "display: none;"
      )
    )
  )
}

# Servidor del módulo de autenticación
auth_server <- function(id, authorized_emails_path) {
  moduleServer(id, function(input, output, session) {
    
    # Variables reactivas
    values <- reactiveValues(
      authenticated = FALSE,
      user_email = NULL,
      authorized_emails = NULL
    )
    
    # Cargar emails autorizados al inicializar
    observe({
      if (file.exists(authorized_emails_path)) {
        values$authorized_emails <- read_csv(authorized_emails_path, col_types = cols())$email
      } else {
        # Crear archivo de ejemplo si no existe
        sample_emails <- data.frame(
          email = c("alumno1@ejemplo.com", "alumno2@ejemplo.com", "profesor@estacionr.com")
        )
        write_csv(sample_emails, authorized_emails_path)
        values$authorized_emails <- sample_emails$email
      }
    })
    
    # Manejar click en botón de login
    observeEvent(input$login_btn, {
      email <- tolower(trimws(input$email_input))
      
      if (email == "") {
        show_error("Por favor, ingresá tu correo electrónico")
        return()
      }
      
      if (!is_valid_email(email)) {
        show_error("Por favor, ingresá un correo electrónico válido")
        return()
      }
      
      if (email %in% values$authorized_emails) {
        values$authenticated <- TRUE
        values$user_email <- email
        hide_error()
        
        # Ocultar panel de login
        shinyjs::hide("login_panel")
      } else {
        show_error("Correo electrónico no autorizado. Contactá a Estación R si creés que es un error.")
      }
    })
    
    # Función para mostrar errores
    show_error <- function(message) {
      output$error_content <- renderText(message)
      shinyjs::html("error_message", message)
      shinyjs::show("error_message")
    }
    
    # Función para ocultar errores
    hide_error <- function() {
      shinyjs::hide("error_message")
    }
    
    # Función para validar formato de email
    is_valid_email <- function(email) {
      grepl("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", email)
    }
    
    # Función para logout
    logout <- function() {
      values$authenticated <- FALSE
      values$user_email <- NULL
      updateTextInput(session, "email_input", value = "")
      shinyjs::show("login_panel")
    }
    
    # Retornar valores reactivos y funciones
    return(
      list(
        authenticated = reactive(values$authenticated),
        user_email = reactive(values$user_email),
        logout = logout
      )
    )
  })
}