library(lubridate)
library(dplyr)
library(ggplot2)
library(plotly)
library(TSstudio)
library(xts)

# Inicializar
# Clear plots
if(!is.null(dev.list())) dev.off()
# Clear console
cat("\014") 
# Clean workspace
rm(list=ls())


# Cargar datos
getwd()
setwd("/home/yoviajo/Documentos/lab/proy/google/mobility/dat/")

datos_2020 <- read.csv("2020_BO_Region_Mobility_Report.csv")
class(datos_2020)

datos_2021 <- read.csv("2021_BO_Region_Mobility_Report.csv")
datos_2022 <- read.csv("2022_BO_Region_Mobility_Report.csv")

# Filtrar registros subnacionales
bo_datos_2020 <- subset(datos_2020, sub_region_1 == "")
bo_datos_2021 <- subset(datos_2021, sub_region_1 == "")
bo_datos_2022 <- subset(datos_2022, sub_region_1 == "")

str(bo_datos_2020)

# Ajustar campo fecha
fecha <- ymd(bo_datos_2020$date)
bo_datos_2020 <- cbind(bo_datos_2020, fecha)
str(bo_datos_2020)


fecha <- ymd(bo_datos_2021$date)
bo_datos_2021 <- cbind(bo_datos_2021, fecha)
str(bo_datos_2021)

fecha <- ymd(bo_datos_2022$date)
bo_datos_2022 <- cbind(bo_datos_2022, fecha)
str(bo_datos_2022)

# Gráfico básico, por año
p <- ggplot(bo_datos_2020, aes(x=fecha, y=retail_and_recreation_percent_change_from_baseline)) +
  geom_line() + 
  xlab("")
p


p <- ggplot(bo_datos_2021, aes(x=fecha, y=retail_and_recreation_percent_change_from_baseline)) +
  geom_line() + 
  xlab("")
p


p <- ggplot(bo_datos_2022, aes(x=fecha, y=retail_and_recreation_percent_change_from_baseline)) +
  geom_line() + 
  xlab("")
p

## COMERCIO MINORISTA Y ACTIVIDADES RECREATIVAS ##

# Armar DF específicos de un atributo por año y combinarlas
minrec_20 <- data.frame(fecha = bo_datos_2020$fecha, minrec = bo_datos_2020$retail_and_recreation_percent_change_from_baseline)
minrec_21 <- data.frame(fecha = bo_datos_2021$fecha, minrec = bo_datos_2021$retail_and_recreation_percent_change_from_baseline)
minrec_22 <- data.frame(fecha = bo_datos_2022$fecha, minrec = bo_datos_2022$retail_and_recreation_percent_change_from_baseline)
bo_minrec <- rbind(minrec_20, minrec_21, minrec_22)

# Graficar serie 2020-2022
p <- ggplot(bo_minrec, aes(x=fecha, y=minrec)) +
  geom_line() + 
  xlab("")
p


## TIENDAS DE COMESTIBLES Y FARMACIAS ##

# Armar DF nacional
tiefar_20 <- data.frame(fecha = bo_datos_2020$fecha, tiefar = bo_datos_2020$grocery_and_pharmacy_percent_change_from_baseline)
tiefar_21 <- data.frame(fecha = bo_datos_2021$fecha, tiefar = bo_datos_2021$grocery_and_pharmacy_percent_change_from_baseline)
tiefar_22 <- data.frame(fecha = bo_datos_2022$fecha, tiefar = bo_datos_2022$grocery_and_pharmacy_percent_change_from_baseline)
bo_tiefar <- rbind(tiefar_20, tiefar_21, tiefar_22)

# Graficar serie 2020-2022
p <- ggplot(bo_tiefar, aes(x=fecha, y=tiefar)) +
  geom_line() + 
  xlab("")
p


# Convertir DF a serie de tiempo (con columna fecha)
class(bo_tiefar)
bo_tiefar
str(bo_tiefar)
bo_tiefar_st <- xts(bo_tiefar$tiefar, bo_tiefar$fecha)
bo_tiefar_st
is.xts(bo_tiefar_st) 

# Graficar serie 2020-2022
ts_info(bo_tiefar_st)
ts_plot(bo_tiefar_st)



## PARQUES ##

# Armar DF nacional
parq_20 <- data.frame(fecha = bo_datos_2020$fecha, parq = bo_datos_2020$parks_percent_change_from_baseline)
parq_21 <- data.frame(fecha = bo_datos_2021$fecha, parq = bo_datos_2021$parks_percent_change_from_baseline)
parq_22 <- data.frame(fecha = bo_datos_2022$fecha, parq = bo_datos_2022$parks_percent_change_from_baseline)
bo_parq <- rbind(parq_20, parq_21, parq_22)

# Graficar serie 2020-2022
p <- ggplot(bo_parq, aes(x=fecha, y=parq)) +
  geom_line() + 
  xlab("")
p


# Convertir DF a serie de tiempo (con columna fecha)
class(bo_parq)
bo_parq
str(bo_parq)
bo_parq_st <- xts(bo_parq$parq, bo_parq$fecha)
bo_parq_st
is.xts(bo_parq_st) 

# Graficar serie 2020-2022
ts_info(bo_parq_st)
ts_plot(bo_parq_st)



## LUGARES DE TRABAJO ##

# Armar DF nacional
trab_20 <- data.frame(fecha = bo_datos_2020$fecha, trab = bo_datos_2020$workplaces_percent_change_from_baseline)
trab_21 <- data.frame(fecha = bo_datos_2021$fecha, trab = bo_datos_2021$workplaces_percent_change_from_baseline)
trab_22 <- data.frame(fecha = bo_datos_2022$fecha, trab = bo_datos_2022$workplaces_percent_change_from_baseline)
bo_trab <- rbind(trab_20, trab_21, trab_22)

# Graficar serie 2020-2022
p <- ggplot(bo_trab, aes(x=fecha, y=trab)) +
  geom_line() + 
  xlab("")
p


# Convertir DF a serie de tiempo (con columna fecha)
class(bo_trab)
bo_trab
str(bo_trab)
bo_trab_st <- xts(bo_trab$trab, bo_parq$fecha)
bo_trab_st
is.xts(bo_trab_st) 

# Graficar serie 2020-2022
ts_info(bo_trab_st)
ts_plot(bo_trab_st)


## RESIDENCIAL ##

# Armar DF nacional
resid_20 <- data.frame(fecha = bo_datos_2020$fecha, resid = bo_datos_2020$residential_percent_change_from_baseline)
resid_21 <- data.frame(fecha = bo_datos_2021$fecha, resid = bo_datos_2021$residential_percent_change_from_baseline)
resid_22 <- data.frame(fecha = bo_datos_2022$fecha, resid = bo_datos_2022$residential_percent_change_from_baseline)
bo_resid <- rbind(resid_20, resid_21, resid_22)

# Graficar serie 2020-2022
p <- ggplot(bo_resid, aes(x=fecha, y=resid)) +
  geom_line() + 
  xlab("")
p


# Convertir DF a serie de tiempo (con columna fecha)
class(bo_resid)
bo_resid
str(bo_resid)
bo_resid_st <- xts(bo_resid$resid, bo_resid$fecha)
bo_resid_st
is.xts(bo_resid_st) 

# Graficar serie 2020-2022
ts_info(bo_resid_st)
ts_plot(bo_resid_st)

