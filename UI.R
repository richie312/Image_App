
library(shiny)
library(shinythemes)
library(keras)
library(knitr)

library(dplyr)
library(wordcloud2)
library(tm)
library(RColorBrewer)
library(mgcv)
library(ggplot2)
library(markdown)

shinyUI(fluidPage(theme = shinytheme('cerulean'),
                  
        navbarPage(  title = "Image Classification with Pre-trained Models",  
                     id= "nav",
                     tabPanel("Image", value ="Image",
    fluidRow(style="background-color:white;",
      column(6
             , fluidRow(
               column(6, br(),
                      fileInput(inputId = "file",label = "File", buttonLabel="Upload Image",
                                   accept = c(
                                     ".jpg",
                                     ".jpeg",
                                     ".png")),
                      helpText("Default max. file size is 10MB"),
                      
                      helpText(h5("This Application is preloaded with few images for the detection"))
                      , div(style = "height:100px;"))
               , column(6, br(),
                        selectInput(inputId = "Model", label = "Model", 
                                       choices = c("resnet50","inception"),
                                       selected = "inception"),
                        br(),
                        helpText(h5("Keras is a user-friendly neural networks API. This application uses the ResNet50 & Inception V3 model, with weights pre-trained on ImageNet.")),
                        
                        div(style = "height:100px;"))),
              fluidRow(
               column(12,
                      helpText(h3("Word Cloud for the image object",style="color:#C0392B")),
                      
                      column(4,radioButtons(inputId="color", label = "Select color", choices =c("random-light","random-dark"),selected='random-light')),
                      column(4 ,sliderInput(inputId="Font",label="Font Size",min=0, max=1, value = 0.5)),
                      wordcloud2Output(outputId="word",width="450px",height="600px")
                      ,
                      div(style = "height:600px;"))
             )
      )
      , column(6,
               helpText(h3("Image Preview",style="color:#C0392B")),
               selectInput(inputId="Image_class",label="Select Image",choices=c("RaspberryPi.jpg","Cup.jpg","Cat.jpg","Dog.jpg","Bruno(Robot).jpg"),selected="RaspberryPi.jpg"),
               br(),
               imageOutput(outputId="image", width="600px", height="350px"),
               br(),br(),
               helpText(h3("Bar Plot for the image object.", style="color:#C0392B")),
               plotOutput(outputId="ggplot"), 
               
               div(style = "height:600px;"))
    )
  ),
  tabPanel("Links & Videos",value = "Resources",
           fluidRow(column(12,style="background-color:#D5F5E3;",
                           includeMarkdown("resources.rmd")))
           
           
        )
     )
  )
)

