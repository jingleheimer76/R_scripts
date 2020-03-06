#commented code for working through O'Reilley's R for data science


#setting some things up (tidyvers was already installed)

library(sqldf)

library(tidyverse)

library(lubridate)

library(dplyr)


#look at the tibble data native in ggplot
mpg

sqldf("select * from mpg 
      where year > 2000")

#base code from which to plot, call ggplot and point it at data; then specify the
#type of graph with a geom functon and give that function the mapping through the 
#aesthetic aes arguements:
#ggplot(data = <DATA>) + 
#  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))


#classic point scatter plot is called by geom_point

ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy))

#add an additional aesthetic, color, to the above plot (color, shape, size, alpha)

ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, color = trans))

# run multiple plots with different filter usine facets. facets take 'formulas',
# signified by tildes. In the case below the formula is just a categorical data
# var you can think of tilde like an operator in the sense of 'class vs. cyl'

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~class)

#split the facet along two categories w/facet_grid

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(class ~ cyl)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(. ~ class)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(class ~ .)

# orig plot but changing the geom to smooth(

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x=displ, y = hwy))

# now just add additonal geoms to the same plot to get a dope graphongraph

ggplot(data = mpg)+ 
  geom_smooth(mapping = aes(x=displ, y=hwy)) +
  geom_point(mapping = aes(x = displ, y = hwy))

# be more efficient and set the mappings alongside the data(

ggplot(data= mpg, mapping = aes(x=displ, y=hwy)) +
  geom_smooth() +
  geom_point()

#explore a new data set
diamonds

sqldf("select * 
      FROM diamonds
      where price > 400")

# bar charts will default the stat to counts 

ggplot(data = diamonds, mapping = aes(x= cut)) + 
  geom_bar()

#data transformation practice

#looks like new tidyvers doesn't have the flights dataset native ...

#install.packages("nycflights13")
library(nycflights13)

#xplore data

view(flights)

# use the filter function with operators <, <=, >, >=, !=, == (near is better than ==)

filter(flights, month == 1, day == 1)

#drop that data in to an object jan1

jan1 <- filter(flights, month == 1, day == 1)
jan1


#use %in% for looking in a vector

nov_dec <- filter(flights, month %in% c(11, 12))
nov_dec

#these and statements are equivalent

filter(flights, arr_delay <= 120, dep_delay <= 120)

filter(flights, arr_delay <= 120 & dep_delay <= 120)


#nulls are know as NA in R; use is.na() as the test

is.na(x)

#exercises
#find all flights that had a delay of two or more hours

filter(flights, arr_delay >= 120)

#find flight that flew to Houston HOU or IAH

filter(flights, dest %in% c('IAH', 'HOU'))

#arrived more than 2 hrs late but didn't leave late
filter(flights, dep_delay <= 0 & arr_delay > 120)

#flights have missing dep time
filter(flights, is.na(dep_time))


#use arrange to sort

arrange(flights, desc(dep_delay))


arrange(flights, desc(month), day)


#mutate adds new data columns; transmute creates new data table
#use %/% - division rounded to integer and %% remainder to change base 
#this example creates a new table with the number of minutes from midnight

transmute(flights, dep_time, minfmid = dep_time %/% 100 *60 + dep_time %% 100 )

#test saving stuff
install.packages("hexbin")

library(tidyverse)

library(hexbin)

getwd()

ggplot(diamonds, aes(carat, price)) +
  geom_hex()

ggsave("diamons.pdf")
write.csv(diamonds, "diamonds.csv")


#try out causal impact 

library(CausalImpact)



#create a sample data set using some stuff that makes it time series
set.seed(1)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y <- 1.2 * x1 + rnorm(100)
y[71:100] <- y[71:100] + 10
data <- cbind(y, x1)


glimpse(data)

data

data2 <- tibble(data)

glimpse(data2)
data2

rm(data2)

#now tibble up that data
data2 <- tibble( period = 1:100, y = y, x = x1)

#run the impact model on the orginal frame
impact <- CausalImpact(data, c(1,70), c(71,100))
plot(impact)

#now try it on the tibble ... causal impact doesn't know the first column is the time serices ...
impact2 <- CausalImpact(data2, c(1,70), c(71,100))
plot(impact2)

#remove that column and try again ... it works - must use the row number of the tibble as the time value 
#next try with dates
data3 <- dplyr::select(data2, y, x)

impact3 <- CausalImpact(data3, c(1,70), c(71,100))
plot(impact3)
