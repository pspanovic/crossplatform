
library(googleVis)
library(shiny)
library(sqldf)

# Initialize
ds = read.csv("data/dataset.csv")
game_platform = sqldf("select Game, 
                              case when Platform = 'Both Platforms' then 1 else 0 end as both,
                              case when Platform = 'PS4 Exclusive' then 1 else 0 end as ps4,
                      case when Platform = 'Xbox One Exclusive' then 1 else 0 end as xb1
                      from ds")
exclusives =sqldf("select 'PS4' as platform, sum(ps4) as exclusive, sum(both) as xplatform from game_platform
                  union all
                  select 'XB1' as platform, sum(xb1) as exclusive, sum(both) as xplatform from game_platform")
genre_platform = sqldf("select case when Genre = 'Construction an...' then 'Construction'
                                    when Genre = 0 then 'Unspecified' else Genre end as Genre,
                                sum(case when Platform = 'Both Platforms' then 1 else 0 end) as both,
                       sum(case when Platform = 'PS4 Exclusive' then 1 else 0 end) as ps4,
                       sum(case when Platform = 'Xbox One Exclusive' then 1 else 0 end) as xb1
                       from ds
                       group by 1")  

esrb_platform = sqldf(" select case when ESRB = 0 then 'Unspecified' 
                    when ESRB like 'E%' then 'E - Everyone' else ESRB end as ESRB, 
                    sum(case when Platform = 'Both Platforms' then 1 else 0 end) as both,
                    sum(case when Platform = 'PS4 Exclusive' then 1 else 0 end) as ps4,
                    sum(case when Platform = 'Xbox One Exclusive' then 1 else 0 end) as xb1
              from ds group by 1")

platform_esrb =  sqldf("select Platform,
                        sum(case when ESRB like 'E%' then 1 else 0 end) as Everyone,
                        sum(case when ESRB like 'M%' then 1 else 0 end) as Mature,      
                        sum(case when ESRB like 'RP%' then 1 else 0 end) as RP,
                        sum(case when ESRB like 'T%' then 1 else 0 end) as Teen,
                        sum(case when ESRB = 0 then 1 else 0 end) as Unspecified
                  from ds
                  group by 1
                        ")
# unspecified years are empty
ds2 = sqldf("select Game, Platform, case when Year >= 2013 then Year end as Year,
                                    case when Genre = 0 then 'Unspecified' else Genre end as Genre,
                                    case when ESRB = 0 then 'Unspecified' else ESRB end as ESRB
            from ds")

# Server
shinyServer(
    function(input, output) {
      
      # Interactive toggles controlling the type of bar graph
      charttypeInput1 <- reactive({        
        switch(input$charttype1,
               "Stacked" = TRUE,
               "Clustered" = FALSE)        
      })
      
      charttypeInput2 <- reactive({        
        switch(input$charttype2,
               "Stacked" = TRUE,
               "Clustered" = FALSE)        
      })
      
      charttypeInput3 <- reactive({        
        switch(input$charttype3,
               "Stacked" = TRUE,
               "Clustered" = FALSE)        
      })
      

      
      # Cross platform comparison
      output$xplatform <- renderGvis({
        gvisColumnChart(exclusives, options = list(isStacked = charttypeInput1(),
                                                   legend = 'bottom',
                                                  # chartArea = '{left:10,top:0,width:"50%",height:"75"}',
                                                   vAxis = "{title: '# Games', titleTextStyle: {color: '#2E64FE'}}"
                                                   ))   })
      # Check box input for game genre comparison
      genreInput <- reactive({input$genreselect})  
      output$xgenre <- renderGvis({
        gvisColumnChart(subset(genre_platform, Genre %in% genreInput()), 
                        options = list(isStacked = charttypeInput2(),
                                       legend = 'bottom',
                                       vAxis = "{title: '# Games', titleTextStyle: {color: '#2E64FE'}}"
                                       ))   })

      # Check box input for ESRB ratings
      xaxisInput <- reactive({
        switch(input$xaxisinput,
               "Ratings" = esrb_platform,
               "Platforms" = platform_esrb)
      })
      
      esrbInput <- reactive({input$esrbselect})

      
      output$xesrb <- renderGvis({
        
        if (input$xaxisinput == "Ratings") {
          gvisColumnChart(subset(xaxisInput(), ESRB %in% esrbInput()), 
                         options = list(isStacked = charttypeInput3(),
                                         legend = 'bottom',
                                         vAxis = "{title: '# Games', titleTextStyle: {color: '#2E64FE'}}"
                        )) }
        
        else {
          gvisColumnChart(subset(platform_esrb, select = c(Platform, if("E - Everyone" %in% esrbInput()) {Everyone} else {c()},
                                                           if("M - Mature" %in% esrbInput()) {Mature} else {c()},
                                                           if("RP - Rating Pending" %in% esrbInput()) {RP} else {c()},
                                                           if("T - Teen" %in% esrbInput()) {Teen} else {c()},
                                                           if("Unspecified" %in% esrbInput()) {Unspecified} else {c()})),
                          options = list(isStacked = charttypeInput3(),
                                         legend = 'bottom',
                                         vAxis = "{title: '# Games', titleTextStyle: {color: '#2E64FE'}}"))
              }
      })
      
      # Interactive table to view game inventory
      pageOptions <- reactive({
        list(
          page=ifelse(input$gamesperpage=="All",'disable','enable'),
          pageSize=ifelse(input$gamesperpage=="All",200,input$gamesperpage)
        )
      })
      output$inventoryTable <- renderGvis({
        gvisTable(ds2, options = pageOptions())
      })


  })
