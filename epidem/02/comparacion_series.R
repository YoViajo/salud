library(ggplot2)
library(reshape)
data <- data.frame(time = seq(0, 23), noob = rnorm(24), plus = runif(24), extra = rpois(24, lambda = 1))
Molten <- melt(data, id.vars = "time")
ggplot(Molten, aes(x = time, y = value, colour = variable)) + geom_line()



bo_resid
bo_tiefar

# Agregar atributos al DF de valores (series de tiempo)
bo_df_2 <- merge(bo_resid, bo_tiefar, by = "fecha")
bo_df_3 <- merge(bo_df_2, bo_parq, by = "fecha")
bo_df_4 <- merge(bo_df_3, bo_trab, by = "fecha")
bo_df_5 <- merge(bo_df_4, bo_minrec, by = "fecha")

# Dar formato "melt" a datos
Molten <- melt(bo_df_5, id.vars = "fecha")

# Graficar múltiples series de valores como línea
ggplot(Molten, aes(x = fecha, y = value, colour = variable)) + geom_line()
