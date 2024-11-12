library(RODBC)
library(plyr)
library(dplyr)
library(lubridate)
library(plotly)

Q1<- "select *
from dbo.SpeciesResultSetExpanded
where ltrim(rtrim(Species)) in 
('Herring','Mackerel','Black-bellied Anglerfish',
'Blue Whiting','Boarfish',
'Cod','Haddock','Hake',
'Horse Mackerel', 'Sole','Ling','Megrim','White-bellied Anglerfish',
'Plaice','Pollack',
'Saithe','Sole','Sprat','Whiting');"

# Load our server and database details (not included in Git)
# This is the format of the ConnectionDetails.R file:
# ConnectionDetails <- list(server = "serverName", database = "databaseName")
source("data-raw/ConnectionDetails.R")
conString <- paste0("Driver=SQL Server; Server=",ConnectionDetails[['server']],"; Database=",ConnectionDetails[['database']])

# Connect to the database
channel <- odbcDriverConnect(conString)
SDdata<- sqlQuery(channel,Q1)

# keep a back-up of original results before any changes are made layter
SDdata_backup<-SDdata


###################################################

####Some of the species in table SpeciesResultSetExpanded changed since last updates data in 2019#####
####use Species table to compare names
Q2<- "
SELECT *
FROM [dbo].[Species]"
sp<-sqlQuery(channel,Q2)

close(channel)


sp$CommonName <- trimws(sp$CommonName)##remove white space
com_sp<-filter(sp,CommonName%in%c("White-bellied Anglerfish","Cod","Herring",
"Horse Mackerel","Mackerel",
"Saithe","Black-bellied Anglerfish","Blue Whiting","Boarfish",
"Ling","Sole",
"Hake","Sprat","Plaice",
"Pollack","Haddock","Megrim","Whiting"))
com_sp[c(3,22,24,28)]



####### Formatting #######

SDdata$Species <- trimws(SDdata$Species)
levels(as.factor(SDdata$Species))
head(SDdata) #check white space removed

# Source data is filtered in Q1 at start of script
# SDdata<-SDdata[SDdata$Species %in% c("Atlantic Herring","Atlantic Mackerel","Blackbellied Angler",
#                                      "Blue Whiting","Boarfish",
#                                      "Atlantic Cod","Haddock","European Hake",
#                                      "Atlantic Horse Mackerel", "Lemon Sole","Common Ling","Megrim","Angler",
#                                      "European Plaice","Green Pollack",
#                                      "Billet","Common Sole","European Sprat","Whiting"),]

SDdata$Species <- droplevels(as.factor(SDdata$Species)) #drop empty levels of species


####### Complete Cases #######
### Length ###
bio.data.length <- SDdata
dataV2 <- bio.data.length[!is.na(bio.data.length$Length),] 
dataV3 <- dataV2[!is.na(dataV2$Weight),]
dim(dataV3)
cc.length <- dataV3
cc.length <- cc.length[cc.length$Weight>0,]

#saveRDS(cc.length, file= "Data/CompleteLengthCases20211202.rds") ##change to todays date before running

bio.data<- cc.length
bio.data.sample <- sample_frac(bio.data, 0.1)
bio.data<-filter(bio.data,Year!= as.integer(format(Sys.Date(), "%Y")) ) # remove unverified data from present year
bio.data<-droplevels(filter(bio.data,ICESSubArea!="U    "))
bio.data$ICESSubArea<-paste0("27.",bio.data$ICESSubArea)
bio.data$ICESSubArea<-trimws(bio.data$ICESSubArea)
bio.data$ICESDiv<-trimws(bio.data$ICESDiv)
bio.data$ICESSubArea<-as.factor(bio.data$ICESSubArea)
bio.data$ICESDiv<-as.factor(bio.data$ICESDiv)
levels(bio.data$ICESDiv)
levels(bio.data$ICESDiv)[10]<-"(unclassified)" #renaming "U"
bio.data$ICESDivFullNameN<-droplevels(interaction(bio.data$ICESSubArea,bio.data$ICESDiv))
bio.data$ICESSubArea<-as.factor(bio.data$ICESSubArea)
bio.data$ICESDivFullNameN<-as.factor(bio.data$ICESDivFullNameN)

saveRDS(bio.data, file = "Data/bio.data20241029.rds") ##change to todays date before running

### Age ###
bio.data.age <- SDdata
dataA2 <- bio.data.age[!is.na(bio.data.age$Age),]
dataA3 <- dataA2[!is.na(dataA2$Length),]
cc.age<-dataA3
cc.age <- cc.age[!is.na(cc.age$Date),]
cc.age<- cc.age %>%
  mutate(decimaldate = decimal_date(Date))
cc.age <- cc.age %>% 
  mutate(justdecimal= cc.age$decimaldate-cc.age$Year)
cc.age <- cc.age %>%
  mutate(AgeContin = cc.age$Age + cc.age$justdecimal)
cc.age <- cc.age[!cc.age$Age <0.1,]
cc.age<-filter(cc.age,Year!= as.integer(format(Sys.Date(), "%Y")) ) # remove unverified data from present year
cc.age<-droplevels(filter(cc.age,ICESSubArea!="U    "))
cc.age$ICESSubArea<-paste0("27.",cc.age$ICESSubArea)
cc.age$ICESSubArea<-trimws(cc.age$ICESSubArea)
cc.age$ICESDiv<-trimws(cc.age$ICESDiv)
cc.age$ICESSubArea<-as.factor(cc.age$ICESSubArea)
cc.age$ICESDiv<-as.factor(cc.age$ICESDiv)
levels(cc.age$ICESDiv)
levels(cc.age$ICESDiv)[10]<-"(unclassified)" #renaming "U"
cc.age$ICESDivFullNameN<-droplevels(interaction(cc.age$ICESSubArea,cc.age$ICESDiv))

cc.age$ICESSubArea<-as.factor(cc.age$ICESSubArea)
cc.age$ICESDivFullNameN<-as.factor(cc.age$ICESDivFullNameN)

saveRDS(cc.age, file = "Data/cc.age20241029.rds")


#########SpeciesList for server.R####

com_sp <- com_sp[order(as.character(com_sp$CommonName), as.character(com_sp$AphiaID)),]

SpeciesList <- data.frame(IC_Species = c(as.character(com_sp$LogbooksFAOCode)),
                          Species_Name_full = c(as.character(com_sp$CommonName)),
                          Species_Name = c(as.character(com_sp$CommonName)))

SpeciesList <- SpeciesList[SpeciesList$IC_Species %in% 
              c('ANK','BOC','COD','HAD','HER','HKE','HOM','LIN',
                'MAC','MEG','MON','PLE','POK','POL','SOL','SPR',
                'WHB','WHG'),]

# SpeciesList <- data.frame(IC_Species =c(as.character(com_sp$LogbooksFAOCode)),
#                           Species_Name_full = c(as.character(com_sp$CommonName)),
#                           Species_Name = c("Herring" ,"Sprat","Cod","Haddock",
#                                            "Whiting","Blue Whiting","Pollack","Saithe","Ling",
#                                            "Hake", "Black-bellied Anglerfish",
#                                            "White-bellied Anglerfish","Horse Mackerel","Mackerel","Plaice",
#                                           "Megrim","Sole","Boarfish"))
write.csv(SpeciesList,"Data/SpeciesList20241029.csv",row.names=F)
