# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
# Load in the data

SpeciesList<-read.csv("Data/SpeciesList20220512.csv")
bio.data <- readRDS("Data/bio.data20220512.rds")
cc.age<- readRDS("Data/cc.age20220512.rds")
Supp_table <- read.csv('Data/Supplemental data.csv', header=TRUE, sep = ",")

Mode <- function(x) {
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
}

# Define server logic 
shinyServer(function(input, output, session){
    
    ## Read parameter strings from the URL and update the "species" selectInput appropriately
    observe({
        urlParameters <- parseQueryString(session$clientData$url_search)
        ## If we have a species parameter in the URL we will try and use it to
        ## choose our default species
        if (!is.null(urlParameters[['species']])) {
            
            speciesURLParameter <- urlParameters[['species']]
            
            # Try and find the description for the parameter passed in
            speciesURLName <- SpeciesList[tolower(SpeciesList$IC_Species)==tolower(speciesURLParameter),"Species_Name"]
            
            # If we didn't get a match just use the first species in the data frame as the default species
            if (length(speciesURLName) == 0){
                speciesURLName <- SpeciesList[1,"Species_Name"]
            }
            
            updateSelectInput(session, 
                              "species",label="Species",
                              choices= SpeciesList$Species_Name,
                              selected= speciesURLName )
            
            
            #Show the Fish Species tab using SELECT - this is a bit of hack to make sure the
            # user is taken to the Fish Species page first
            showTab("TopLevelMenu","Fish Species",select= TRUE, session)
            
        } 
        ## Else we 'll just use the first species in the data frame as the default species
        else 
        {
            updateSelectInput(session, 
                              "species",label="Species",
                              choices= SpeciesList$Species_Name,
                              selected= SpeciesList[1,"Species_Name"] )
            
        }
    })
    
    ###### Introduction page #######
    
    output$gear_pic<-renderImage({
        filename <- normalizePath(file.path('www/GearPics',paste(input$gearpic,'.jpg', sep='')))
        list(src = filename, width =400, height= "auto")}, deleteFile = FALSE)
    
    ####### Fish Species page #######
    output$fish_b1a<- renderText({
        as.character(Supp_table[which(Supp_table[,"Fish"] %in% input$species),"b1a"])
    })
    output$fish_biology<- renderText({
        as.character(Supp_table[which(Supp_table[,"Fish"] %in% input$species),"biology"])
    })
    output$fish_distribution<-renderText({
        as.character(Supp_table[which(Supp_table[,"Fish"] %in% input$species),"distribution"])
    })
    output$fish_drawing<- renderImage({
        filename <- paste("www/FishSketches/", Supp_table[which(Supp_table[,"Fish"] %in% input$species),"Fish"], ".png", sep="")
        list(src = filename, filetype = "png",width= "auto", height = 150)}, deleteFile = FALSE)
    output$monk_belly<- renderImage({
        filename <- paste("www/FishSketches/BUD&PISC", ".jpg", sep="")
        list(src = filename, filetype = "jpg",width= "auto", height = 150)}, deleteFile = FALSE)
    output$fish_b1<-renderImage({
        filename <- paste("www/LandingsDist/Landings", input$slideryear, "/Land", 
                          Supp_table[which(Supp_table[,"Fish"] %in% input$species),"Fish_Code"],".png", sep="")
        list(src = filename, width ="auto", height= 550)}, deleteFile = FALSE)
    output$ageingtxt <- renderText({
        as.character(Supp_table[which(Supp_table[,"Fish"] %in% input$species),"Ageing2"])
    })
    
    
    ## Clear the value of input$lengthcm when input$species is changed
    observeEvent(input$species,{
      #print("input$species event observed")
      updateTextInput(session, "lengthcm", value = "")
    }, ignoreNULL = TRUE, ignoreInit = TRUE)
    
    ##### Age/length widget ######
    x1 <- reactive({cc.age$Age[which(cc.age$Species==paste(SpeciesList[which(SpeciesList$Species_Name==input$species),][[2]]) & 
                                         cc.age$Length== paste(input$lengthcm))]})
    output$agerange <- reactive({
        if (length(x1())<3) {
            paste("No individuals of this length recorded",sep="")
        }else{ 
            paste(min(x1()),"to", max(x1()), "years,", "n = ",length(x1()), sep=" ")
        }
    })
    output$mode <- reactive({
        paste(Mode(x1()), sep=" ")
    })
    
    
    ##### Histogram #######
    observeEvent(input$showhist, {
        y1 <- reactive({cc.age$Age[which(cc.age$Species==paste(SpeciesList[which(SpeciesList$Species_Name==input$species),][[2]]) & cc.age$Length== paste(input$lengthcm))]})
        
        output$age_hist <- renderPlotly({
          yy<-as.data.frame(y1())
          
          # Don't show the graph if there's no data
          if (nrow(yy) == 0){
            NULL
          } else {
            yy$age<-as.factor(yy$y1)
            p<-ggplot(yy,aes(age))+geom_bar(color="black",fill="white",width = 1)+
            labs(title ='Histogram of observered ages',x="Age" )
            ggplotly(p)
          }
         
        })
    })
    
    ##### Distribtion slider text ####### 
    output$LandingsDisttext <- renderText({
        if(input$species=="Horse Mackerel")
        {if(input$slideryear>2014){paste(Supp_table[which(Supp_table[,"Fish"] %in% input$species),"LandingsDist"], sep="")}
            else{}}
        else{
                paste("The distribution of ", input$species, " landings by Irish vessels during ", 
              input$slideryear, ". ", 
              Supp_table[which(Supp_table[,"Fish"] %in% input$species),"LandingsDist"], sep="")}
    })
    
######## Length/Weight #######
grsp <-reactive({
  
  # set a default value to prevent error messages
  speciesToFilter <- "xxx"
  if (input$species != ""){
    speciesToFilter <- as.character(SpeciesList[which(SpeciesList$Species_Name==input$species),][[2]])
  }
 
  filter(bio.data,Species==speciesToFilter)
 
 })
  
    # Reactive quarter filter based on quarters available by species
    output$quarterfilter<- renderUI({
        quarterlist2<-c("All",levels(na.omit(as.factor(grsp()$Quarter))))
        selectInput("quarter","Quarter", choices=quarterlist2, selected = "All")
    })
    
    # Reactive year filter based on years available by species
    output$yearfilter<- renderUI({
       
      # set default values to avoid errors
      if (length(grsp()$Year)> 0){
        minYear <- min(grsp()$Year, na.rm=TRUE)
        maxYear <- max(grsp()$Year, na.rm=TRUE)
      } else {
        minYear <- 2020
        maxYear <- 2021
      }
      
        sliderInput("year","Years", min=minYear, max=maxYear, 
                     value = c( maxYear -1, maxYear )
                    ,sep="", step=1)##by one year
        
    })
    
    # Reactive gear filter based on gears available by species
    output$GearFilter <- renderUI({
        gearlist <- unique(grsp()$Gear)
        gearlist2 = factor(append("All", as.character(gearlist)))
        selectInput(inputId="gearselect", label="Select gear type", choices=gearlist2, selected= "All")
    })
grspnew.w<- reactive({
        
        myYears <- c()
        if (!is.null(input$year)){
          if (length(input$year)>=2){
            if (input$year[1] < input$year[2]){
              myYears <- input$year[1]:input$year[2]
            } else {
              myYears <- c(input$year[1])
            }
          } else {
            myYears <- input$year
          }
        }
        
        grspyear<- filter(grsp(), Year %in% myYears)
        
        if(input$quarter == "All" || is.null(input$quarter)){
            grspqtr = grspyear
        }else{
            grspqtr<- filter(grspyear, Quarter %in% input$quarter )
        }
        if(input$gearselect == "All"|| is.null(input$gearselect)|| input$biooptionselection=="None"){
            grspgear = grspqtr 
        }else{
            grspgear <- filter(grspqtr, Gear %in% input$gearselect) 
        }
    })
  
   
    #Creating Sub Area filter based on the full data
    output$spatialops.w <- renderUI({
   if(input$Id=="ICES Area"){   
       pickerInput(
           inputId = "subselect",
           label = "ICES Area",
           choices = str_sort(as.character(unique(grsp()$ICESSubArea)),numeric = TRUE),
           selected=str_sort(as.character(unique(grsp()$ICESSubArea)),numeric = TRUE),
           options = list(
             `actions-box` = TRUE
           ),
           multiple = TRUE
       )}
    else{
      pickerInput(
        inputId = "subselect2",
        label = "ICES Division",
        choices = str_sort(as.character(unique(grsp()$ICESDivFullNameN )),numeric = TRUE),
        selected=str_sort(as.character(unique(grsp()$ICESDivFullNameN )),numeric = TRUE),
        options = list(
          `actions-box` = TRUE
        ),
        multiple = TRUE
      )}
})

    #Update the Area filter based on the full data being filtered by year, quarter and gear
      observe({
        if(input$Id=="ICES Area"){     
          if(is.null(input$year)){
              return()
         }else{# ....
  
           x <- str_sort(as.character(unique(grspnew.w()$ICESSubArea)),numeric = TRUE)
          updatePickerInput(session, "subselect",label="ICES Area", choices=x,selected = x)
          
         }}
        else{
          if(is.null(input$year)){
            return()
          }else{# ....
            
            x <- str_sort(as.character(unique(grspnew.w()$ICESDivFullNameN )),numeric = TRUE)
            updatePickerInput(session, "subselect2",label="ICES Division", choices=x,selected = x)
            
          }
        }
      })

    #Filter based on Sub Area
    grspnew.w1<- reactive({
      if(input$Id=="ICES Area"){
            grspSub <- filter(grspnew.w(),ICESSubArea %in% input$subselect)}
      else{
        grspSub <- filter(grspnew.w(),ICESDivFullNameN %in% input$subselect2)
      }
    })
    
    
    ###Data Downloader widget  
    output$downloadDatalw <- downloadHandler(
        filename = function() {
            paste(input$species, "-LWdata",".csv", sep = "")
        },
        content = function(file) {
            write.csv(grsp(), file, row.names = FALSE) 
        })

    ###Plotly charts
    output$bio_lw<- renderPlotly({
      
        validate(need(nrow(grspnew.w1()) > 0, "No data to plot for the selected parameters"))
        # Max number of points we will plot on a chart - for performance reasons
        maxPointsToPlot <- 10000 
        myAnnotation <- ''
        # Set ranges for axes
        minX <- min(grspnew.w1()$Length)-1
        maxX <- max(grspnew.w1()$Length)+1
        minY <- 0
        maxY <- max(grspnew.w1()$Weight, na.rm = T)*1.05
        
        if(input$biooptionselection=="Sex"){
            grspnew.w1 <- filter(grspnew.w1(), !is.na(Sex))
            validate(need(nrow(grspnew.w1) > 0, "No data to plot for the selected parameters"))
            # if there's a lot of data to plot just plot a sample of it
            if (nrow(grspnew.w1)> maxPointsToPlot){
              grspnew.w1 <- grspnew.w1[sample(nrow(grspnew.w1), maxPointsToPlot), ]
              myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
            } 
            
            p <- plot_ly(grspnew.w1, x = ~Length, y = ~Weight, type = 'scatter', 
                         text=~paste("length:",Length,"cm","<br>weight:",Weight, "grams<br>date:", Date, "<br>sex:", Sex),
                         hoverinfo='text',
                         color = ~Sex, colors="Set1",
                         mode = 'markers', marker =list(opacity = 0.5)) %>% 
                layout(hovermode='closest', title=paste(input$species,"Weight vs Length (points coloured by sex)"),
                       xaxis = list(title = 'Length (cm)', range= c(minX, maxX), showline = TRUE),
                       yaxis = list(title = 'Weight (g)', range = c(minY, maxY), showline = TRUE),
                       annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                       margin=(list(t=70)),
                       showlegend = TRUE) 
            p$elementId <- NULL
            p 
        }else if(input$biooptionselection=="Age"){
            grspnew.w1 <- filter(grspnew.w1(), Age>-1)
            grspnew.w1 <- filter(grspnew.w1, !is.na(Age))
            validate(need(nrow(grspnew.w1) > 0, "No data to plot for the selected parameters"))
            # if there's a lot of data to plot just plot a sample of it
            if (nrow(grspnew.w1)> maxPointsToPlot){
              grspnew.w1 <- grspnew.w1[sample(nrow(grspnew.w1), maxPointsToPlot), ]
              myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
            } 

              p <- plot_ly(grspnew.w1, x = ~Length, y = ~Weight, type = 'scatter', mode = 'markers',hoverinfo='text',
                text=~paste("length:",Length,"cm","<br>weight:",Weight, "grams<br>date:", Date, "<br>Age:", Age),
                color= ~Age, colors = "Set1",marker =list(opacity = 0.5)) %>%  
              layout(hovermode='closest', title=paste(input$species,"Weight vs Length (points coloured by age)"),
                xaxis = list(title = 'Length (cm)', range= c(minX, maxX), showline = TRUE),
                yaxis = list(title = 'Weight (g)', range = c(minY, maxY), showline = TRUE),
                annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                margin=(list(t=70)),
                showlegend = FALSE)
            p$elementId <- NULL
            p 
        }else if(input$biooptionselection=="Presentation"){
            grspnew.w1 <- filter(grspnew.w1(), !is.na(Presentation))
            validate(need(nrow(grspnew.w1) > 0, "No data to plot for the selected parameters"))
            # if there's a lot of data to plot just plot a sample of it
            if (nrow(grspnew.w1)> maxPointsToPlot){
              grspnew.w1 <- grspnew.w1[sample(nrow(grspnew.w1), maxPointsToPlot), ]
              myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
            } 
            
            p <- plot_ly(grspnew.w1, x = ~Length, y = ~Weight, type = 'scatter', mode = 'markers',hoverinfo='text',
                         text=~paste("length:",Length,"cm","<br>weight:",Weight, "grams<br>date:", Date, "<br>presentation:", Presentation),
                         color= ~Presentation, colors = "Dark2") %>%  
                layout(hovermode='closest', title=paste(input$species,"Weight vs Length (points coloured by sample presentation)"),
                       xaxis = list(title = 'Length (cm)', range= c(minX, maxX), showline = TRUE),
                       yaxis = list(title = 'Weight (g)', range = c(minY, maxY), showline = TRUE),
                       annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                       margin=(list(t=70)),
                       showlegend = TRUE)
            p$elementId <- NULL
            p 
        }else if(input$biooptionselection=="Sample Type"){
            grspnew.w1 <- filter(grspnew.w1(), !is.na(Type))
            validate(need(nrow(grspnew.w1) > 0, "No data to plot for the selected parameters"))
            # if there's a lot of data to plot just plot a sample of it
            if (nrow(grspnew.w1)> maxPointsToPlot){
              grspnew.w1 <- grspnew.w1[sample(nrow(grspnew.w1), maxPointsToPlot), ]
              myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
            } 
            
            p <- plot_ly(grspnew.w1, x = ~Length, y = ~Weight, type = 'scatter', mode = 'markers',hoverinfo='text',
                         text=~paste("length:",Length,"cm","<br>weight:",Weight, "grams<br>date:", Date, "<br>sample type:",Type), 
                         color= ~Type,colors =c('Discards'='red','Landings'='lightgreen')) %>%  
                layout(hovermode='closest', title=paste(input$species,"Weight vs Length (points coloured by sample type)"),
                       xaxis = list(title = 'Length (cm)', range= c(minX, maxX), showline = TRUE),
                       yaxis = list(title = 'Weight (g)', range = c(minY, maxY), showline = TRUE),
                       annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                       margin=(list(t=70)),
                       showlegend = TRUE)
            p$elementId <- NULL
            p 
        }else if(input$biooptionselection=="Gear"){
            grspnew.w1 <- filter(grspnew.w1(), !is.na(Gear))
            validate(need(nrow(grspnew.w1) > 0, "No data to plot for the selected parameters"))
            # if there's a lot of data to plot just plot a sample of it
            if (nrow(grspnew.w1)> maxPointsToPlot){
              grspnew.w1 <- grspnew.w1[sample(nrow(grspnew.w1), maxPointsToPlot), ]
              myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
            } 
            
            p <- plot_ly(grspnew.w1, x = ~Length, y = ~Weight, type = 'scatter', mode = 'markers',hoverinfo='text',
                         text=~paste("length:",Length,"cm","<br>weight:",Weight, "grams<br>date:", Date, "<br>gear type:",Gear),
                         color= ~Gear,colors = "Set1") %>%  
                layout(hovermode='closest', title=paste(input$species,"Weight vs Length (points coloured by gear type)"),
                       xaxis = list(title = 'Length (cm)', range= c(minX, maxX), showline = TRUE),
                       yaxis = list(title = 'Weight (g)', range = c(minY, maxY), showline = TRUE),
                       annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                       margin=(list(t=70)),
                       showlegend = TRUE)
            p$elementId <- NULL
            p 
        }
        else{
          grspnew.w1 <- grspnew.w1()
          validate(need(nrow(grspnew.w1()) > 0, "No data to plot for the selected parameters"))
          # if there's a lot of data to plot just plot a sample of it
          if (nrow(grspnew.w1)> maxPointsToPlot){
            grspnew.w1 <- grspnew.w1[sample(nrow(grspnew.w1), maxPointsToPlot), ]
            myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
          } 
          
           p <- plot_ly(grspnew.w1, x = ~Length, y = ~Weight, type = 'scatter',
                         mode = 'markers', marker =list(opacity = 0.5,color='black'),
                         hoverinfo='text',
                         text=~paste("length:",Length,"cm<br>weight:",Weight, "grams<br>Date:", Date)) %>%
                layout(hovermode='closest', 
                       title=paste(input$species," Weight vs Length", sep=""),
                       xaxis = list(title = 'Length (cm)', range= c(minX, maxX), showline = TRUE),
                       yaxis = list(title = 'Weight (g)', range = c(minY, maxY), showline = TRUE),
                       annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                       margin=(list(t=80)
                      ),
                       showlegend = FALSE)
            p$elementId <- NULL
            p
           
        }
    })   
    
######## Age/Weight ########
output$speciesotolith<-renderImage({
  # set a default file to avoid error messages
  filename <- normalizePath(file.path('www/Ageing',paste('Black-bellied Anglerfish','.png', sep='')))
  if(input$species != ""){
        filename <- normalizePath(file.path('www/Ageing',paste(input$species,'.png', sep='')))
  }
  list(src = filename, width =300)
  
}, deleteFile = FALSE)
    
cc.a<-reactive({
  
  # set a default value to prevent error messages
  speciesToFilter <- "xxx"
  if (input$species != ""){
    speciesToFilter <- as.character(SpeciesList[which(SpeciesList$Species_Name==input$species),][[2]])
  }
  
  filter(cc.age,Species==speciesToFilter)
  
})  

# Reactive year filter based on years available by species
output$yearfilter.a<- renderUI({
  
  # set default values to avoid errors
  if (length(cc.a()$Year)> 0){
    minYear <- min(cc.a()$Year, na.rm=TRUE)
    maxYear <- max(cc.a()$Year, na.rm=TRUE)
  } else {
    minYear <- 2020
    maxYear <- 2021
  }
  
    sliderInput("year.a","Years", min=minYear, max=maxYear, 
                value = c( maxYear-1, maxYear ),
                sep="", step=1)
})

# Reactive quarter filter based on quarters available by species
output$quarterfilter.a<- renderUI({
    quarterlist2<-c("All",levels(na.omit(as.factor(cc.a()$Quarter))))
 selectInput("quarter.a","Quarter", choices=quarterlist2, selected = "All")
})

# Reactive gear filter based on gears available by species
output$GearFilter.a <- renderUI({
    gearlist <- unique(cc.a()$Gear)
    gearlist2 = factor(append("All", as.character(gearlist)))
    selectInput(inputId="gearselect.a", label="Select gear type", choices=gearlist2, selected= "All")
}) 



grspage <- reactive({
  
    myYears <- c()
    if (!is.null(input$year.a)){
      if (length(input$year.a)>=2){
        if (input$year.a[1] < input$year.a[2]){
          myYears <- input$year.a[1]:input$year.a[2]
        } else {
          myYears <- c(input$year.a[1])
        }
      } else {
        myYears <- input$year.a
      }
    }
    
    grspageyear<- filter(cc.a(), Year %in% myYears)
    
    
    if(input$quarter.a == "All" || is.null(input$quarter.a)){
        grspageqtr = grspageyear
    }else{
        grspageqtr<- filter(grspageyear, Quarter %in% input$quarter.a )
    }
    if(input$gearselect.a == "All"|| is.null(input$gearselect.a)|| input$ageoptionselection=="None"){
        grspagegear = grspageqtr 
    }else{
        grspagegear <- filter(grspageqtr, Gear %in% input$gearselect.a) 
    }
})

#Creating Sub Area filter based on the full data
 output$spatialops.a <- renderUI({
if(input$Id.a=="ICES Area"){   
  pickerInput(
    inputId = "subselect.a",
    label = "ICES Area",
    choices = str_sort(as.character(unique(cc.a()$ICESSubArea)),numeric = TRUE),
    selected=str_sort(as.character(unique(cc.a()$ICESSubArea)),numeric = TRUE),
    options = list(
      `actions-box` = TRUE
    ),
    multiple = TRUE
  )}
else{
  pickerInput(
    inputId = "subselect2.a",
    label = "ICES Division",
    choices = str_sort(as.character(unique(cc.a()$ICESDivFullNameN )),numeric = TRUE),
    selected=str_sort(as.character(unique(cc.a()$ICESDivFullNameN )),numeric = TRUE),
    options = list(
      `actions-box` = TRUE
    ),
    multiple = TRUE
  )}
    })

#Update the Area filter based on the full data being filtered by year, quarter, month and gear
observe({
  if(input$Id.a=="ICES Area"){     
    if(is.null(input$year.a)){
         return()
    }else{
      
      x <- str_sort(as.character(unique(grspage()$ICESSubArea )),numeric = TRUE)
      updatePickerInput(session, "subselect.a",label="ICES Area", choices=x,selected = x)
      
    }}
  else{
    if(is.null(input$year.a)){
      return()
    }else{
      
      x <- str_sort(as.character(unique(grspage()$ICESDivFullNameN )),numeric = TRUE)
      updatePickerInput(session, "subselect2.a",label="ICES Division", choices=x,selected = x)
      
    }
  }
})

#Filter based on Area
grspnew.a1<- reactive({
    if(input$Id.a=="ICES Area"){
        grspageSub = filter(grspage(), ICESSubArea %in% input$subselect.a)
    }else{
        grspageSub <- filter(grspage(), ICESDivFullNameN %in% input$subselect2.a)}
  
})

####Age Data downloader
output$downloadDatala <- downloadHandler(
    filename = function() {
        paste(input$species, "-LAdata", ".csv", sep = "")
    },
    content = function(file) {
        #write.csv(grspnew.a1(), file, row.names = FALSE)
        write.csv(cc.a(), file, row.names = FALSE)
    })

output$bio_la<- renderPlotly({
  
    validate(need(nrow(grspnew.a1()) > 0, "No data to plot for the selected parameters"))
    # Max number of points we will plot on a chart - for performance reasons
    maxPointsToPlot <- 10000 
    myAnnotation <- ''
    # Set ranges for axes
    minX <- 0
    maxX <- max(grspnew.a1()$Age)+1
    minY <- min(grspnew.a1()$Length)-1
    maxY <- max(grspnew.a1()$Length)+1

    if(input$ageoptionselection=="Sex"){
      
      grspnew.a1 <- filter(grspnew.a1(), !is.na(Sex))
      validate(need(nrow(grspnew.a1) > 0, "No data to plot for the selected parameters"))
      # if there's a lot of data to plot just plot a sample of it
      if (nrow(grspnew.a1)> maxPointsToPlot){
        grspnew.a1 <- grspnew.a1[sample(nrow(grspnew.a1), maxPointsToPlot), ]
        myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
      } 
      
        p <- plot_ly(grspnew.a1, x = ~Age , y =~Length,
                     type = 'scatter', mode = 'markers',hoverinfo='text',
                     text=~paste("length:",Length,"cm","<br>age:",Age, "<br>date:", Date, "<br>sex:", Sex), 
                     color = ~Sex, colors = "Set1",
                     mode = 'markers') %>% 
            layout(hovermode='closest', title=paste(input$species,"length at age (points coloured by sex)"),
                   xaxis = list(title = 'Age', range= c(minX, maxX), showline = TRUE),
                   yaxis = list(title = 'Length (cm)', range= c(minY, maxY), showline = TRUE),
                   annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                   margin=(list(t=50)),
                   showlegend = TRUE) 
        p$elementId <- NULL
        p 
    }else if(input$ageoptionselection=="Presentation"){
        grspnew.a1 <- filter(grspnew.a1(), !is.na(Presentation))
        validate(need(nrow(grspnew.a1) > 0, "No data to plot for the selected parameters"))
        # if there's a lot of data to plot just plot a sample of it
        if (nrow(grspnew.a1)> maxPointsToPlot){
          grspnew.a1 <- grspnew.a1[sample(nrow(grspnew.a1), maxPointsToPlot), ]
          myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
        } 
        
        p <- plot_ly(grspnew.a1, x = ~Age, y = ~Length, 
                     type = 'scatter', mode = 'markers',hoverinfo='text',
                     text=~paste("length:",Length,"cm","<br>age:",Age, "<br>date:", Date, "<br>presentation:", Presentation),
                     color= ~Presentation,colors = "Dark2") %>%  
            layout(hovermode='closest',
                   title=paste(input$species,"length at age (points coloured by presentation)"),
                   xaxis = list(title = 'Age', range= c(minX, maxX), showline = TRUE),
                   yaxis = list(title = 'Length (cm)', range= c(minY, maxY), showline = TRUE),
                   annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                   margin=(list(t=50)),
                   showlegend = TRUE) 
        p$elementId <- NULL
        p 
    }else if(input$ageoptionselection=="Sample Type"){
        grspnew.a1 <- filter(grspnew.a1(), !is.na(Type))
        validate(need(nrow(grspnew.a1) > 0, "No data to plot for the selected parameters"))
        # if there's a lot of data to plot just plot a sample of it
        if (nrow(grspnew.a1)> maxPointsToPlot){
          grspnew.a1 <- grspnew.a1[sample(nrow(grspnew.a1), maxPointsToPlot), ]
          myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
        } 
        
        p <- plot_ly(grspnew.a1, x = ~Age, y = ~Length,
                     type = 'scatter', mode = 'markers',hoverinfo='text',
                     text=~paste("length:",Length,"cm","<br>age:",Age, "<br>date:", Date, "<br>sample type:",Type),
                     color= ~Type,colors =c('Discards'='red','Landings'='lightgreen')) %>%  
            layout(hovermode='closest',
                   title=paste(input$species,"length at age (points coloured by sample type)"),
                   xaxis = list(title = 'Age', range= c(minX, maxX), showline = TRUE),
                   yaxis = list(title = 'Length (cm)', range= c(minY, maxY), showline = TRUE),
                   annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                   margin=(list(t=50)),
                   showlegend = TRUE) 
        p$elementId <- NULL
        p 
    }else if(input$ageoptionselection=="Gear"){
        grspnew.a1 <- filter(grspnew.a1(), !is.na(Gear))
        validate(need(nrow(grspnew.a1) > 0, "No data to plot for the selected parameters"))
        # if there's a lot of data to plot just plot a sample of it
        if (nrow(grspnew.a1)> maxPointsToPlot){
          grspnew.a1 <- grspnew.a1[sample(nrow(grspnew.a1), maxPointsToPlot), ]
          myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
        } 
        
        p <- plot_ly(grspnew.a1, x = ~Age, y = ~Length,
                     type = 'scatter', mode = 'markers',hoverinfo='text',
                     text=~paste("length:",Length,"cm","<br>age:",Age, "<br>date:", Date, "<br>gear type:",Gear),
                     color= ~Gear,colors = "Set1") %>%  
            layout(hovermode='closest',
                   title=paste(input$species,"length at age (points coloured by gear type)"),
                   xaxis = list(title = 'Age', range= c(minX, maxX), showline = TRUE),
                   yaxis = list(title = 'Length (cm)', range= c(minY, maxY), showline = TRUE),
                   annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                   margin=(list(t=50)),
                   showlegend = TRUE) 
        p$elementId <- NULL
        p 
    }else{
      grspnew.a1 <- grspnew.a1()
      validate(need(nrow(grspnew.a1) > 0, "No data to plot for the selected parameters"))
      # if there's a lot of data to plot just plot a sample of it
      if (nrow(grspnew.a1)> maxPointsToPlot){
        grspnew.a1 <- grspnew.a1[sample(nrow(grspnew.a1), maxPointsToPlot), ]
        myAnnotation <- paste0("Only ",maxPointsToPlot," points are plotted - full data available via 'Download data'")
      } 
      
        p <- plot_ly(grspnew.a1, x = ~Age, y = ~Length,
                     hoverinfo='text',
                     type = 'scatter', mode = 'markers', marker =list(opacity = 0.5,color = 'black'),
                     text=~paste("length:",Length,"cm","<br>age:",Age, "<br>date:", Date))%>% 
                     #text=~paste("Age:",Age,"<br>Mean Length:",Length,"cm"))%>% 
            layout(hovermode='closest',
                   title=paste(input$species,"length at age"),
                   xaxis = list(title = 'Age', range= c(minX, maxX) ,showline = TRUE),
                   yaxis = list(title = 'Length (cm)', range= c(minY, maxY), showline = TRUE),
                   annotations = list(text = myAnnotation,  x = (minX +maxX)/2, y = maxY * 0.99 ,showarrow=FALSE, font = list(size = 10)),
                   margin=(list(t=50)),
                   showlegend = FALSE)
        p$elementId <- NULL
        p
    }
})    
}
)