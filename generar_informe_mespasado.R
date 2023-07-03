######################################################
#  Procesa el archivo generado por el sistema SUS    
#  (Reportes de Adscripción)                         
#  filtrando para dejar los registros correspondientes
#  al municipio de Santa Cruz de la Sierra, para  
#  el mes pasado     
#  Requiere descargar previamente el archivo SUS
#  (MS Excel) del sitio web https://sus.minsalud.gob.bo/loginS
#                                    
#  Desarrollado por:                 
#  Eric Armijo  (rcrmj@hotmail.com)  
######################################################


# Instala y carga los paquetes readxl, dplyr, lubridate y writexl si aún no lo has hecho
if (!require(readxl)) {
  install.packages("readxl")
  library(readxl)
}

if (!require(dplyr)) {
  install.packages("dplyr")
  library(dplyr)
}

if (!require(lubridate)) {
  install.packages("lubridate")
  library(lubridate)
}

if (!require(writexl)) {
  install.packages("writexl")
  library(writexl)
}

# Obtiene la lista de todos los archivos Excel en el directorio
file_paths <- list.files(pattern = "\\.xlsx$")

# Itera sobre cada archivo
for (file_path in file_paths) {
  # Lee la primera hoja del archivo de Excel en un data.frame, saltando la primera fila
  data <- read_excel(file_path, skip = 1)
  
  
  # Filtra las filas donde el campo "Municipio" es igual a "SANTA CRUZ DE LA SIERRA",
  # y el campo "Gestion" es igual al año actual, y el campo "Mes" es igual al mes pasado
  data <- filter(data, Municipio == "SANTA CRUZ DE LA SIERRA", Gestion == current_year, Mes == last_month)
  
  
  # Guarda el data.frame resultante en un nuevo archivo de Excel
  write_xlsx(data, file_name)
}


