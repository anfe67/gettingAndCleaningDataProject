## Introduction

# Obtaining the Data 

The script downloads the original dataset (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and places it with the name projectData.zip in a directory named projectData under the current working directory. It then uses thee unzip function to unpack the file. If the file is already present then it should be overwritten. I know we should assume that the file is already in the directory but I find this to be more complete as we have seen in the beginning of the course how to do it.  

The script contains commented instructions to start in a predefined directory. 

# Verification of the data and assumptions 

I have read the README.txt file in "UCI HAR Dataset", and I have understood that the sensor data, consisting of 561 variables per each observation, are stored in the train and test folders. The Inertial Signals are not used for this analysis, I only use: 

Subject files: 
* subject_train.txt 
* subject_test.txt 

Activity files: 
* y_train.txt 
* y_test.txt 

Sensor Data: 
* X_train.txt 
* X_test.txt 

Furthermore, I use the two files 
* activity_labels.txt 
* feature_info.txt 

To give column names and meaningful activity names to the dataset. In this process, I have verified that the train and test sets have the same number of rows. I have also assumed that rbind() of two dataframes appends the first dataframe to the second (order of rows is preserved). 

# Note

I have not used Data Tables, just Data Frames, as the datasets are small enough. 


# Product of the script 

The script produces two csv files
* fullDataWithMeanStdWithActNames.csv  (Contains all the Mean and Std deviations with column names and meaningful activity names)
* analysedData.csv                     (Contains the mean values of the observations, grouped by subject and activity)

I have used the relevant column names contained in feature_info.txt (66 columns out of 561, those containing mean() and std()), all numeric, and I have added: 

* subject          : integer 
* activity         : integer 
* ActivityName     : Factor w/ 6 levels "LAYING","SITTING"... as in activity_labels.txt 

# Verification of the script

After having obtained the desired result, I have deleted all data downloaded and produced and I have started it again with identical results. This is run on Kubuntu Linux 14.04 32 bits edition, R is 3.2.2 and RStudio is version 0.99.447. Some of the commands may need to be adapted when running the script on another platform, especially those dealing with pathnames. 

# Data Processing:  

I have read the data from the test and training set and I have merged it: 

* testData <-read.csv("test/X_test.txt", sep="", header = FALSE)
* trainData <-read.csv("train/X_train.txt", sep="", header = FALSE)
* fullData<-rbind(testData, trainData)

I have done the same with the subjects and the activity codes, also giving column names 

* testSubjects <-read.csv("test/subject_test.txt", sep="", header = FALSE)
* trainSubjects <-read.csv("train/subject_train.txt", sep="", header = FALSE)
* fullSubjects<-rbind(testSubjects, trainSubjects)
* colnames(fullSubjects)<-c("subject")
* testLabels <-read.csv("test/y_test.txt", sep="", header = FALSE)
* trainLabels <-read.csv("train/y_train.txt", sep="", header = FALSE)
* fullLabels<-rbind(testLabels, trainLabels)
* colnames(fullLabels)<-c("activity")

I have then read the column names and assigned them to the fullData dataset to start making sense of the data... 
* features <-read.csv("features.txt", sep="", header = FALSE)
* colnames(fullData)<-as.vector(features$V2)

I have then identified the columns (from the features dataframe) that contain only mean and std in their names as per project assignment 
using a solution that I have found on StackOverflow.com to get a dataset containing only means and standard deviations
* library(sqldf)
* interestingFeatures<-sqldf("select * from features where V2 LIKE '%mean()%' or V2 LIKE '%std()%'") 
* fullDataMeanStd<-fullData[,as.vector(interestingFeatures$V2)]

I have merged in the the subjects and the activity labels 
+ fullDataMeanStd<-cbind(fullSubjects, fullLabels, fullDataMeanStd)

I have joined the activity names from the activity_labels.txt (and I have proposed in the comments in script a second way of doing it) 
* activityNames <-read.csv("activity_labels.txt", sep="", header = FALSE)
* colnames(activityNames)<-c("activity", "ActivityName")
* fullDataWithMeanStdWithActNames <-merge(x = fullDataMeanStd, y = activityNames, by = "activity", all.x = TRUE)

I have swapped columns around to get the subject , activity and activity labels first... (again from StackOverflow)
* ordered_columns_leftside=c('subject','activity','ActivityName')
* fullDataWithMeanStdWithActNames=fullDataWithMeanStdWithActNames[c(ordered_columns_leftside, setdiff(names(fullDataWithMeanStdWithActNames),ordered_columns_leftside))]

Based on this cleaner dataset, I have started the requested analysis using the aggregate function. And I have verified that the results were corect by running calls to summary 
on a subsets of data corresponding to the groups 
* analysedData<-aggregate(fullDataWithMeanStdWithActNames, by=list(fullDataWithMeanStdWithActNames$subject, fullDataWithMeanStdWithActNames$ActivityName), FUN=mean)

I have to clean the dataset a bit further because the join caused the activity name to be empty (cannot average on it, so it takes NA) However the activity names are preserved as part of the grouping functions, so I still have them in the second column (Group 2). And the first column (Group 1) is the subject. So I loose the empty and the duplicated columns. 
* analysedData$ActivityName<-NULL
* analysedData$subject<-NULL

I rename my group columns 
* colnames(analysedData)[1] <- "subject"
* colnames(analysedData)[2] <- "ActivityName"

And I save my two resulting files in TXT and CSV for further analysis. 
* write.table(file="analysedData.txt", x=analysedData, row.names = FALSE)
* write.csv(file="analysedData.csv", x=analysedData)
* write.table(file="fullDataWithMeanStdWithActNames.txt", x=fullDataWithMeanStdWithActNames, row.names = FALSE)
* write.csv(file="fullDataWithMeanStdWithActNames.csv", x=fullDataWithMeanStdWithActNames)









