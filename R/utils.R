# Funciones auxiliares
# Este archivo contiene funciones de utilidad general para la aplicación

library(shiny)

# Función para validar formato de email
is_valid_email <- function(email) {
  if (is.null(email) || is.na(email) || email == "") {
    return(FALSE)
  }
  
  pattern <- "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
  grepl(pattern, email)
}

# Función para limpiar y validar input de usuario
sanitize_user_input <- function(input_text, max_length = 1000) {
  if (is.null(input_text) || is.na(input_text)) {
    return("")
  }
  
  # Remover espacios al inicio y final
  cleaned <- trimws(input_text)
  
  # Limitar longitud
  if (nchar(cleaned) > max_length) {
    cleaned <- substr(cleaned, 1, max_length)
  }
  
  return(cleaned)
}

# Función para formatear tiempo
format_time <- function(time = Sys.time(), format = "%H:%M") {
  format(time, format)
}

# Función para logging (simple)
log_message <- function(message, level = "INFO", user_email = "") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- paste0("[", timestamp, "] ", level, " - ", user_email, " - ", message)
  
  # Por ahora solo imprime en consola
  # En producción se podría escribir a un archivo de log
  cat(log_entry, "\n")
}

# Función para obtener configuración del archivo .Renviron
get_config <- function(key, default = NULL) {
  value <- Sys.getenv(key, unset = "")
  if (value == "" || is.null(value)) {
    return(default)
  }
  return(value)
}

# Función para verificar si todos los paquetes están instalados
check_required_packages <- function() {
  required_packages <- c(
    "shiny", "shinyjs", "DT", "httr2", "jsonlite", 
    "readr", "R6", "shinydashboard"
  )
  
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  
  if (length(missing_packages) > 0) {
    message("Paquetes faltantes detectados. Instalando...")
    install.packages(missing_packages)
    
    # Verificar nuevamente
    still_missing <- missing_packages[!sapply(missing_packages, requireNamespace, quietly = TRUE)]
    
    if (length(still_missing) > 0) {
      stop(paste("No se pudieron instalar los siguientes paquetes:", paste(still_missing, collapse = ", ")))
    } else {
      message("Todos los paquetes fueron instalados exitosamente.")
    }
  } else {
    message("Todos los paquetes requeridos están disponibles.")
  }
}

# Función para crear estructura de directorios si no existe
ensure_directories <- function() {
  dirs <- c("R", "www", "data")
  
  for (dir in dirs) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
      message(paste("Directorio creado:", dir))
    }
  }
}

# Función para validar configuración de la aplicación
validate_app_config <- function() {
  required_env_vars <- c("ANTHROPIC_API_KEY", "APP_SECRET_KEY")
  missing_vars <- character(0)
  
  for (var in required_env_vars) {
    if (Sys.getenv(var, unset = "") == "") {
      missing_vars <- c(missing_vars, var)
    }
  }
  
  if (length(missing_vars) > 0) {
    stop(paste("Variables de entorno faltantes en .Renviron:", 
               paste(missing_vars, collapse = ", ")))
  }
  
  # Verificar que existe el archivo de emails autorizados
  emails_path <- get_config("AUTHORIZED_EMAILS_PATH", "data/authorized_emails.csv")
  if (!file.exists(emails_path)) {
    warning(paste("Archivo de emails autorizados no encontrado:", emails_path,
                  "\nSe creará automáticamente con datos de ejemplo."))
  }
  
  message("Configuración de la aplicación validada exitosamente.")
}

# Función para crear archivo de emails de ejemplo
create_sample_emails <- function(path = "data/authorized_emails.csv") {
  sample_emails <- data.frame(
    email = c(
      "alumno1@ejemplo.com",
      "alumno2@ejemplo.com", 
      "estudiante@universidad.edu",
      "profesor@estacionr.com"
    ),
    nombre = c(
      "Alumno Ejemplo 1",
      "Alumno Ejemplo 2",
      "Estudiante Universitario",
      "Profesor Estación R"
    ),
    activo = c(TRUE, TRUE, TRUE, TRUE),
    fecha_registro = rep(Sys.Date(), 4)
  )
  
  # Crear directorio si no existe
  if (!dir.exists(dirname(path))) {
    dir.create(dirname(path), recursive = TRUE)
  }
  
  readr::write_csv(sample_emails, path)
  message(paste("Archivo de emails de ejemplo creado:", path))
}

# Función para rate limiting simple (en memoria)
RateLimiter <- R6::R6Class(
  "RateLimiter",
  
  public = list(
    requests = NULL,
    max_requests = 60,  # máximo de requests
    time_window = 3600,  # ventana de tiempo en segundos (1 hora)
    
    initialize = function(max_requests = 60, time_window = 3600) {
      self$requests <- list()
      self$max_requests <- max_requests
      self$time_window <- time_window
    },
    
    can_make_request = function(user_id) {
      current_time <- as.numeric(Sys.time())
      
      # Inicializar lista de requests para este usuario si no existe
      if (is.null(self$requests[[user_id]])) {
        self$requests[[user_id]] <- numeric(0)
      }
      
      # Filtrar requests dentro de la ventana de tiempo
      user_requests <- self$requests[[user_id]]
      recent_requests <- user_requests[user_requests > (current_time - self$time_window)]
      self$requests[[user_id]] <- recent_requests
      
      # Verificar si puede hacer más requests
      can_request <- length(recent_requests) < self$max_requests
      
      if (can_request) {
        # Agregar este request a la lista
        self$requests[[user_id]] <- c(self$requests[[user_id]], current_time)
      }
      
      return(can_request)
    }
  )
)