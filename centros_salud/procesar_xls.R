# Instala e importa las bibliotecas necesarias
#install.packages("readxl")
#install.packages("dplyr")
#install.packages("stringr")
library(readxl)
library(dplyr)
library(stringr)

# Define el path del archivo
path <- "INFORMACION  REDES ed.xlsx"

# Lee las primeras cuatro hojas y las almacena en una lista de dataframes
list_of_dfs <- lapply(1:4, function(i) {
  df <- read_excel(path, sheet = i)
  
  # Excluir una columna
  df <- df[ , !(names(df) %in% c("cs_servicios"))]
  
  # Convierte cs_telefono a character para asegurar consistencia
  df$cs_telefono <- as.character(df$cs_telefono)
  
  # Reemplaza los NA con un valor temporal
  df$cs_integral[is.na(df$cs_integral)] <- "no"
  
  # Convierte cs_integral a booleano, tratando NA como FALSE
  df$cs_integral <- ifelse(df$cs_integral == "sí", TRUE, FALSE)
  
  # Divide cs_georef en dos columnas y convierte a numérico
  coords <- strsplit(as.character(df$cs_georef), split = ",", fixed = TRUE)
  df$lat <- sapply(coords, function(x) as.numeric(x[1]))
  df$lon <- sapply(coords, function(x) as.numeric(x[2]))
  
  # Obtén los nombres de todas las columnas hasta cs_georef
  cols_until_cs_georef <- names(df)[1:which(names(df) == "cs_georef")]
  
  # Reordenar las columnas para que lat y lon queden después de cs_georef
  df <- df %>% select(all_of(c(cols_until_cs_georef, "lat", "lon")), everything())
  
  # Verifica y limpia la columna cs_telefono
  if ("cs_telefono" %in% names(df)) {
    df$cs_telefono <- as.character(df$cs_telefono)
    df$cs_telefono <- str_replace_all(df$cs_telefono, "3-", "")
    df$cs_telefono <- sapply(strsplit(df$cs_telefono, "\\s|-"), function(x) {
      valid_substrings <- x[nchar(gsub("[^0-9]", "", x)) >= 7]
      paste0(valid_substrings, collapse = " - ")
    })
  } else {
    warning("La columna 'cs_telefono' no se encuentra en el dataframe.")
  }
  
  # Ajusta el contenido de cs_aniversario y director_nombre
  if ("cs_aniversario" %in% names(df)) {
    df$cs_aniversario <- str_to_title(as.character(df$cs_aniversario))
    df$cs_aniversario <- str_replace_all(df$cs_aniversario, "\\bDe\\b", "de")
    
    meses <- c("\\bEne\\b" = "Enero", "\\bFeb\\b" = "Febrero", "\\bMar\\b" = "Marzo", "\\bAbr\\b" = "Abril", 
               "\\bMay\\b" = "Mayo", "\\bJun\\b" = "Junio", "\\bJul\\b" = "Julio", "\\bAgo\\b" = "Agosto", 
               "\\bSep\\b" = "Septiembre", "\\bSept\\b" = "Septiembre", "\\bOct\\b" = "Octubre", 
               "\\bNov\\b" = "Noviembre", "\\bDic\\b" = "Diciembre")
    df$cs_aniversario <- str_replace_all(df$cs_aniversario, meses)
  }
  
  if ("director_nombre" %in% names(df)) {
    df$director_nombre <- str_to_title(as.character(df$director_nombre))
    df$director_nombre <- str_replace_all(df$director_nombre, "\\.(?! )", ". ")
  }
  
  return(df) # Esta línea se ha movido aquí, dentro del bloque de código de la función
})

# Combina los dataframes de la lista en un solo dataframe
combined_df <- bind_rows(list_of_dfs)

# Guarda el dataframe combinado como un archivo CSV
write.csv(combined_df, "tab_centros_salud_redes.csv", row.names = FALSE)
