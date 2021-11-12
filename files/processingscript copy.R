###############################
# processing script
#
#this script loads the raw data, processes and cleans it 
#and saves it as Rds file in the processed_data folder

# load needed packages. make sure they are installed.
library(readr) #for loading Excel files
library(dplyr) #for data processing
library(here) #to set paths

# path to data
# note the use of the here() package and not absolute paths
dataSPOT <- here::here("files","SympAct_Any_Pos.Rda")

# load data. 
rawdata <-readRDS(dataSPOT)

# take a look at the data
dplyr::glimpse(rawdata)


# Wrangling-------------------------------------------------------------------------------------

# Remove the following variables; 
# Anything with Score, Total, FluA, FluB, Dxname or Activity in the name
# Unique.Visit

# removing columns with Dxname, Unique.Visit & Activity
data <- rawdata %>% select(-c(1:8, 41:63))
dplyr::glimpse(data) # 32 variables

# Remove any NA observations
processeddta <- data %>% na.omit()
dplyr::glimpse(processeddta) # 730 observations


# Pre-processing-------------------------------------------------------------------------------------

# Feature/Variable removal
# Here we are going to remove the binary version of Weakness, Cough and Myalgia variables
data1 <- processeddta %>% select(-c("CoughYN", "WeaknessYN", "MyalgiaYN", "CoughYN2"))

#Order Weakness, Cough and Myalgia variables as factorial
str(data1) # It appears they are already in factor format, but to make sure they are ordinal we will write some code
data1$CoughIntensity <- ordered(data1$CoughIntensity, levels = c("None", "Mild", "Moderate","Severe"))
data1$Weakness <- ordered(data1$Weakness, levels = c("None", "Mild", "Moderate","Severe"))
data1$Myalgia <- ordered(data1$Myalgia, levels = c("None", "Mild", "Moderate","Severe"))
str(data1)

#Removing low (“near-zero”) variance predictors
#Identifying those BINARY variables with <50 responses in each category ussing summary function
summary(data1) 
#Hearing has only 30 Yes responses
#Vision only has 19 Yes responses
processeddta <- data1 %>% select(-c("Vision", "Hearing"))


# location to save file
save_data_location <- here::here("files","processeddta.rds")
saveRDS(processeddta, file = save_data_location)

