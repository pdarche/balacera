#read in balacera tweets
tweets <- read.csv(file="~/Desktop/ccs/balacera/assets/balacera.csv")
#read in stop words
stop.words <- read.csv(file="~/Desktop/ccs/balacera/assets/spanish_stopwords.txt")
#unlist stopwords
stop.words <- unlist(stop.words)
#text var for ease
text <- tolower(unlist(strsplit(tweets$text, " ")))
#remove stop words
text.wosw <- text[!(text %in% stop.words)] 

library(tm)

params <- list(minDocFreq = 1, 
			   	removeNumbers = FALSE, 
			   	stemming = TRUE, 
                stopwords = TRUE, 
				weighting = weightTf
			)
#establish the corpus
text.corp <- Corpus(VectorSource(tweets$text)) 

#convert the corpus to a DocumentTermMatrix
test <- text.corp[1:1000]
test <- tm_map(test, stripWhitespace)
test <- tm_map(test, tolower)
test <- tm_map(test, removeWords, stopwords("spanish"))

#turn into DocumentTermMatrix
dtm <- DocumentTermMatrix(test)  #, control = params

#turn it into a matrix
dtm.mat <- as.matrix(dtm)

#measure euclidian distance between documents
d <- dist(dtm.mat, method="euclidian")

#cluster documents 
fit <- hclust(d, method="ward")
