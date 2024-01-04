#
# Identifica atrasos y marcados faltantes a partir de registros biométricos Zafiro
#     Procesa todos los días disponibles en el archivo Excel de entrada, que necesita definirse
#     Distingue registros en horarios continuo y discontinuo
#     Calcula el tiempo en minutos de atrasos en entradas: atraso por día y sumatoria
#     Identifica días donde faltó algún registro de entrada o salida
#	  Requiere un archivo Excel de entrada y dos subdirectorios ("entrada" y "salida").
#     Colocar el archivo Excel en directorio "entrada"
#     Devuelve un archivo Excel
#

# Inicializar
rm(list = ls())
graphics.off()

# Importar librerías
library(readxl)
library(lubridate)
library(hms)
library(dplyr)
library(writexl)

# Cambiar el directorio de trabajo
setwd("D:/Users/earmijo/Documents/lab/analitica/06/")

if (!dir.exists("entrada")) dir.create("entrada")
if (!dir.exists("salida")) dir.create("salida")

# Leer el archivo desde la hoja especificada
archivo <- "entrada/zafiro_biom_19nov-20dic2023.xlsx"
datos <- read_excel(archivo, sheet = "BD")

# Convertir la columna de FECHA a tipo Date
datos$FECHA <- as.Date(datos$FECHA)

# Convertir a formato de hora
datos$HORA <- format(as.POSIXct(datos$HORA, origin="1899-12-31"), "%H:%M:%S")
datos$HORA_hms <- as_hms(datos$HORA)

# Clasificar tipo de horario
datos <- datos %>%
  group_by(FECHA) %>%
  mutate(
    tipo_horario = ifelse(any(HORA_hms >= as_hms("11:00:00") & HORA_hms <= as_hms("13:00:00")), "discontinuo", "continuo")
  ) %>%
  ungroup()

# Identificar si el registro es ingreso o salida
datos <- datos %>%
  mutate(
    registro = case_when(
      tipo_horario == "continuo" & hour(HORA_hms) < 12 ~ "ingreso",
      tipo_horario == "discontinuo" & (HORA_hms >= as_hms("00:00:00") & HORA_hms < as_hms("12:30:00")) ~ "ingreso",
      tipo_horario == "discontinuo" & (HORA_hms >= as_hms("12:30:00") & HORA_hms < as_hms("14:00:00")) ~ "salida",
      tipo_horario == "discontinuo" & (HORA_hms >= as_hms("14:00:00") & HORA_hms <= as_hms("14:30:00")) ~ "ingreso",
      tipo_horario == "discontinuo" & (HORA_hms > as_hms("14:30:00") & HORA_hms < as_hms("18:30:00")) ~ "ingreso",
      tipo_horario == "discontinuo" & (HORA_hms >= as_hms("18:30:00")) ~ "salida",
      TRUE ~ "salida"
    )
  )

# Identificar si hubo atraso en el ingreso
datos <- datos %>%
  mutate(
    obs = case_when(
      tipo_horario == "continuo" & registro == "ingreso" & HORA_hms > as_hms("08:00:00") ~ "atrasado",
      tipo_horario == "discontinuo" & registro == "ingreso" & HORA_hms > as_hms("08:30:00") & HORA_hms < as_hms("12:30:00") ~ "atrasado",
      tipo_horario == "discontinuo" & registro == "ingreso" & HORA_hms > as_hms("14:30:00") ~ "atrasado",
      TRUE ~ "normal"
    )
  )

# Calcular el tiempo de atraso (en minutos) solo para registros atrasados
datos <- datos %>%
  mutate(
    t_atraso = ifelse(obs == "atrasado",
                      as.numeric(difftime(HORA_hms, 
                                          ifelse(tipo_horario == "continuo", as_hms("08:00:00"),
                                                 ifelse(HORA_hms <= as_hms("12:30:00"), as_hms("08:30:00"), as_hms("14:30:00"))), 
                                          units = "mins")), 
                      NA)
  )

# Contar entradas y salidas por día
conteo_eventos <- datos %>%
  group_by(FECHA) %>%
  summarise(
    num_ingresos = sum(registro == "ingreso"),
    num_salidas = sum(registro == "salida")
  ) %>%
  ungroup()

# Identificar días con eventos faltantes
conteo_eventos <- conteo_eventos %>%
  mutate(
    evento_faltante = case_when(
      num_ingresos == 0 | num_salidas == 0 ~ "Sí",
      TRUE ~ "No"
    )
  )

# Crear un data frame con los días que faltan eventos
dias_evento_faltante <- conteo_eventos %>%
  filter(evento_faltante == "Sí")

# Crear un data frame para atraso por día
atraso_por_dia <- datos %>%
  group_by(FECHA) %>%
  summarise(total_atraso_dia = sum(t_atraso, na.rm = TRUE)) %>%
  ungroup()

# Convertir la columna de FECHA a tipo Date para atraso_por_dia
atraso_por_dia$FECHA <- as.Date(atraso_por_dia$FECHA)

# Crear un data frame con la información final de tiempo de atraso
fecha_inicio <- min(datos$FECHA, na.rm = TRUE)
fecha_final <- max(datos$FECHA, na.rm = TRUE)
fecha_inicio_date <- as.Date(fecha_inicio, format="%Y-%m-%d")
fecha_final_date <- as.Date(fecha_final, format="%Y-%m-%d")
num_dias <- as.numeric(difftime(fecha_final_date, fecha_inicio_date, units = "days"))
total_atraso <- sum(datos$t_atraso, na.rm = TRUE)

informacion_final <- data.frame(
  fecha_inicio = fecha_inicio,
  fecha_final = fecha_final,
  num_dias = num_dias,
  total_atraso = total_atraso
)

# Generar el nombre del archivo de salida basado en las fechas
nombre_archivo_temp <- paste0("bd_marcado_biom_", format(fecha_inicio_date, "%d%b"), "-", format(fecha_final_date, "%d%b%Y"))
nombre_archivo_limpio <- gsub("\\.", "", nombre_archivo_temp)  # Eliminar el punto si existe
nombre_archivo <- paste0("salida/", nombre_archivo_limpio, ".xlsx") # Añadir la extensión .xlsx

# Guardar todo en un archivo Excel
write_xlsx(list("Datos" = datos, "Atraso por día" = atraso_por_dia, "Información Final" = informacion_final, "Días con Evento Faltante" = dias_evento_faltante), nombre_archivo)
