library(shiny)

# Define UI for application
ui <- fluidPage(
  titlePanel(
    "Información de Centros de Salud",
    windowTitle = "Información de Centros de Salud"
  ),
  
  tabsetPanel(
    tabPanel("Consulta por Red de Salud",
             sidebarLayout(
               sidebarPanel(
                 selectInput("red_salud", "Red de Salud", choices = NULL),
                 actionButton("do_red", "Realizar Consulta")
               ),
               mainPanel(
                 DTOutput("table_red")
               )
             )
    ),
    tabPanel("Consulta por Centro de Salud",
             sidebarLayout(
               sidebarPanel(
                 textInput("cs_nombre", "Nombre del Centro de Salud"),
                 actionButton("do_cs", "Realizar Consulta")
               ),
               mainPanel(
                 DTOutput("table_cs")
               )
             )
    )
  )
)

# Define server logic required
server <- function(input, output, session) {
  
  data <- reactiveVal(NULL)
  
  # Leer el archivo CSV al iniciar la aplicación
  df <- read.csv("tab_centros_salud_redes.csv", stringsAsFactors = FALSE)
  data(df)
  
  # Establecer las opciones para el menú desplegable de "Red de Salud"
  updateSelectInput(session, "red_salud", choices = c("", sort(unique(df$red_salud))))
  
  output$table_red <- renderDT({
    req(input$do_red)
    
    dt <- data()
    
    # Filtrar por "Red de Salud" si se selecciona una
    if (!is.null(input$red_salud) && input$red_salud != "") {
      dt <- dt[dt$red_salud == input$red_salud, c("cs_nombre", "cs_integral", "horas_atencion", "director_nombre", "dm")]
      
      # Convertir los valores de 'cs_integral' a "SÍ" o "NO"
      dt$cs_integral <- ifelse(dt$cs_integral, "SÍ", "NO")
      
      # Ordenar por 'cs_nombre'
      dt <- dt[order(dt$cs_nombre), ]
    }
    
    # Definir nombres de encabezados visibles
    col_names <- c("Centro Salud", "Integral", "Atención (hrs)", "Director(a)", "DM")
    
    datatable(dt, colnames = col_names, options = list(pageLength = 25, autoWidth = TRUE), 
              caption = paste("Red de Salud:", input$red_salud), rownames = FALSE)
  })
  
  output$table_cs <- renderDT({
    req(input$do_cs)
    
    dt <- data()
    
    # Filtrar por "Nombre del Centro de Salud" si se proporciona uno
    if (!is.null(input$cs_nombre) && input$cs_nombre != "") {
      dt <- dt[grepl(input$cs_nombre, dt$cs_nombre, ignore.case = TRUE), ]
    }
    
    # Seleccionar columnas específicas para mostrar
    dt <- dt[, c("red_salud", "cs_nombre", "cs_integral", "horas_atencion", "cs_direccion", "cs_aniversario", "director_nombre", "dm")]
    
    # Convertir los valores de 'cs_integral' a "SÍ" o "NO"
    dt$cs_integral <- ifelse(dt$cs_integral, "SÍ", "NO")
    
    # Ordenar por 'cs_nombre'
    dt <- dt[order(dt$cs_nombre), ]
    
    # Definir nombres de encabezados visibles
    col_names <- c("Red Salud", "Centro Salud", "Integral", "Atención (hrs)", "Dirección", "Aniversario", "Director(a)", "DM")
    
    datatable(dt, colnames = col_names, options = list(pageLength = 25, autoWidth = TRUE), rownames = FALSE)
  })
}

# Run the application 
shinyApp(ui, server)