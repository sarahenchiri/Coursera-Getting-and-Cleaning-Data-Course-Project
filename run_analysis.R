
setwd("~/Desktop/Getting and cleaning DATA")

destination <- "./data"
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipped_data <- file.path(destination, "dataset.zip")

# Create working directory
if(!file.exists(destination)) { dir.create(destination) }

# Download and unzip dataset
download.file(dataURL, dest=zipped_data, method="curl")
unzip (zipped_data, exdir=destination)
extracted_data <- file.path(destination, "UCI HAR Dataset")
extracted_data_test <- file.path(extracted_data, "test")
extracted_data_train <- file.path(extracted_data, "train")

# Read the data related to the test subjects
featuresTest <- read.table(file.path(extracted_data_test, "X_test.txt"), header=FALSE)
activityTest <- read.table(file.path(extracted_data_test, "y_test.txt"), header=FALSE)
subjectsTest <- read.table(file.path(extracted_data_test, "subject_test.txt"), header=FALSE)

# Read the data related to the train subjects
featuresTrain <- read.table(file.path(extracted_data_train, "X_train.txt"), header=FALSE)
activityTrain <- read.table(file.path(extracted_data_train, "y_train.txt"), header=FALSE)
subjectsTrain <- read.table(file.path(extracted_data_train, "subject_train.txt"), header=FALSE)

# Set names for the train data
dataFeaturesLables <- read.table(file.path(extracted_data, "features.txt"), head=FALSE)
names(subjectsTrain) <- c("Subject")
names(activityTrain) <- c("Activity")
names(featuresTrain) <- dataFeaturesLables$V2

# Set names for the test data
names(subjectsTest) <- c("Subject")
names(activityTest) <- c("Activity")
names(featuresTest) <- dataFeaturesLables$V2

# Merge the training data
testDataAll <- cbind(subjectsTest, activityTest, featuresTest)

# Merge the test data
trainDataAll <- cbind(subjectsTrain, activityTrain, featuresTrain)

# Concatinate the train and test data
dataAll <- rbind(trainDataAll, testDataAll)

# Get the reaquested features
requestedFeaturesLabels <- dataFeaturesLables$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesLables$V2)]

# subset the data
selectedLabels <- c( "Subject", "Activity", as.character(requestedFeaturesLabels))
dataFinal <- subset(dataAll, select=selectedLabels)

# Label the activity
activityLabels <- read.table(file.path(extracted_data, "activity_labels.txt"), header=FALSE)
dataFinal$Activity <- activityLabels[dataFinal$Activity, 2]

# Appropriately labels the data set with descriptive variable names
names(dataFinal)<-gsub("^t", "time", names(dataFinal))
names(dataFinal)<-gsub("^f", "frequency", names(dataFinal))
names(dataFinal)<-gsub("Acc", "Accelerometer", names(dataFinal))
names(dataFinal)<-gsub("Gyro", "Gyroscope", names(dataFinal))
names(dataFinal)<-gsub("Mag", "Magnitude", names(dataFinal))
names(dataFinal)<-gsub("BodyBody", "Body", names(dataFinal))
names(dataFinal)<-gsub("\\(\\)","", names(dataFinal))

# create a second, independent tidy data
library(plyr)
dataFinal_2 = ddply(dataFinal, c("Subject", "Activity"), numcolwise(mean))
write.table(dataFinal_2, file="tidyData.txt")
