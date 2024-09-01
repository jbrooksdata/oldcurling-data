install.packages("tidyverse")
install.packages("jsonlite")
install.packages("rvest")
library(tidyverse)
library(jsonlite)
library(rvest)

# scrape dates from history; same format as api url
dates_url = 'https://doubletakeout.com/history'
page = read_html(dates_url)
dates = page %>% html_nodes("td:nth-child(2)") %>% html_text()

rankings <- data.frame()

for(i in dates){
  
  url <- paste0("https://doubletakeout.com/api.php?t=women&d=",i)
  data <- fromJSON(url)
  players <- data$Player
  
  bind <- bind_cols(i,players)
  
  rankings <- bind_rows(rankings, bind)
}

colnames(rankings)[1] <- 'Date'

csv_file <- "data/womensRankings.csv"
existing_data <- read.csv(csv_file)
# return rows with new dates
new_data <- subset(rankings, !(Date %in% existing_data$Date))

if (nrow(new_data) > 0) {
  write.table(
    new_data, 
    file = csv_file, 
    sep = ",", 
    row.names = FALSE, 
    col.names = FALSE,  # Don't write column names again
    append = TRUE
  )
} else {
  message("No new data.")
}
