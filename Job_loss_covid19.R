
```{r}

library(tidyverse)
library(lubridate)
```


```{r}
#extract the dataset
dataset<- read_csv('pulse2020_puf_01 (version 1).csv')
```



```{r}
#explore the dataset

dataset %>% group_by(EEDUC) %>% tally()


#replace -99 and -88 by NA
dataset[dataset=="-99"]<-NA
dataset[dataset=="-88"]<-NA


#change WRKLOSS to 0 or 1
dataset$WRKLOSS[dataset$WRKLOSS=="2"]<-0



#Drop vars with all empty values
dataset <- dataset %>% select_if(function(x){!all(is.na(x))})

#drop rows with NA on WRKloss
library(tidyr)
dataset<- dplyr::filter(dataset,!is.na(WRKLOSS))

#missing value proportions in each column
colMeans(is.na(dataset))

# or, get only those columns where there are missing values
colMeans(is.na(dataset))[colMeans(is.na(dataset))>0]

#drop varaibles with more than 60% missing data
nm<-names(dataset)[colMeans(is.na(dataset))>0.6]
dataset <- dataset %>% select(-nm)

#Drop some other columns which are not useful and those which will cause 'leakage'
drop<-c("EXPCTLOSS","ANYWORK","SCRAM","WEEK","EST_ST","PWEIGHT","TSPNDPRPD",       "FOODCONF" ,  "HLTHSTATUS "  ,         "ANXIOUS"    ,      "WORRY"   ,       "INTEREST"    ,      "DOWN" ,         "HLTHINS1"  ,      "HLTHINS2"     ,   "HLTHINS3"   ,     "HLTHINS4",  "HLTHINS5"  ,      "HLTHINS6"   ,     "HLTHINS7"   ,     "HLTHINS8"  ,       "DELAY"  ,        "NOTGET"     ,     "TENURE"  ,       "MORTLMTH"     ,   "MORTCONF" ,"HLTHSTATUS" ,"THHLD_NUMADLT","AHISPANIC " ,"ARACE","AGENDER","ABIRTH_YEAR","AHHLD_NUMKID")

dataset=dataset[,!(names(dataset)%in% drop)]







#replace  missing vlaue by the median or mean
dataset<- dataset %>% replace_na(list(MS=median(dataset$MS,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(KINDWORK=median(dataset$KINDWORK,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(RSNNOWRK=median(dataset$RSNNOWRK,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(UNEMPPAY=median(dataset$UNEMPPAY,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(PRIFOODSUF=median(dataset$PRIFOODSUF,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(CURFOODSUF=median(dataset$CURFOODSUF,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(FREEFOOD=median(dataset$FREEFOOD,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(TSPNDFOOD=mean(dataset$TSPNDFOOD,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(INCOME=mean(dataset$INCOME,na.rm=TRUE)))



#Impute missing values - first get the columns with missing values
colMeans(is.na(dataset))[colMeans(is.na(dataset))>0]

#summary of data in these columns
nm<- names(dataset)[colSums(is.na(dataset))>0]

summary(dataset[, nm])


#change wrkloss to factor,and other useful varaibles into factor

dataset$WRKLOSS = as.factor(dataset$WRKLOSS)

dataset$EGENDER = as.factor(dataset$EGENDER)

dataset$EEDUC = as.factor(dataset$EEDUC)

dataset$TBIRTH_YEAR = as.factor(dataset$TBIRTH_YEAR)

dataset$INCOME = as.factor(dataset$INCOME)

dataset$RRACE = as.factor(dataset$RRACE)

dataset$MS = as.factor(dataset$MS)

dataset$KINDWORK = as.factor(dataset$KINDWORK)

```




```{r}
#split the dataset into training and test datasets


#we use 70% as training data and 30% as test data


#random select data


library(rsample)
datasetSplit<-initial_split(dataset, prop=0.7) 
datasetTrn<-training(datasetSplit)
datasetTst<-testing(datasetSplit)

```




```{r}


#logistic model 


glm<-glm(WRKLOSS~. ,family=binomial,data=datasetTrn)


summary(glm)

summary(residuals(glm))
#Since the median deviance residual is close to zero, this means that our model is not biased in one direction (i.e. the outcome is neither over- nor underestimated).


# First, the null deviance is high, which means it makes sense to use more than a single parameter for fitting the model. Second, the residual deviance is relatively low, which indicates that the log likelihood of our model is close to the log likelihood of the saturated model.
#However, for a well-fitting model, the residual deviance should be close to the degrees of freedom.
#Thus we need to find a group of better parameters rather than Education only. we are using EEDUC and age below.

library(caret)
library(ROCR)


Predictions= predict(glm, datasetTst, type = "response")
PredictionsProbs = as.factor(ifelse(Predictions>0.5,1,0))
datasetTst$WRKLOSS=as.factor(datasetTst$WRKLOSS)


table(PredictionsProbs,true=datasetTst$WRKLOSS)

pred=prediction(Predictions, datasetTst$WRKLOSS)

aucPerf <-performance(pred, "tpr", "fpr")
plot(aucPerf)

aucPerf=performance(pred, "auc")
aucPerf@y.values


```

#Thus we need to find a group of better parameters rather than Education only. we are using EEDUC and age below.










```{r}
library(tidyverse)
library(lubridate)

#extract the dataset
dataset<- read_csv('pulse2020_puf_01 (version 1).csv')

##explore the dataset

dataset %>% group_by(EEDUC) %>% tally()


#replace -99 and -88 by NA
dataset[dataset=="-99"]<-NA
dataset[dataset=="-88"]<-NA


#change WRKLOSS to 0 or 1
dataset$WRKLOSS[dataset$WRKLOSS=="2"]<-0



#Drop vars with all empty values
dataset <- dataset %>% select_if(function(x){!all(is.na(x))})

#drop rows with NA on WRKloss
library(tidyr)
dataset<- dplyr::filter(dataset,!is.na(WRKLOSS))

#missing value proportions in each column
colMeans(is.na(dataset))

# or, get only those columns where there are missing values
colMeans(is.na(dataset))[colMeans(is.na(dataset))>0]

#drop varaibles with more than 60% missing data
nm<-names(dataset)[colMeans(is.na(dataset))>0.6]
dataset <- dataset %>% select(-nm)

#Drop some other columns which are not useful and those which will cause 'leakage'
drop<-c("EXPCTLOSS","ANYWORK","SCRAM","WEEK","EST_ST","PWEIGHT","TSPNDPRPD",       "FOODCONF" ,  "HLTHSTATUS "  ,         "ANXIOUS"    ,      "WORRY"   ,       "INTEREST"    ,      "DOWN" ,         "HLTHINS1"  ,      "HLTHINS2"     ,   "HLTHINS3"   ,     "HLTHINS4",  "HLTHINS5"  ,      "HLTHINS6"   ,     "HLTHINS7"   ,     "HLTHINS8"  ,       "DELAY"  ,        "NOTGET"     ,     "TENURE"  ,       "MORTLMTH"     ,   "MORTCONF" ,"HLTHSTATUS" ,"THHLD_NUMADLT","AHISPANIC " ,"ARACE","AGENDER","ABIRTH_YEAR","AHHLD_NUMKID" )

dataset=dataset[,!(names(dataset)%in% drop)]







#replace  missing vlaue by the median or mean
dataset<- dataset %>% replace_na(list(MS=median(dataset$MS,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(KINDWORK=median(dataset$KINDWORK,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(RSNNOWRK=median(dataset$RSNNOWRK,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(UNEMPPAY=median(dataset$UNEMPPAY,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(PRIFOODSUF=median(dataset$PRIFOODSUF,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(CURFOODSUF=median(dataset$CURFOODSUF,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(FREEFOOD=median(dataset$FREEFOOD,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(TSPNDFOOD=mean(dataset$TSPNDFOOD,na.rm=TRUE)))

dataset<- dataset %>% replace_na(list(INCOME=mean(dataset$INCOME,na.rm=TRUE)))



#Impute missing values - first get the columns with missing values
colMeans(is.na(dataset))[colMeans(is.na(dataset))>0]

#summary of data in these columns
nm<- names(dataset)[colSums(is.na(dataset))>0]

summary(dataset[, nm])

#first thing we need to convert workloss to 1 or -1
#change WRKLOSS to -1 or 1
dataset$WRKLOSS<-ifelse(dataset$WRKLOSS == 1,"1","-1")







#build model by using SVM



library(rsample)
datasetSplit<-initial_split(dataset, prop=0.7) 
datasetTrn<-training(datasetSplit)
datasetTst<-testing(datasetSplit)

library(e1071)
library(caret)


datasetTrn$WRKLOSS<-as.numeric(as.factor(datasetTrn$WRKLOSS))



## classification model
svm.model <- svm(datasetTrn$WRKLOSS~., data = datasetTrn, type = "C-classification")


svm.model



predTrnsvm<-predict(svm.model,x=datasetTrn,decision.values = T)

svm_Trn1<-confusionMatrix(predTrnsvm,factor(datasetTrn$WRKLOSS),positive = "1")

svm_Trn1



#svm with kernel 

svm.model1 <- svm(datasetTrn$WRKLOSS~., data = datasetTrn, type = "C-classification",kernel = 'radial')


svm.model1





predTrnsvm1<-predict(svm.model1,datasetTrn,decision.values = T)

svm_Trn2<-confusionMatrix(predTrnsvm1,factor(datasetTrn$WRKLOSS),positive = "1")

svm_Trn2

##svm.tune <- tune.svm(x=datasetTrn,y=factor(datasetTrn$WRKLOSS),kernel="linear",cost=c(0.125,0.5,1,512),probability= TRUE)


##summary(svm.tune)

```