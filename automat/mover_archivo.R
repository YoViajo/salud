# Definir los directorios
origen <- "D:/Users/earmijo/Downloads/"
destino <- work_dir  # Asegúrate de que 'work_dir' esté definido

# Obtener una lista de todos los archivos Excel en el directorio origen que comienzan con 'ConsolidadoAdscripcion_'
archivos <- list.files(path = origen, pattern = "^ConsolidadoAdscripcion_.*\\.xlsx$", full.names = TRUE)

# Mover cada archivo al directorio destino
for (archivo in archivos) {
  # Genera el nuevo nombre del archivo
  nuevo_nombre <- file.path(destino, basename(archivo))
  
  # Mover el archivo
  file.rename(from = archivo, to = nuevo_nombre)
}
