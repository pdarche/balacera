library(tm)

#read in balacera tweets
#raw data can be found at: https://raw.github.com/pdarche/balacera/master/assets/data/balacera.csv
tweets <- read.csv(file="~/Desktop/ccs/balacera/assets/data/balacera.csv")

# params <- list(minDocFreq = 1, 
# 			   	removeNumbers = FALSE, 
# 			   	stemming = TRUE, 
#                 stopwords = TRUE, 
# 				weighting = weightTf
# 			)

#establish the corpus
text.corp <- Corpus(VectorSource(tweets$text)) 

stopwords <- c(stopwords('spanish'), 'rt')

#convert the corpus to a DocumentTermMatrix
test <- text.corp[1:1000]
test <- tm_map(test, stripWhitespace)
test <- tm_map(test, tolower)
test <- tm_map(test, removePunctuation)
test <- tm_map(test, removeWords, stopwords)

#turn into DocumentTermMatrix
dtm <- DocumentTermMatrix(test)  #, control = params

#explore the data a little...
findFreqTerms(dtm, lowfreq=30)
findAssocs(dtm, 'muertos', 0.20)

#back to business
dtm2 <- removeSparseTerms(dtm, sparse=0.95)

#convert to data frame
df <- as.data.frame(inspect(dtm2)) #as.vector?

#scale
df.scale <- scale(df)

#find euclidian distance
d <- dist(df.scale, method = "euclidean")

#cluster with ward
fit <- hclust(d, method="ward")
#plot
plot(fit) 

#make 5 groups
groups <- cutree(fit, k=5)

#color them red
rect.hclust(fit, k=5, border="red")

#kmeans cluster
kfit <- kmeans(df.scale, 5)

#dimensional scaling
mds <- cmdscale(d, k=2)
plot(mds)
