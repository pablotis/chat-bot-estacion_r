# Integración con API de Claude
# Este archivo contiene las funciones para comunicarse con la API de Anthropic Claude

library(httr2)
library(jsonlite)

# Clase para manejar la API de Claude
ClaudeAPI <- R6::R6Class(
  "ClaudeAPI",
  
  public = list(
    api_key = NULL,
    base_url = "https://api.anthropic.com/v1/messages",
    system_prompt = NULL,
    
    # Constructor
    initialize = function(api_key = NULL) {
      self$api_key <- api_key %||% Sys.getenv("ANTHROPIC_API_KEY")
      
      if (self$api_key == "" || is.null(self$api_key)) {
        stop("API key de Anthropic no encontrada. Configurá ANTHROPIC_API_KEY en .Renviron")
      }
      
      # Configurar el prompt del sistema según especificaciones del proyecto
      self$system_prompt <- self$get_system_prompt()
    },
    
    # Obtener respuesta de Claude
    get_response = function(user_message, conversation_history = list()) {
      
      # Validar que la consulta sea sobre R
      if (!self$is_r_related(user_message)) {
        return("Hola! Soy un asistente especializado en R. Por favor, haceme consultas relacionadas con programación en R, análisis de datos, o estadística usando R. ¿En qué puedo ayudarte con R específicamente?")
      }
      
      # Preparar mensajes para la API
      messages <- self$prepare_messages(user_message, conversation_history)
      
      # Realizar la petición a la API
      response <- self$call_api(messages)
      
      # Procesar y retornar la respuesta
      return(self$process_response(response))
    },
    
    # Validar si la consulta es sobre R
    is_r_related = function(message) {
      r_keywords <- c(
        "r programming", "rstudio", "tidyverse", "ggplot", "dplyr",
        "data.frame", "tibble", "pipe", "%>%", "function", "variable",
        "error", "warning", "package", "library", "install.packages",
        "read.csv", "write.csv", "plot", "graph", "visualization",
        "statistical", "analysis", "dataset", "vector", "matrix",
        "factor", "numeric", "character", "logical", "missing",
        "na", "null", "summary", "str", "head", "tail", "dim",
        "shiny", "rmarkdown", "knitr", "devtools"
      )
      
      # Convertir a minúsculas para comparación
      message_lower <- tolower(message)
      
      # Buscar palabras clave de R
      r_detected <- any(sapply(r_keywords, function(keyword) {
        grepl(keyword, message_lower, fixed = TRUE)
      }))
      
      # También permitir si menciona errores comunes de R
      error_patterns <- c(
        "object.*not found", "could not find function", "non-numeric argument",
        "subscript out of bounds", "cannot open file", "package.*not available"
      )
      
      error_detected <- any(sapply(error_patterns, function(pattern) {
        grepl(pattern, message_lower)
      }))
      
      # Si no detecta R específicamente, pero es una pregunta genérica de programación, 
      # la permitimos ya que podría ser sobre R
      generic_programming <- grepl("(como|cómo).*(hacer|crear|generar|cargar|importar|exportar|instalar)", message_lower) ||
                           grepl("(que|qué).*(es|significa)", message_lower) ||
                           grepl("(error|problema|issue)", message_lower) ||
                           grepl("(ayuda|help)", message_lower)
      
      return(r_detected || error_detected || generic_programming)
    },
    
    # Preparar mensajes para la API
    prepare_messages = function(user_message, conversation_history) {
      messages <- list()
      
      # Agregar historial de conversación (mantener solo las últimas 10 interacciones)
      if (length(conversation_history) > 20) {
        conversation_history <- tail(conversation_history, 20)
      }
      
      # Convertir historial a formato de la API
      for (msg in conversation_history) {
        if (length(msg) >= 2 && !is.null(msg$role) && !is.null(msg$content)) {
          messages <- append(messages, list(list(
            role = msg$role,
            content = msg$content
          )))
        }
      }
      
      # Agregar mensaje actual del usuario
      messages <- append(messages, list(list(
        role = "user",
        content = user_message
      )))
      
      return(messages)
    },
    
    # Realizar llamada a la API
    call_api = function(messages) {
      
      body <- list(
        model = "claude-3-sonnet-20240229",
        max_tokens = 1000,
        system = self$system_prompt,
        messages = messages
      )
      
      tryCatch({
        response <- request(self$base_url) %>%
          req_headers(
            "x-api-key" = self$api_key,
            "Content-Type" = "application/json",
            "anthropic-version" = "2023-06-01"
          ) %>%
          req_body_json(body) %>%
          req_timeout(30) %>%
          req_perform()
        
        return(resp_body_json(response))
        
      }, error = function(e) {
        if (grepl("timeout", e$message, ignore.case = TRUE)) {
          stop("Timeout: La respuesta tardó demasiado. Intentá con una consulta más simple.")
        } else if (grepl("401", e$message)) {
          stop("Error de autenticación: Verificá tu API key de Anthropic.")
        } else if (grepl("429", e$message)) {
          stop("Demasiadas consultas: Esperá unos segundos antes de intentar de nuevo.")
        } else {
          stop(paste("Error al comunicarse con Claude:", e$message))
        }
      })
    },
    
    # Procesar respuesta de la API
    process_response = function(response) {
      if (is.null(response) || is.null(response$content)) {
        return("Disculpá, no pude generar una respuesta. Por favor, intentá de nuevo.")
      }
      
      # Extraer el texto de la respuesta
      if (length(response$content) > 0 && !is.null(response$content[[1]]$text)) {
        content <- response$content[[1]]$text
        
        # Procesar el contenido para mejorar la presentación
        content <- self$format_response(content)
        
        return(content)
      } else {
        return("Disculpá, hubo un problema al procesar la respuesta. Intentá de nuevo.")
      }
    },
    
    # Formatear la respuesta para mejor presentación
    format_response = function(content) {
      # Convertir código R a bloques con sintaxis highlighting
      content <- gsub("```r\\n([^`]+)```", "<pre class='r-code'><code>\\1</code></pre>", content)
      content <- gsub("```R\\n([^`]+)```", "<pre class='r-code'><code>\\1</code></pre>", content)
      content <- gsub("```\\n([^`]+)```", "<pre class='code'><code>\\1</code></pre>", content)
      
      # Convertir código inline
      content <- gsub("`([^`]+)`", "<code class='inline-code'>\\1</code>", content)
      
      # Convertir saltos de línea a <br>
      content <- gsub("\\n", "<br>", content)
      
      return(content)
    },
    
    # Obtener el prompt del sistema
    get_system_prompt = function() {
      return("Sos un asistente especializado en R para estudiantes de Estación R. Tu rol es ayudar a estudiantes principiantes e intermedios con sus consultas sobre programación en R.

REGLAS FUNDAMENTALES:
1. Respondé SIEMPRE en español rioplatense, de forma clara y didáctica
2. Si falta contexto mínimo para responder, pedí la información necesaria
3. Mostrá soluciones preferentemente con tidyverse, y cuando sea relevante, incluí el equivalente en base R
4. Proporcioná ejemplos reproducibles cortos con datos de juguete cuando no te proporcionen datos
5. IMPORTANTE: Tu primer intento NO debe ser dar la solución directa, sino ayudar a quien consulta a identificar dónde está el problema. Priorizá el proceso de aprendizaje
6. Si no podés resolver algo, explicá claramente por qué y pedí exactamente lo que necesitás para avanzar
7. NO respondas consultas que no estén relacionadas con R

ENFOQUE PEDAGÓGICO:
- Hacé preguntas guía como '¿Qué error te está mostrando R?' o '¿Podés mostrarme qué intentaste hasta ahora?'
- Explicá el 'por qué' detrás de los errores comunes
- Usá analogías cuando sea útil para explicar conceptos
- Fomentá las buenas prácticas de programación

ESTRUCTURA DE RESPUESTA:
1. Validá que entendés el problema
2. Hacé preguntas para que el estudiante reflexione
3. Si corresponde, mostrá un ejemplo mínimo reproducible
4. Explicá el concepto subyacente
5. Sugerí práctica adicional o variaciones

Mantené siempre un tono amigable y motivador. El objetivo es que aprendan, no solo que resuelvan el problema.")
    }
  )
)

# Función helper para crear una instancia de la API
create_claude_api <- function(api_key = NULL) {
  ClaudeAPI$new(api_key = api_key)
}

# Operador %||% para valores por defecto
`%||%` <- function(x, y) if (is.null(x)) y else x