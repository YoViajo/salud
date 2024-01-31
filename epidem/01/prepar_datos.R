

install.packages("DataExplorer")

library(DataExplorer)
library(tidyverse)
library(ggplot2)

# Cargar datos nacionales y filtrar para el municipio de Santa Cruz
covid_mun <- read.csv("/home/yoviajo/Documentos/lab/bd/dat/salud/consolidado_covid_19-mun_se.csv")
covid_scz <- covid_mun %>% filter(Codigo == 70101)
colnames(covid_scz) <- c('dpt_cod', 'dpt_nom', 'mun_cod', 'mun_nom', 'sem_epi', 'confirmados', 'activos', 'fallecidos', 'recuperados')

# EDA
str(covid_scz)
create_report(covid_scz)

# GRÁFICOS

# Gráfico de dispersión básico
p1 <- ggplot(covid_scz, aes(x=sem_epi, y=confirmados)) + geom_point()
p2 <- ggplot(covid_scz, aes(x=sem_epi, y=activos)) + geom_point()
p3 <- ggplot(covid_scz, aes(x=sem_epi, y=fallecidos)) + geom_point()
p4 <- ggplot(covid_scz, aes(x=sem_epi, y=recuperados)) + geom_point()

# Gráfico de dispersión con línea de regresión
p1 <- ggplot(covid_scz, aes(x=sem_epi, y=confirmados)) + geom_point() + geom_smooth(method="auto", se=TRUE, fullrange=FALSE, level=0.95)
p2 <- ggplot(covid_scz, aes(x=sem_epi, y=activos)) + geom_point() + geom_smooth(method="auto", se=TRUE, fullrange=FALSE, level=0.95)
p3 <- ggplot(covid_scz, aes(x=sem_epi, y=fallecidos)) + geom_point() + geom_smooth(method="auto", se=TRUE, fullrange=FALSE, level=0.95)
p4 <- ggplot(covid_scz, aes(x=sem_epi, y=recuperados)) + geom_point() + geom_smooth(method="auto", se=TRUE, fullrange=FALSE, level=0.95)

# Ajustar etiquetas
p1 + ggtitle("Municipio de Santa Cruz \n Casos confirmados") + xlab("Semana epidemiológica") + ylab("# confirmados")
p2 + ggtitle("Municipio de Santa Cruz \n Casos activos") + xlab("Semana epidemiológica") + ylab("# activos")
p3 + ggtitle("Municipio de Santa Cruz \n Casos fallecidos") + xlab("Semana epidemiológica") + ylab("# fallecidos")
p4 + ggtitle("Municipio de Santa Cruz \n Casos recuperados") + xlab("Semana epidemiológica") + ylab("# recuperados")
