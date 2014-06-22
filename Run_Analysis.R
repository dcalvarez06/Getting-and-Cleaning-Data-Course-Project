#Create file to store all information related to Course Project if one doesn't already exist with this same file path-Getting and Cleaning Data
if(!file.exists("~/Training/DataScienceClass/data/CourseProject")) { dir.create("~/Training/DataScienceClass/data/CourseProject")}
##Set File path for your download
FilePath<-file.path("~/Training/DataScienceClass/data/CourseProject", "HAR.zip")
##File to download
FiletoUnzip<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
##Download File to FilePath
download.file(FiletoUnzip, FilePath)
##Unzip File in the FilePath
unzip(FilePath)
##Change working directory to that file you just created
setwd("~/Training/DataScienceClass/data/CourseProject/UCI HAR Dataset")

##Read features 
features<-read.table("./features.txt")
##STEP 4: Appropriately labels the data set with descriptive activity names
####removing anything that is not text or numeric
features$V3<-gsub("[^[:alnum:]]","", features$V2)
####remove second column
features$V2<-NULL
####Names columns in features
names(features)<-c("list","features")
####Read activity labels
activitylabels<-read.table("./activity_labels.txt")
####Name columns in activitylabels
names(activitylabels)<-c("actlabel","activity")

##Read Test Tables 
SubTest<-read.table("./test/subject_test.txt", header=FALSE, sep="")
####Name columns in SubTest
names(SubTest)<-"subject"
####Data Set for Test
XTest<-read.table("./test/X_test.txt", header=FALSE, sep="")
####Labels for the XTest Data Set
YTest<-read.table("./test/Y_test.txt", header=FALSE, sep="")
####Name columns in YTest
names(YTest)<-"activity"
##Combining all Test into one table
Test<-cbind(SubTest,YTest,XTest)
##names of Test columns to features
names(Test)[3:563]=features[,2]
##Read Train Tables
SubTrain<-read.table("./train/subject_train.txt", header=FALSE, sep="")
####Name columns in SubTrain
names(SubTrain)<-"subject"
####Data Set for Train
XTrain<-read.table("./train/X_train.txt", header=FALSE, sep="")
####Labels for the XTrain Data Set
YTrain<-read.table("./train/Y_train.txt", header=FALSE, sep="")
####Name columns in YTrain
names(YTrain)<-"activity"
##Combing all Train into one table
Train<-cbind(SubTrain,YTrain,XTrain)
##names of Train columns to features
names(Train)[3:563]=features[,2]

##STEP 1:Merges the training and the test sets to create one data set
####One Data Set
DataSet<-rbind(Test,Train)
##STEP 3: Uses descriptive activity names to name the activities in the data set
####Rename Values for Labels to Activity
DataSetAll<-merge(activitylabels,DataSet, by.x="actlabel", by.y="activity", all=TRUE)
####Remove actlabel column
DataSetAll$actlabel<-NULL

##STEP 2:Extract Only Mean and Std for each measurement
####Extracts Mean Columns (left case sensitive because the UpperCase are Means I do not want to bring in)
MeanData<-DataSetAll[grep("mean",names(DataSetAll))]
####Extracts Std Columns (left case sensitive because the UpperCase are Stds I do not want to bring in)
StdData<-DataSetAll[grep("std",names(DataSetAll))]
####Combine Mean and Std data sets
MeanStd<-cbind(MeanData,StdData)
####Grab Subjects
Sub<-DataSetAll[grep("subject",names(DataSetAll))]
####Grab Activities
Act<-DataSetAll[grep("activity",names(DataSetAll))]
####Grab ActLabels
##ActLabel<-DataSetAll[grep("actlabel",names(DataSetAll))]
####Combine Subject and Activities
SubAct<-cbind(Sub,Act)
####Combine Mean, Std, Sub, Act into one data set
MeanStdData<-cbind(MeanStd,SubAct)


##STEP 5:Creates a second, independent tidy data set with the average of each variable for each activity and each subject
library('reshape2')
DF<-data.frame(MeanStdData)
mdata <- melt(DF, id=c("subject","activity"))
FinalDataSet<-dcast(mdata,subject+activity~variable,fun.aggregate=mean)

##Write .txt
write.table(FinalDataSet, "HARMerged.txt", sep=";") 
##Write.csv
write.csv(FinalDataSet, "HARMerged.csv")
