library(dplyr)
library(tidyr)         
library(ggplot2)
library(reticulate)

setwd("U:\\PhD\\Spyder\\QuantPlotter2")
filepath <- "U:\\PhD\\Experimental_data\\qPCR\\2984_TM_21"

source_python("ConvertXLSX.py")
csvnames <- convertAllFiles(filepath)

#Importing the fluorescence data.

rncsvfull <- read.csv(csvnames[1])
rncsv <- subset(rncsvfull, select = -c(6,7,8,9))
rncsv$Well <- as.factor(rncsv$Well)
#Importing the CT values and converting them into numerics for later.

ctcsv <- read.csv(csvnames[2])
ctcsv$Well <- as.factor(ctcsv$Well)
ctcsv$CT <- as.factor(ctcsv$CT)
levels(ctcsv$CT)[levels(ctcsv$CT)=="Undetermined"] <- 0
ctcsv$CT <- as.double(paste(ctcsv$CT))

#Combining with a left join to keep the original dataset and simply append
#the CT values where the wells have been used.
rncsv_with_ct <- left_join(rncsv, ctcsv, by = c("Well" = "Well"))

#Working out the min and max to equalise the graphs.
#max_delta_rn <- max(rncsv_with_ct$Delta.Rn)
max_delta_rn <- 0.7
min_delta_rn <- 0

setwd(paste(filepath))

well_in <- c(1,2)
while (well_in[2] < 96) {
  well_subset <- filter(rncsv_with_ct, Well %in% well_in)
  
  if (any(is.na(well_subset$Rn))) {
    well_in <- well_in + 2
    next
  } else {
    
    well_subset$Well <- as.numeric(well_subset$Well)
    
    #Getting CTs for each well, as the table has multiple of each well.
    grouped_by_wells <- group_by(well_subset, Well)
    CTs <- summarise(grouped_by_wells, CT = max(CT), Sample.Name = Sample.Name)
    
    #Generating a set of labels from the subsetted data.
    CT_labels <- data.frame(labels = c(CTs$CT), Well = c(CTs$Well))
    titlevector <- as.character(CTs$Sample.Name)
    titlestring <- unique(titlevector)
    
    #Plotting a line graph...
    cycleplot <- ggplot(data=well_subset, aes(x=Cycle, y=Delta.Rn)) +
      geom_line() +
      #Setting the y axis to show 1 to 40.
      scale_x_continuous(breaks = well_subset$Cycle, labels = well_subset$Cycle) +
      #Setting the x axis to always be from min to max, approximately.
      coord_cartesian(ylim = c(min_delta_rn,max_delta_rn), expand= TRUE) +
      facet_wrap(~ Well, ncol = 2) +
      ggtitle(paste0(titlestring, collapse = " ")) +
      theme_dark() +
      geom_label(data = CT_labels, mapping = aes(x=5, y= (max_delta_rn - 0.1), label = labels))
    
    #And adding the CT values as a label for clarity.
    
    ggsave(file = paste0(well_in[1], "_", well_in[2], ".pdf"), dev = "pdf", plot = cycleplot)
    
    well_in <- well_in + 2
  }
}