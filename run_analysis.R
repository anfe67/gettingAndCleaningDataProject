# Uncomment this line to start in a specific directory (change it as you please)
# setwd("/home/tomtom/data/")

# Check if directory exists, if not create it
if (!file.exists("projectData")) {
      dir.create("projectData")
}

# Project file data 
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# I am on linux, the method = "curl" does not work for me or in my version of R. It is Ok when I omit it  
download.file(fileUrl, destfile = "./projectData/projectData.zip")

# This is to verify that I have downloaded the file correctly 
list.files("./projectData")

# Decompress the file (unzip is part of the utils package, loaded per default)
unzip("./projectData/projectData.zip", exdir="./projectData")

# This is to verify that I have the directory with the new decompressed files
list.files("./projectData")

# I move to the decompressed data dir to have an easier life with paths
setwd("./projectData/UCI HAR Dataset")

# Read the test and training data 
testData <-read.csv("test/X_test.txt", sep="", header = FALSE)
trainData <-read.csv("train/X_train.txt", sep="", header = FALSE)

# merge the two datasets 
fullData<-rbind(testData, trainData)

# Read the test and training subjects for the observatiosn 
testSubjects <-read.csv("test/subject_test.txt", sep="", header = FALSE)
trainSubjects <-read.csv("train/subject_train.txt", sep="", header = FALSE)

# merge the two subject datasets 
fullSubjects<-rbind(testSubjects, trainSubjects)

# Adding Column name
colnames(fullSubjects)<-c("subject")

# Read the test and training activity label codes for the observations
testLabels <-read.csv("test/y_test.txt", sep="", header = FALSE)
trainLabels <-read.csv("train/y_train.txt", sep="", header = FALSE)

# merge the two label datasets ()
fullLabels<-rbind(testLabels, trainLabels)

# Adding Column name
colnames(fullLabels)<-c("activity")

# Read the column names and assign them to the fullData dataset to start making sense of the data... 
features <-read.csv("features.txt", sep="", header = FALSE)
colnames(fullData)<-as.vector(features$V2)

# I am now identifying the columns (from the features dataframe) that contain only mean and std in their names as per project assignment 
library(sqldf)
interestingFeatures<-sqldf("select * from features where V2 LIKE '%mean()%' or V2 LIKE '%std()%'") 

# Get a dataset containing only means and standard deviations
fullDataMeanStd<-fullData[,as.vector(interestingFeatures$V2)]

# Add the subject and the activity columns 
fullDataMeanStd<-cbind(fullSubjects, fullLabels, fullDataMeanStd)

# Read activity names 
activityNames <-read.csv("activity_labels.txt", sep="", header = FALSE)
colnames(activityNames)<-c("activity", "ActivityName")


# Include descriptive activity names in the dataset
fullDataWithMeanStdWithActNames <-merge(x = fullDataMeanStd, y = activityNames, by = "activity", all.x = TRUE)

# Alternative using sqldf 
# library(sqldf)
# fullDataWithMeanStdWithActNames <- sqldf("SELECT * FROM fullDataMeanStd LEFT JOIN activityNames USING(activity)")

# I want to have the subject, activity and activity labels first... (from StackOverflow)
ordered_columns_leftside=c('subject','activity','ActivityName')
fullDataWithMeanStdWithActNames=fullDataWithMeanStdWithActNames[c(ordered_columns_leftside, setdiff(names(fullDataWithMeanStdWithActNames),ordered_columns_leftside))]

# I suppose that this is the starting point for our analysis, the dataset is clean and I need to do some grouping here... 
analysedData<-aggregate(fullDataWithMeanStdWithActNames, by=list(fullDataWithMeanStdWithActNames$subject, fullDataWithMeanStdWithActNames$ActivityName), FUN=mean)

# This contains the good data but I want to clean a bit better the dataset. The first two column names are the groupings (subject and activity). 
# I lost the ActivityName because I cannot average on it. So, I clean the column names and remove the duplications. 
analysedData$ActivityName<-NULL
analysedData$subject<-NULL

# Column 1 is the subject and column 2 is the ActivityName 
colnames(analysedData)[1] <- "subject"
colnames(analysedData)[2] <- "ActivityName"

# For good measure, I save this one to a file... 
write.table(file="analysedData.txt", x=analysedData, row.names = FALSE)
write.csv(file="analysedData.csv", x=analysedData)

# I also save the clean dataset to a file... 
write.table(file="fullDataWithMeanStdWithActNames.txt", x=fullDataWithMeanStdWithActNames, row.names = FALSE)
write.csv(file="fullDataWithMeanStdWithActNames.csv", x=fullDataWithMeanStdWithActNames)








