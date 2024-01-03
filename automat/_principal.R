#######################################################
# Script mensual "Informe Adscripciones SUS":
#   - prepara archivo mensual (mes pasado)
#   - copia el nuevo informe a carpeta compartida
#   - envía anuncio por correo-e a destinataria
#
#  Desarrollado por: Eric Armijo (rcrmj@hotmail.com)
#######################################################

if (!require(lubridate)) {
  install.packages("lubridate")
  library(lubridate)
}


# Calcula el año y el mes actual
current_year <- as.integer(format(Sys.Date(), "%Y"))
last_month <- month(Sys.Date()) - 1
if (last_month == 0) {
  last_month <- 12
  current_year <- current_year - 1
}


# Establece la carpeta de trabajo
ruta_base <- "D:/Users/earmijo/Documents/sist/SUS/informes"
last_month_str <- sprintf("%02d", last_month)
work_dir <- paste(ruta_base, last_month_str, sep = "/")

if (!dir.exists(work_dir)) {
  dir.create(work_dir, recursive = TRUE)
}
setwd(work_dir)

## Mover el archivo descargado del SUS a la carpeta de trabajo (mes pasado)
source('D:/Users/earmijo/Documents/sist/SUS/informes/lab/mover_archivo.R')


# Forma el nombre del archivo final
file_name <- paste0("SUS-ConsolidadoAdscripcion-municScz_", current_year, "-", sprintf("%02d", last_month), ".xlsx")


## Procesar el archivo SUS de adscripciones ##
source('D:/Usuarios/earmijo/Documents/sist/SUS/informes/lab/generar_informe_mespasado.R')


## Copiar el archivo nuevo en la carpeta compartida ##

# Define la ruta de destino
dest_dir <- "W:/SUS_seguros/"

# Crea la ruta completa del archivo fuente y del archivo de destino
source_file <- paste0(work_dir, "/", file_name)
dest_file <- paste0(dest_dir, file_name)

# Copia el archivo a la carpeta de destino
if (file.copy(source_file, dest_file, overwrite = TRUE)) {
  if (file.exists(dest_file)) {
    print("El archivo ya existía y ha sido sobrescrito exitosamente.")
  } else {
    print("La copia de archivos fue exitosa.")
  }
} else {
  warning("Advertencia: La copia de archivos no fue exitosa.")
}


## Anunciar por correo-e la disponibilidad del archivo nuevo ##
source('D:/Usuarios/earmijo/Documents/sist/SUS/informes/lab/enviar_correoe.R')
