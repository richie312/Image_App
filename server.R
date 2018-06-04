


library(shiny)
library(shinythemes)
library(keras)

library(dplyr)
library(wordcloud2)
library(tm)
library(RColorBrewer)
library(mgcv)
library(ggplot2)


## Current Working directory
##setwd("C:/Users/Richie/Desktop/Image_App")

## Download the below pretrained mdoels from the internet
#model_resnet<- application_resnet50(weights = 'imagenet')
#model_vgg16<-application_vgg16(weights="imagenet", include_top = FALSE)
#model_inception<-application_inception_v3(weights = "imagenet")

## Load the previously saved models

model_resnet<-load_model_hdf5(file = "model_resnet")
model_inception<-load_model_hdf5(file = "model_inception")



server<-shinyServer(function(input,output){
  
  

output$image<-renderImage({
  par(bg="#F5EEF8")
  src=input$file
  src=src$datapath
  if(is.null(src)){
    return(list(src=as.character(paste(input$Image_class)), height="350"))
  }
    else{
      return(list(src=src, height="350"))
    }
    
  },deleteFile = FALSE)
  

## Load the image

  

output$word<-renderWordcloud2({file1<-input$file



image_path<-if(is.null(file1$datapath)){as.character(paste(input$Image_class))}else{file1$datapath}

img<-image_load(image_path, target_size=c(224,224))


x<-image_to_array(img)


## Reshape the image

x<-array_reshape(x,c(1,dim(x)))
x<-if(input$Model == "resnet50"){
  imagenet_preprocess_input(x)}
else{inception_v3_preprocess_input(x)}

## Make the prediction with imagenet pretrained model


preds<-if(input$Model == "resnet50"){
  model_resnet%>%predict(x)
  }
else{
  model_inception%>%predict(x)
}


## Decode the label_text

main = imagenet_decode_predictions(preds, top = 6)[[1]]
text<-main$class_description


## WordCloud

Corpus=Corpus(VectorSource(text))
Corpus=tm_map(Corpus,content_transformer(tolower))

myDTM = TermDocumentMatrix(Corpus)
m = as.matrix(myDTM)
v = sort(rowSums(m), decreasing = TRUE)
d<-data.frame(word=names(v),freq=v)
## WordCloud

wordcloud2(data = d,size=input$Font,color=as.character(paste(input$color)))


})


output$ggplot<-renderPlot({
  file1<-input$file
  image_path<-if(is.null(file1$datapath)){as.character(paste(input$Image_class))}else{file1$datapath}
  img<-image_load(image_path, target_size=c(224,224))
  x<-image_to_array(img)
  
  ## Reshape the image
  
  x<-array_reshape(x,c(1,dim(x)))
  x<-if(input$Model == "resnet50"){
    imagenet_preprocess_input(x)}
  else{inception_v3_preprocess_input(x)}
  
  ## Make the prediction with imagenet pretrained model
  preds<-if(input$Model == "resnet50"){
    model_resnet%>%predict(x)
  }
  else{
    model_inception%>%predict(x)
  }
  
  
  ## Decode the label_text
  
  main = imagenet_decode_predictions(preds, top = 6)[[1]]
  
  ## plot with ggplot2
  par(bg="#F5EEF8")
  ggplot(data=main,aes(x=reorder(class_description,score), y=score))+
    geom_bar(stat = "identity", width = 0.5, fill="#F6862F")+
    coord_flip()+
    scale_color_brewer()+
    ggtitle("Probable object with scores")+
    xlab("Probable Objects")+
    ylab("score")+
    theme(panel.border = element_blank(), 
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.title = element_text(hjust = 0.5,size=18,colour="indianred4"),
          axis.line = element_line(colour = "black"))+
    theme(legend.position="none")
  
})

}
)