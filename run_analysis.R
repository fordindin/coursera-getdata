#!/usr/bin/env Rscript

library(plyr)
library(reshape2)
# initializing some variables

source.dataset.url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
destfile <- 'getdata-project-files-UCI-HAR-Dataset.zip'
destdir <- 'UCI HAR Dataset'
data.set <- list()

message("Getting source dataset..", appendLF=FALSE)
if (!file.exists(destfile)){
		download.file(source.dataset.url, destfile, method='curl', quiet=TRUE)
}
message("	Done")

message("Unpacking source dataset..", appendLF=FALSE)
if (!file.exists(destdir)){
		unzip(destfile)
}
message("	Done")

message("Loading features..", appendLF=FALSE)
data.set$features <- read.table(
		paste(destdir, "features.txt", sep="/"),
		col.names=c('id', 'name'),
		stringsAsFactors=FALSE
		)
message("		Done")

message("Loading activity features..", appendLF=FALSE)
data.set$activity_labels <- read.table(
		paste(destdir, "activity_labels.txt", sep="/"),
		col.names=c('id', 'Activity'))
message("	Done")

message("Loading test set..", appendLF=FALSE)
data.set$test <- cbind(
		subject=read.table(paste(destdir, "test", "subject_test.txt", sep="/"), col.names="Subject"),
		y=read.table(paste(destdir, "test", "y_test.txt", sep="/"), col.names="Activity.ID"),
		x=read.table(paste(destdir, "test", "X_test.txt", sep="/"))
		)
message("		Done")

message("Loading train set..", appendLF=FALSE)
data.set$train <- cbind(
		subject=read.table(paste(destdir, "train", "subject_train.txt", sep="/"), col.names="Subject"),
		y=read.table(paste(destdir, "train", "y_train.txt", sep="/"), col.names="Activity.ID"),
		x=read.table(paste(destdir, "train", "X_train.txt", sep="/"))
		)
message("		Done")

message("Merging and filtering dataset..", appendLF=FALSE)
tidy <- rbind(data.set$test, data.set$train)[,c(1, 2, grep("mean\\(|std\\(",data.set$features$name) + 2)]
message("	Done")

change.features.names <- function(c) {
		c <- sub("tBody", "Time.Body", c)
		c <- sub("tGravity", "Time.Gravity", c)
		c <- sub("fBody", "FFT.Body", c)
		c <- sub("fGravity", "FFT.Gravity", c)
		c <- sub("\\-mean\\(\\)\\-", ".Mean.", c)
		c <- sub("\\-std\\(\\)\\-", ".Std.", c)
		c <- sub("\\-mean\\(\\)", ".Mean", c)
		c <- sub("\\-std\\(\\)", ".Std", c)
return(c)
}

message("Renaiming the features..", appendLF=FALSE)
names(tidy) <- c("Subject", "Activity.ID",change.features.names(data.set$features$name[grep("mean\\(|std\\(", data.set$features$name)]))
message("	Done")

message("Renaiming variables..", appendLF=FALSE)
tidy <- merge(tidy, data.set$activity_labels, by.x="Activity.ID", by.y="id")
tidy <- tidy[,!(names(tidy) %in% c("Activity.ID"))]
message("		Done")

message("Creating second dataset..", appendLF=FALSE)
tidy.mean <- ddply(melt(tidy, id.vars=c("Subject", "Activity")), .(Subject, Activity), summarise, MeanSamples=mean(value))
message("	Done")

message("Saving the datasets..", appendLF=FALSE)
write.table(tidy.mean, file = "tidy.mean.txt",row.names = FALSE)
write.table(tidy, file = "tidy.txt",row.names = FALSE)
message("		Done")

