# Initialize data sets for UI

library(shiny)
library(sqldf)

# UI
shinyUI(pageWithSidebar(
  headerPanel("PS4 vs XBox One Cross-platform Comparison"),

  sidebarPanel(

    
    checkboxGroupInput("genreselect","Navigate to the 'XGenre' tab and check the game genres you are interested in comparing:",
                       choices = c("Action","Adventure","Construction","Fighting","Horror","Life Simulation","MMO","Music","Platform",
                                   "Puzzle","Racing","Role-Playing","Shooter","Sports","Stealth","Unspecified" ),
                       selected = c("Adventure","Fighting","Racing","Shooter","Sports")),
    
    checkboxGroupInput("esrbselect","Navigate to the 'ESRB' tab and check the game ratings you are interested in comparing:",
                       choices = c("E - Everyone","M - Mature","RP - Rating Pending","T - Teen","Unspecified"),
                       selected = c("E - Everyone","M - Mature","T - Teen"))    

#   ,
#   submitButton('Submit')
    
    ),
  
  mainPanel( 
    

    
    p("It's been about 15 months since we've been comparing Sony's Playstation 4 and Microsoft's XBox One. 
      One of the most important considerations for those still lingering on which console to buy is the selection 
      of games. This interactive application allows users to run some simple analysis that may help them make 
      that decision."),
    p("Data for this project was extracted from ", a("TheGamesDB.net", href="http://thegamesdb.net/",
                                                     target = "_blank"), " on February 5, 2015."),
    
    tabsetPanel(
      tabPanel("XPlatform",
               
               # XPlatform
               h4("XPlatform Summary"),
               selectInput("charttype1", "Toggle chart type:",
                           choices = c("Stacked","Clustered")),
               htmlOutput("xplatform"), 
               br(),
               p("Definitions:"),
               p(strong("exclusive")," = game is only avialable for the single specified platform"),
               p(strong("xplatform"), "= cross-platform; game is available on both platforms")
               ),
               
      tabPanel("XGenre",           
      
               # XGenre
               h4("XGenre Summary"),
               selectInput("charttype2", "Toggle chart type:",
                           choices = c("Clustered","Stacked")),      
               p("Check boxes in the left panel to view specific genres."),      
               htmlOutput("xgenre"),
               br(),
               p("Definitions:"),
               p(strong("both")," = games avialable on both platforms"),
               p(strong("ps4"), "= games exclusive to PS4"),
               p(strong("xb1"), "= games exclusive to XB1")
               ),
               
               
      tabPanel("ESRB",
               
               # ESRB
               h4("ESRB Ratings Summary"),
               # Toggle chart type
               selectInput("charttype3", "Toggle chart type:",
                           choices = c("Stacked","Clustered")), 
               # Toggle platform/ratings
               selectInput("xaxisinput", "Toggle x-axis:",
                           choices = c("Platform","Ratings")),
               p("Check boxes in the left panel to view specific ESRB ratings."),
               htmlOutput("xesrb"), 
               br(),
               p("Definitions:"),
               p(strong("both")," = games avialable on both platforms"),
               p(strong("ps4"), "= games exclusive to PS4"),
               p(strong("xb1"), "= games exclusive to XB1"),
               p(strong("ESRB"),"= for more information about ESRB ratings",
               a("click here", href="http://www.esrb.org/ratings/ratings_guide.jsp",target = "_blank"))
               ),
      
      tabPanel("Inventory",
               
               # Game Inventory 
               h4("Game Inventory"),
               selectInput("gamesperpage", "Games per page:",
                             choices = c(10,25,50,100,"All")),
               htmlOutput("inventoryTable")
               )
      
      
      )  )
    
))
