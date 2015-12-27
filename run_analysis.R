## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


install.packages("data.table")
install.packages("reshape2")

library("data.table")
library("reshape2")

# Load text files with activity labels and column names
actividad_etiquetas <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
columnas <- read.table("./UCI HAR Dataset/features.txt")[,2]

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
extraer_columnas <- grepl("mean|std", columnas)

# Load and process X_test & y_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
materia_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(X_test) = columnas
X_test = X_test[,extraer_columnas]

# Load activity labels
y_test[,2] = actividad_etiquetas[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(materia_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(materia_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
materia_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) = columnas
X_train = X_train[,extraer_columnas]

# Load activity data
y_train[,2] = actividad_etiquetas[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(materia_train) = "subject"

# Bind data
train_data <- cbind(as.data.table(materia_train), y_train, X_train)

# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names.
# Merge test and train data
data = rbind(test_data, train_data)
id_etiquetas   = c("subject", "Activity_ID", "Activity_Label")
data_etiquetas = setdiff(colnames(data), id_etiquetas)
melt_data      = melt(data, id = id_etiquetas, measure.vars = data_etiquetas)

# 5.Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt", row.names = FALSE,col.names = TRUE)
