# Módulo de Chat
# Este módulo maneja la interfaz del chat y la comunicación con el usuario

library(shiny)
library(shinyjs)

# UI del módulo de chat
chat_ui <- function(id) {
  ns <- NS(id)
  
  div(
    id = ns("chat_panel"),
    class = "chat-container",
    style = "display: none;",
    
    # Header del chat
    div(
      class = "chat-header",
      
      div(
        class = "header-left",
        img(src = "logo.png", class = "logo", height = "40px"),
        h3("Estación R - Asistente", class = "app-title")
      ),
      
      div(
        class = "header-right",
        span(textOutput(ns("user_email_display")), class = "user-email"),
        actionButton(
          ns("logout_btn"),
          "Salir",
          class = "btn-outline logout-btn"
        )
      )
    ),
    
    # Área de conversación
    div(
      class = "chat-messages",
      id = ns("messages_container"),
      
      # Mensaje de bienvenida
      div(
        class = "message bot-message welcome-message",
        div(
          class = "message-content",
          h4("¡Hola! Soy tu asistente de R de Estación R 👋"),
          p("Estoy acá para ayudarte con tus consultas sobre programación en R. 
            Recordá que mi enfoque es pedagógico: no solo te voy a dar la respuesta, 
            sino que te voy a ayudar a entender el problema y aprender en el proceso."),
          p("Podés empezar preguntándome sobre:"),
          tags$ul(
            tags$li("Errores que te aparecen en R"),
            tags$li("Cómo hacer análisis de datos"),
            tags$li("Dudas sobre funciones específicas"),
            tags$li("Buenas prácticas de programación")
          ),
          p("¿En qué te puedo ayudar hoy?")
        )
      )
    ),
    
    # Indicador de "escribiendo..."
    div(
      id = ns("typing_indicator"),
      class = "typing-indicator",
      style = "display: none;",
      div(class = "typing-dots",
          span(), span(), span()
      ),
      span("El asistente está escribiendo...")
    ),
    
    # Área de entrada de texto
    div(
      class = "chat-input-container",
      
      # Botones de consultas predefinidas
      div(
        class = "quick-questions",
        actionButton(ns("q1"), "¿Cómo cargo un CSV?", class = "btn-quick"),
        actionButton(ns("q2"), "¿Qué es el pipe %>%?", class = "btn-quick"),
        actionButton(ns("q3"), "Error: object not found", class = "btn-quick")
      ),
      
      # Input de texto y botón de envío
      div(
        class = "input-row",
        textAreaInput(
          ns("user_input"),
          label = NULL,
          placeholder = "Escribí tu consulta sobre R aquí...",
          width = "100%",
          rows = 2,
          resize = "vertical"
        ),
        actionButton(
          ns("send_btn"),
          "Enviar",
          class = "btn-primary send-btn"
        )
      ),
      
      div(
        class = "input-info",
        span("Máximo 1000 caracteres")
      )
    )
  )
}

# Servidor del módulo de chat
chat_server <- function(id, user_email, claude_api) {
  moduleServer(id, function(input, output, session) {
    
    # Variables reactivas
    values <- reactiveValues(
      messages = list(),
      conversation_history = list()
    )
    
    # Mostrar email del usuario en el header
    output$user_email_display <- renderText({
      paste("Hola,", user_email())
    })
    
    # Mostrar el panel de chat cuando el usuario está autenticado
    observe({
      if (!is.null(user_email()) && user_email() != "") {
        shinyjs::show("chat_panel")
      } else {
        shinyjs::hide("chat_panel")
      }
    })
    
    # Manejar envío de mensaje
    observeEvent(input$send_btn, {
      send_message()
    })
    
    # Permitir envío con Enter (Shift+Enter para nueva línea)
    observeEvent(input$user_input, {
      # JavaScript para manejar Enter vs Shift+Enter se define en CSS/JS
    })
    
    # Manejar consultas predefinidas
    observeEvent(input$q1, {
      updateTextAreaInput(session, "user_input", value = "¿Cómo cargo un archivo CSV en R?")
    })
    
    observeEvent(input$q2, {
      updateTextAreaInput(session, "user_input", value = "¿Qué es el pipe %>% y cómo se usa?")
    })
    
    observeEvent(input$q3, {
      updateTextAreaInput(session, "user_input", value = "Me aparece el error 'object not found' en R. ¿Qué significa?")
    })
    
    # Función para enviar mensaje
    send_message <- function() {
      user_message <- trimws(input$user_input)
      
      # Validaciones
      if (user_message == "") return()
      
      if (nchar(user_message) > 1000) {
        show_error("El mensaje es muy largo. Máximo 1000 caracteres.")
        return()
      }
      
      # Limpiar input
      updateTextAreaInput(session, "user_input", value = "")
      
      # Agregar mensaje del usuario a la conversación
      add_user_message(user_message)
      
      # Mostrar indicador de typing
      shinyjs::show("typing_indicator")
      
      # Obtener respuesta del asistente
      get_bot_response(user_message)
    }
    
    # Función para agregar mensaje del usuario
    add_user_message <- function(message) {
      user_msg <- div(
        class = "message user-message",
        div(class = "message-content", message),
        div(class = "message-time", format(Sys.time(), "%H:%M"))
      )
      
      # Agregar a la lista de mensajes
      values$messages <- append(values$messages, list(user_msg))
      
      # Actualizar UI
      update_messages_ui()
    }
    
    # Función para agregar mensaje del bot
    add_bot_message <- function(message) {
      bot_msg <- div(
        class = "message bot-message",
        div(class = "message-content", HTML(message)),
        div(class = "message-time", format(Sys.time(), "%H:%M"))
      )
      
      # Agregar a la lista de mensajes
      values$messages <- append(values$messages, list(bot_msg))
      
      # Ocultar indicador de typing
      shinyjs::hide("typing_indicator")
      
      # Actualizar UI
      update_messages_ui()
    }
    
    # Función para obtener respuesta del bot
    get_bot_response <- function(user_message) {
      
      # Agregar mensaje a historial para mantener contexto
      values$conversation_history <- append(
        values$conversation_history,
        list(list(role = "user", content = user_message))
      )
      
      # Llamar a la API de Claude
      tryCatch({
        response <- claude_api$get_response(user_message, values$conversation_history)
        
        # Agregar respuesta al historial
        values$conversation_history <- append(
          values$conversation_history,
          list(list(role = "assistant", content = response))
        )
        
        # Mostrar respuesta
        add_bot_message(response)
        
      }, error = function(e) {
        shinyjs::hide("typing_indicator")
        add_bot_message(paste("Disculpá, tuve un problema técnico:", e$message,
                             "Por favor, intentá de nuevo en unos segundos."))
      })
    }
    
    # Función para actualizar la UI de mensajes
    update_messages_ui <- function() {
      output$messages_output <- renderUI({
        values$messages
      })
      
      # Scroll automático al final
      session$sendCustomMessage("scrollToBottom", "messages_container")
    }
    
    # Función para mostrar errores
    show_error <- function(message) {
      showNotification(
        message,
        type = "error",
        duration = 3
      )
    }
    
    # Función para limpiar historial
    clear_history <- function() {
      values$messages <- list()
      values$conversation_history <- list()
      update_messages_ui()
    }
    
    # Retornar funciones públicas
    return(
      list(
        clear_history = clear_history
      )
    )
  })
}