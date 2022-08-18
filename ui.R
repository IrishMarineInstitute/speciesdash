# This is the ui of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
##### Packages #####
library(shiny)
library(shinythemes)
library(plotly)
library(htmltools)
library(shinycssloaders)
library(shinyWidgets)
library(tidyverse)

shinyUI(
    navbarPage(id="TopLevelMenu", title="Species Dashboard", theme= shinytheme("cerulean"), fluid=TRUE,
               ##### Intro #####                    
               tabPanel("Introduction",
                        
                        tags$head(includeScript("google-analytics.js")), 
                        tags$style(
                          ".irs-bar {",
                          "  border-color: transparent;",
                          "  background-color: transparent;",
                          "}",
                          ".irs-bar-edge {",
                          "  border-color: transparent;",
                          "  background-color: transparent;",
                          "}"
                        ),
                        fluidRow(
                            column(width = 7,
                                   tabsetPanel(id= "tabs",
                                               tabPanel("Fishing Grounds", value = "A", 
                                                        p(), 
                                                        HTML("<p>The fisheries resource is the bedrock of the Irish seafood industry. The waters around Ireland contain some of the most productive fishing grounds and biologically sensitive areas in the EU. In 2010 an estimated 1.3 million tonnes of fish were taken by the fishing fleets of EU member states from the waters around Ireland (ICES Sub-areas VI & VII). Ireland landed 259,500 tonnes of these fish or 23% of the international landings. The main fish species caught were mackerel, horse mackerel, boarfish, blue whiting, herring, cod, whiting, haddock, saithe, hake, megrim, anglerfish, plaice, sole and Nephrops.<br/> <p><b> Main map: </b>This map shows the main fishing grounds arounds Ireland. The names of the grounds are based on records from fisheries observers and the outlines are derived from VMS data. The colour of the background uses a gradient to give the impression of water dept with the darker the colour indicating the deeper the water. The character of the seabed can vary considerably from one area to the next and fishers distinguish fishing grounds based on the bottom type and on the expected catch composition. Marine Institute fisheries observers record the names used for these grounds and although the names may vary between fishers and some grounds have no clear boundaries, patterns emerge when the observer records are overlaid over fishing effort data from Vessel Monitoring Systems (VMS) and catch composition data from the logbooks.</br>"),
                                                        div(p(HTML(paste0('Funding for this project was provided by the EMFF ',br(),
                                                                          p(),
                                                                          img(src="Logos/Irelands_EU_ESIF_2014_2020_en.jpg", width = "300px", height = "100px"),
                                                                          br(),br(),
                                                                          div(p(HTML('App last updated 2022-05-12')))
                                                                          ))))),
                                               tabPanel("Irish Ports", value = "B", 
                                                        p(), 
                                                        HTML("<p>Fish are landed into numerous ports around the Irish coast and, although each vessel is registered in a single port, they do not necessarily land their fish there. The main landings port for each vessel was determined by examining logbook data from  Irish Logbook Database and selecting the port where most landings events took place. Only vessels greater than 10m with at least 50 landings events during the period 2008-12 were included.</p>"),
                                                        p(), 
                                                        img(src="PortNames.png",  width =350, height= 400, style="display: block; margin-left: auto; margin-right: auto;"),
                                                        p(), 
                                                        HTML("<p><b>Map:</b> The small map above shows the main Irish fishing ports (black dots). Minor ports are shown as white dots.</p>")),
                                               tabPanel("Types of Gear", value = "C", 
                                                        p(), 
                                                        HTML("<p>From VMS data, it can be estimated that demersal otter trawlers account for the vast majority of fishing effort of vessels greater than 15m inside the Irish EEZ (around 62% of the fishing hours in 2008-12). Longliners account for around 15% and Gill and trammel netters for 7%. It is worth noting, however, that the time spent engaged in fishing operations is not necessarily a good measure of effort for passive gears. Pelagic trawlers only account for 5% of the total effort inside the EEZ but they are responsible for more landings than any other gear type, both in terms of volume and value. Beam trawlers and seiners account for around 5% and 2% respectively and pots and dredges both account for around 1%. Note that there are a considerable number of vessels<15m involved in potting and dredging. Other fishing gears or unknown gears account for the remaining 2%.</p>"),
                                                        p(),
                                                        hr(),
                                                        column(6,
                                                               selectInput("gearpic",label="Diagram of fishing gear type",
                                                                           choices =  list("Beam trawl"= 1, "Gillnet"= 2, 
                                                                                           "Midwater trawl"= 3,"Otter trawl"= 4,
                                                                                           "Seine Net"= 5), 
                                                                           selected = 1),
                                                               tags$h5("Illustration:"),
                                                               imageOutput("gear_pic"),
                                                               offset=2)
                                               ),
                                               tabPanel("Vessel Nationalities",value = "D",
                                                        p(), 
                                                        HTML("<p>The VMS data also reveal that the vast majority of fishing effort by Irish vessels >15m takes places within the Irish EEZ (77%). However, most of the fishing effort inside the Irish EEZ is carried out by foreign vessels; Ireland is responsible for only 36% of the international effort of vessels >15m inside the EEZ (note that the proportion of Irish effort would be considerably higher if smaller vessels were included). The Irish effort consists of mainly of demersal otter trawlers. Spain accounts for 30% of the effort (mainly demersal otter trawlers and longliners). France and the UK account for 20% and 11% of the effort(dominated by demersal otter trawlers for both countries). Belgium accounts for 1% of the effort, (nearly all beam trawlers). The remaining 3% effort  is mainly carried out by the Netherlands, Germany and Denmark and is dominated by pelagic trawlers.<p>")),
                                               tabPanel("Fish Ageing",value = "E",
                                                        p(), 
                                                        HTML("<p><b>Why do we age fish?</b>
In order to assess the state of any fish stock, it is important to know the age structure of the population. The age profile gives an indication on how healthy the stock is. A broad range of ages signifies a healthy stock; a lack of young fish could mean poor spawning in a particular year; a lack of older fish may signify overfishing. </p> <p><b>How do we age fish? </b>The most common method used to age marine fish is to examine the ear stones or <u>otoliths</u> found in the head of the fish. These are made of calcium and help the fish to maintain its balance.</p> "),
                                                        p(),
                                                        fluidRow(column(6,
                                                                        img(src="Ageing/agedexample.png",  width =400, height= 250),
                                                                        offset=2)),
                                                        br(),
                                                        br(),
                                                        br(),
                                                        br(),
                                                        br(),
                                                        br(),
                                                        br(),
                                                        fluidRow(column(12,HTML("<p>Otoliths provide an accurate representation of the age of the individual fish, as it consists of layers of calcium carbonate that are built up on an annual basis, much like tree bands. Each year of growth is composed of an opaque and a translucent zone. The opaque zones are wide and represent summer growth, when food is plentiful and the temperatures are warm. The translucent zones are narrower and represent winter growth, when food is less plentiful and temperatures are colder. The age of an individual fish can be determined by reading the pattern of zones on the otolith.The otoliths are located beside the brain in the head of the fish. Each species of fish has different shaped otoliths. Otoliths in plaice, mackerel and herring are thin and the bands are clear and easy to count. The otoliths of cod, haddock, whiting and black sole are thick and the otolith must be sectioned before the ring pattern can be seen.</p>"),style = "margin-top:-8em"))),
                                               tabPanel("Data Collection",value = "F",
                                                        p(), 
                                                        HTML("<p>Data collection is essential for the implementation of the CFP.  Robust scientific data is required to evaluate the state of fish stocks, the profitability of the different segments of the sector and the effects of fisheries and aquaculture on the ecosystem. It is also used to evaluate EU policies: fisheries management measures, structural financial measures in support of the fisheries and aquaculture dependent areas, mitigation measures to reduce negative effects of fisheries on the ecosystem."),
                                                        HTML("<p><b>Catch Sampling:</b> Scientists collect essential data for fish stock assessments when fishers land their catch. Additionally, sampling at sea allows scientists to quantify the part of the catch that is not landed at the ports. They estimate the amounts of fish that are landed or discarded, and collect age and length data.By sampling the commercial catches we collect crucial data on the amount of fish that is caught as well as their age and length composition of the fish. Many fish species can be aged; this information allows assessment models to track the abundance of cohorts of fish over time and analyse the age composition of the catch each year. These data are the raw material used to assess the resource."),
                                                        br(),
                                                        tags$a(href = "https://www.dcmap-ireland.ie/", 
                                                               "Learn More", 
                                                               target="_blank"),
                                                        br(),
                                                        img(src="Data.jpg", width =750, height= 250))
                                               
                                   )#close tabsetPanel     
                            ), #close column
                            column(width = 5,
                                   conditionalPanel(condition = "input.tabs == 'A'",
                                                    img(src="FishingGrounds.jpg", width = 500, height= 570)),
                                   conditionalPanel(condition = "input.tabs == 'B'",
                                                    img(src="PortPie.png", width =500, height= 550, align = 'center'),
                                                    HTML("<p><b>Main map: </b>This map shows landings by port and species group; the size of the pie plots corresponds to the landings volume.</p>")),
                                   conditionalPanel(condition = "input.tabs == 'C'",
                                                    img(src="GearTypes.png",width =500, height= 550),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    HTML("<p><b> Map: </b>This map illustrates the spatial distribution of fishing effort by gear type for vessels >15m fishing in the Irish EEZ. The percentages in the legend refer to the share of the total effort inside the EEZ for each type of gear.</p>")),
                                   conditionalPanel(condition = "input.tabs == 'D'",
                                                    img(src="NationalityAllGears.png",width =475, height= 515),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    br(),
                                                    HTML("<p><b> Map: </b>This map illustrates the nationality of vessels >15m fishing in the Irish EEZ (all gears combined). IRL = Ireland; GBR = United Kingdom; FRA = France; ESP = Spain; BEL = Belgium. The percentages in the legend refer to the share of the total effort inside the EEZ for each country.</p>")),
                                   conditionalPanel(condition = "input.tabs == 'E'",
                                                    img(src="Ageing/otoliths in head with inset copy.jpg",width =600, height= 500)),
                                   conditionalPanel(condition = "input.tabs == 'F'",
                                                   img(src="Sampled.png",width =500, height= 550),
                                                   HTML("<p> This map shows the positions of the hauls from which discards have been sampled ")
                                                   )
                            )#close column
                        ) #close fluidRow1 
               ), #close tabPanel 
               ##### Fish sp tab - option selectors ######  
               tabPanel("Fish Species",
                        fluidRow(
                            column(width = 7,
                                   fluidRow(
                                       column(width=3,
                                              # We set the species list and default selection in server.R now 
                                              selectInput("species",label="Species",
                                                          choices= NULL,
                                                          selected= NULL ),
                                              conditionalPanel(condition = "input.fishtab == 'A'",
                                                               selectInput(inputId="biooptionselection", label="Select parameter", 
                                                                           choices=list("None","Age","Sex","Presentation","Gear","Sample Type"),
                                                                           selected = "None")),
                                              conditionalPanel(condition = "input.fishtab == 'B'",
                                                               selectInput(inputId="ageoptionselection", label="Select parameter", 
                                                                           choices=list("None","Sex","Presentation","Gear","Sample Type"),
                                                                           selected = "None")),
                                              conditionalPanel(condition = "input.biooptionselection =='Gear' && input.fishtab == 'A'",
                                                               uiOutput("GearFilter")),
                                              conditionalPanel(condition = "input.ageoptionselection =='Gear' && input.fishtab == 'B'",
                                                               uiOutput("GearFilter.a")                
                                              )),
                                       column(width=4,
                                              conditionalPanel(condition="input.fishtab == 'A'",
                                                               uiOutput("quarterfilter"),
                                                               uiOutput("yearfilter")),
                                              conditionalPanel(condition="input.fishtab == 'B'",
                                                               uiOutput("quarterfilter.a"),
                                                               uiOutput("yearfilter.a"))
                                       ),
                                       column(width=5,
                                              conditionalPanel("input.fishtab == 'A'",
                                                               radioGroupButtons(
                                                                 inputId = "Id",
                                                                 label = "",
                                                                 choices = c("ICES Area", 
                                                                             "ICES Division"),
                                                                 direction = "horizontal",
                                                                 checkIcon = list(
                                                                   yes = tags$i(class = "fa fa-check-square", 
                                                                                style = "color: steelblue"),
                                                                   no = tags$i(class = "fa fa-square-o", 
                                                                               style = "color: steelblue"))
                                                               ),
                                                               
                                                               
                                                               uiOutput("spatialops.w")
                                              ), #- SubArea filter
                                              
                                              conditionalPanel("input.fishtab == 'A'",
                                                               downloadButton("downloadDatalw", "Download data")
                                              ),
                                              conditionalPanel("input.fishtab == 'B'",
                                                               radioGroupButtons(
                                                                 inputId = "Id.a",
                                                                 label = "",
                                                                 choices = c("ICES Area", 
                                                                             "ICES Division"),
                                                                 direction = "horizontal",
                                                                 checkIcon = list(
                                                                   yes = tags$i(class = "fa fa-check-square", 
                                                                                style = "color: steelblue"),
                                                                   no = tags$i(class = "fa fa-square-o", 
                                                                               style = "color: steelblue"))
                                                               ),
                                                               uiOutput("spatialops.a")), #- SubArea filter
                                              conditionalPanel("input.fishtab == 'B'",                 
                                                               downloadButton("downloadDatala", "Download data",class="btn btn-outline-primary")#,
                                                               
                                                               ))
                                   ),
                                   ##### Fish sp tab - Maps and plots  ######                                     
                                   fluidRow(
                                       column(width=12,
                                              conditionalPanel(condition = "input.fishtab == 'A'",
                                                               plotlyOutput("bio_lw")
                                                               %>% withSpinner(color="#0dc5c1")),
                                              conditionalPanel(condition = "input.fishtab == 'B'",
                                                               plotlyOutput("bio_la")
                                                               %>% withSpinner(color="#0dc5c1"))
                                       )),
                                   
                                   fluidRow(
                                       column(width=10, 
                                              conditionalPanel(condition = "input.fishtab == 'C'",
                                                               imageOutput("fish_b1", height="100%"),
                                                               tags$style(HTML(".js-irs-0 .irs-grid-pol.small {height: 4px;}")),
                                                               tags$style(HTML(".js-irs-1 .irs-grid-pol.small {height: 0px;}")),
                                                               sliderInput("slideryear", "Choose Year:",
                                                                           min = 2007, max = 2021, #change after yearly update..For year 2020 max year is 2019
                                                                           value = 2021, step = 1,
                                                                           sep = "",
                                                                           animate = TRUE),htmlOutput("LandingsDisttext")),offset=4,style = "margin-top:-5em"))
                            ), 
                            ##### Fish sp tab - Species tabsets #####
                            column(width = 5,
                                   tabsetPanel(id = "fishtab",
                                               tabPanel("Biology",value= "A", 
                                                        p(), htmlOutput("fish_biology"),
                                                        fluidRow(column(width=7,imageOutput("fish_drawing", height='100%')),
                                                                 column(width=5,conditionalPanel(condition = "input.species =='White-bellied Anglerfish' || input.species =='Black-bellied Anglerfish'",
                                                                                                 imageOutput("monk_belly"))))),     
                                               tabPanel("Age", value = "B", 
                                                        p(),
                                                        fluidRow(column(width=5, htmlOutput("ageingtxt")),
                                                                 column(width=7, imageOutput("speciesotolith", height='100%'))),
                                                        p(),
                                                        fluidRow(column(width=5,textInput("lengthcm", label = "Enter fish length in cm:"), value = 0),
                                                                 column(width=7,tags$b("Age range observed*:"), h4(textOutput("agerange")),
                                                                        tags$b("Modal age is:"),h4(textOutput("mode")),
                                                                        tags$small("*age range based on age readings and lengths taken from fish sampled at ports and the stockbook"))),
                                                        hr(),
                                                        column(width=5,actionButton("showhist",label = "Show Histogram")), 
                                                        plotlyOutput("age_hist")
                                               ),
                                               tabPanel("Distribution",value= "C",
                                                       
                                                        p(),htmlOutput("fish_distribution"),
                                                        p(),htmlOutput("fish_b1a"),
                                                        h3("Useful links for more information:"),
                                                        a(href=paste0("https://shiny.marine.ie/stockbook/"),
                                                          "The Digital Stockbook",target="_blank"),
                                                        p(),
                                                        a(href=paste0("https://www.marine.ie"),
                                                          "The Marine Institute webpage",target="_blank"),
                                                        p(),
                                                        "For any queries contact",
                                                       a("informatics@marine.ie",href="informatics@marine.ie")
                                                        )
                                   )#close tabsetPanel
                            )#close column
                        )#close fluidRow   
               ) #close tabPanel
    )#close navbarPage
) #close shinyUI







