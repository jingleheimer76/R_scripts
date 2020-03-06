
#get the eniro set

library(reshape2)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(sqldf)
library(RODBC)
library(tcltk)
library(FastKNN)

#take a data frame, look at it, turn it into a tibble

iris

irist<- as_tibble(iris)

irist

view(iris)

view(irist)


#take a vector of integers 1 - 5 and combine it with 1 and the result of a formula

tibble(
  x = 1:5,
  y = 1,
  z = x^2 + y
)

#now make a tibble of 1000 (1e3) rows, with lables
# a random number (default between 0 and 1)
# a random sample of all the letters (w/replacement) 
# a random sample of the dates within 30 days from now
# a random sample of the times within 1 day (24 hours from now)

samptib <- tibble(
  rownum = 1:1000,
  randunm = runif(1e3),
  randlet = sample(letters, 1e3, replace = TRUE), 
  randday = lubridate::today() + runif(1e3) * 30,
  randtime = lubridate::now() + runif(1e3) * 60 * 60 * 24
)
  
#now write that to a csv to keep for importing later! (btw, check out these pipes)
tibble(
  rownum = 1:1000,
  randunm = runif(1e3),
  randlet = sample(letters, 1e3, replace = TRUE), 
  randday = lubridate::today() + runif(1e3) * 30,
  randtime = lubridate::now() + runif(1e3) * 60 * 60 * 24
) %>% write.csv("samples.csv")

#read.csv takes the characters and dates and turns them in to f'ing factors
#Since you *NEVER* want that, use read_csv instead. Thanks tidyverse

#either command will default to the working dir

sampcsv <- read.csv("samples.csv")

sampcsv2 <- read_csv("samples.csv")

view(sampcsv, title = 'CSVed')

view(samptib, title = "orig")

#common arguments you'll need to use are:
# read_csv([data], skip = [n], comment = [a], colnames = [False]/c("name1", "name2",...), na = [a])

#read in a csv that has some ugly issues - rows with all nulls a column with a "%" character meaning it 
#comes in as a character vectory

CHAN <- read_csv("Data/GuestxChannel_2.csv")

view(CHAN)

#now let's get rid of the nulls and convert "Channel_Guest_PCT" to a double (not a character)

CHAN <- mutate(CHAN, CHAN_PCT = as.numeric(gsub("%", "", Channel_Guest_Pct))/100)

CHAN <- CHAN %>% filter(!is.na(TXN_DATE_ID))

#now calc the sub totals of guest trips by day and 

#create ur groups - here by day, but could do week too
CHAN <- group_by(CHAN, TXN_DATE_ID)

#calc each day over the total by the group
CHAN <- mutate(CHAN, DayPct = NM_GUEST_CNT/sum(NM_GUEST_CNT))

CHAN <- ungroup(CHAN)

#better yet, just get all that good, good Azure data in and never f-around with 
#eporting to a csv and running read_csv


###### START: RELOAD AZURE CONNECTION ######
F_NET <- function()
{
  RODBC::odbcCloseAll()
  Connection_Azure <<- odbcConnect("AZURE_PROD")
}

########## START:  Execute a T-SQL QUERY and return it as a DF
F_EXECUTE_AZURE_QUERY <- function(sql)
{
  F_NET()
  query <- paste(sql)
  result <- sqlQuery(Connection_Azure, query, believeNRows=FALSE)
  return (result)
}

# Execute SQL Query: Enter any query here and it will execute against azure prod and return a dataframe
FISCAL_WEEK_LOOKUP = F_EXECUTE_AZURE_QUERY(
  "
  SELECT DISTINCT FISCAL_YEAR_NUM * 100 +FISCAL_WEEK AS LOOKUP_NO_TRANSFORM, FISCAL_YEAR_NUM AS FISCAL_YEAR, FISCAL_WEEK AS FISCAL_WEEK FROM [CRM_ANALYTICS].[DIM_DATE] 
  "
)
Collapse

