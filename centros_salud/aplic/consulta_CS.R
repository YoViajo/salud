#################
#  Aplicación web para consulta
#  de información general de  
#  Centros de salud del Municipio de
#  Santa Cruz de la Sierra, Bolivia
#
#  Desarollo: Eric Armijo, responsable de sistemas SMS
#################

library(shiny)
library(DT)
library(leaflet)

ui <- fluidPage(
  titlePanel(
    "Información de Centros de Salud",
    windowTitle = "Información de Centros de Salud"
  ),
  tabsetPanel(
    tabPanel("Consulta por Red de Salud",
             sidebarLayout(
               sidebarPanel(
                 selectInput("red_salud", "Red de Salud", choices = NULL)
               ),
               mainPanel(
                 DTOutput("table_red")
               )
             )
    ),
    tabPanel("Consulta por Centro de Salud",
             sidebarLayout(
               sidebarPanel(
                 textInput("centro_salud", "Nombre del Centro de Salud"),
                 actionButton("do_cs", "Realizar Consulta")
               ),
               mainPanel(
                 DTOutput("table_cs")
               )
             )
    )
  ),
  tags$head(
    tags$style(
      HTML(
        "#logo {
          position: fixed;
          bottom: 0;
          left: 20px;
          width: 100px;
          z-index: 100;
        }"
      )
    )
  ),
  tags$img(src = 'logo_sms.png', id = 'logo')
)

server <- function(input, output, session) {
  
  df <- read.csv("todos_centros_salud_actualizado.csv", stringsAsFactors = FALSE)
  df <- df[df$activo == "sí", ]
  
  updateSelectInput(session, "red_salud", choices = c("", sort(unique(df$red_salud))))
  
  output$table_red <- renderDT({
    req(input$red_salud)
    dt <- df
    if (!is.null(input$red_salud) && input$red_salud != "") {
      dt <- dt[dt$red_salud == input$red_salud, ]
    }
    dt <- dt[, c("centro_salud", "integral", "horas_atencion", "director_nombre", "dm")]
    colnames(dt) <- c("Centro de Salud", "Integral", "Atención (hrs)", "Director(a)", "DM")
    datatable(dt, options = list(pageLength = 25, autoWidth = TRUE), rownames = FALSE)
  })
  
  output$table_cs <- renderDT({
    req(input$do_cs)
    dt <- df
    if (!is.null(input$centro_salud) && input$centro_salud != "") {
      dt <- dt[grepl(input$centro_salud, dt$centro_salud, ignore.case = TRUE), ]
    }
    dt <- dt[, c("centro_salud", "red_salud", "integral", "horas_atencion", "director_nombre", "dm")]
    colnames(dt) <- c("Centro de Salud", "Red de Salud", "Integral", "Atención (hrs)", "Director(a)", "DM")
    datatable(dt, options = list(pageLength = 25, autoWidth = TRUE), rownames = FALSE)
  })
  
  columnas_seleccionadas <- c("dm", "red_salud", "cs_codigo", "centro_salud", "integral", 
                              "horas_atencion", "direccion", "telefono", 
                              "aniversario", "director_nombre", "celular")
  
  etiquetas <- c("DM", "Red", "Código", "Centro salud", "Integral", "Atención (hrs)", "Dirección", "Teléfono", "Aniversario", "Director(a)", "Celular")
  
  showModalDetails <- function(info, df) {
    fila <- info$row
    centro <- df[fila, "centro_salud", drop = TRUE]
    datos_centro <- df[df$centro_salud == centro, ]
    datos_filtrados <- datos_centro[, columnas_seleccionadas]
    lat <- as.numeric(datos_centro$latitud)
    lng <- as.numeric(datos_centro$longitud)
    
    contenido_modal <- lapply(1:ncol(datos_filtrados), function(i) {
      valor <- as.character(datos_filtrados[1, i])
      etiqueta <- etiquetas[i]
      
      if (is.na(valor) || valor == "NA") {
        valor = ""
      }
      
      return(tags$p(tags$b(etiqueta), ": ", valor))
    })
    
    showModal(modalDialog(
      title = paste("Información de", centro),
      renderUI({
        wellPanel(
          lapply(contenido_modal, function(linea) {
            tags$p(linea)
          }),
          leafletOutput("map", width = "100%", height = 300)
        )
      }),
      footer = modalButton("Cerrar")
    ))
    
    output$map <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap) %>%
        addMarkers(lng = lng, lat = lat, popup = centro)
    })
  }
  
  observeEvent(input$table_red_cell_clicked, {
    info <- input$table_red_cell_clicked
    if (is.null(info) || is.null(info$col) || is.null(info$row)) {
      return(NULL)
    }
    dt <- df
    if (!is.null(input$red_salud) && input$red_salud != "") {
      dt <- dt[dt$red_salud == input$red_salud, ]
    }
    showModalDetails(info, dt)
  })
  
  observeEvent(input$table_cs_cell_clicked, {
    info <- input$table_cs_cell_clicked
    if (is.null(info) || is.null(info$col) || is.null(info$row)) {
      return(NULL)
    }
    dt <- df
    if (!is.null(input$centro_salud) && input$centro_salud != "") {
      dt <- dt[grepl(input$centro_salud, dt$centro_salud, ignore.case = TRUE), ]
    }
    showModalDetails(info, dt)
  })
}

shinyApp(ui, server)


