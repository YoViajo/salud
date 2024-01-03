######################################
#  Envía un mensaje por Outlook para 
#  anunciar la disponibilidad del    
#  Informe de adscripción SUS del    
#  mes pasado                        
#  Requiere tener iniciada una
#  sesión de MS Outlook
#                                    
#  Desarrollado por:                 
#  Eric Armijo  (rcrmj@hotmail.com)  
######################################


# Instala y carga las bibliotecas necesarias.
# install.packages("RDCOMClient", repos = "http://www.omegahat.net/R")
# install.packages("lubridate")
library(RDCOMClient)
library(lubridate)

# Establece la localidad en español.
Sys.setlocale("LC_TIME", "Spanish")

# Obtén el mes pasado y el año actual.
fecha_pasada <- Sys.Date() %m-% months(1)
mes_pasado <- format(fecha_pasada, "%B")
ano_actual <- year(fecha_pasada)

# Crea un objeto de Outlook.
OutApp <- COMCreate("Outlook.Application")

# Crea un nuevo correo electrónico.
OutMail = OutApp$CreateItem(0)

# Configura los detalles del correo electrónico.
OutMail[["To"]] = "szcadima@gmsantacruz.gob.bo"
OutMail[["Subject"]] = paste("Informe de adscripción SUS para el municipio de Santa Cruz – ", mes_pasado, ano_actual, sep = " ")
OutMail[["Body"]] = paste("Estimada Ing.,\n\nYa está disponible el “Informe de adscripción SUS para el municipio de Santa Cruz – ", mes_pasado, ano_actual, "”. El archivo correspondiente, obtenido a partir de datos proporcionados por el sitio web SUS, ha sido copiado al directorio compartido: https://drive.google.com/drive/folders/1Yeh-tUvunFFImb_MfdwQxvBFieDU4tr2?usp=drive_link\n\nAtte.")

# Envía el correo electrónico.
resultado_envio <- OutMail$Send()

if (resultado_envio) {
  # Si el envío fue exitoso
  print("El correo electrónico fue enviado exitosamente.")
} else {
  # Si hubo algún problema y el envío no se realizó correctamente
  print("Hubo un problema al enviar el correo electrónico. Por favor, verifica la configuración.")
}

