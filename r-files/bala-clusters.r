library(tm)

#read in tweets
tweets <- read.csv('http://stu.itp.nyu.edu/~pmd299/training-tweets.csv')

#select six events
event.10 <- tweets[tweets$event == 10,]
event.11 <- tweets[tweets$event == 11,]
event.12 <- tweets[tweets$event == 12,]
event.13 <- tweets[tweets$event == 13,]
event.14 <- tweets[tweets$event == 14,]
event.15 <- tweets[tweets$event == 15,]

#create data frame from events
combined <- rbind(event.10, event.11, event.12, event.13, event.14, event.15)

#create the corpus
text.corp <- Corpus(VectorSource(combined$text)) 

#preprocess the corpus
text.corp <- tm_map(text.corp, stripWhitespace)
text.corp <- tm_map(text.corp, tolower)
text.corp <- tm_map(text.corp, removePunctuation)
text.corp <- tm_map(text.corp, removeWords, stopwords)

#convert corpus to dtm
dtm <- DocumentTermMatrix(text.corp)

#remove sparse terms
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

#make n groups
cluster.num <- 6

#instantiate empty cluster number error vector	
clust.num.error <- c()

for (i in 1:ceiling(max(fit$height))){
	groups <- cutree(fit, h=i)
	rect.hclust(fit, h=i, border="red")
	clusters <- rect.hclust(fit, h=i, border="red")
	error <- c((length(clusters) - cluster.num)^2)
	clust.num.error <- c(clust.num.error, error) 
}

plot(clust.num.error, type="l")
#all the error values of zero
zeros <- clust.num.error[clust.num.error == 0]
#find indices of error values of zero
zeros <- which(clust.num.error %in% zeros)
#get the first one, that's our h value
hval <- zeros[1]

#replot with new h value
plot(fit)
groups <- cutree(fit, h=hval)
rect.hclust(fit, h=hval, border="red")
clusters <- rect.hclust(fit, h=hval, border="red")

#initialize empty vector for training modes
test.modes <- c()

#vector of training event ids
training.events <- c(10,11,12,13,14,15)

#find the modal event from each cluster and add it to the test modes
for (j in 1:length(clusters)){
	#get modal value from each training cluster
	cluster <- unlist(clusters[[j]])
	events <- as.data.frame(combined[cluster,]$event)
	mode.vec <- as.vector(as.numeric(names(rev(sort(table(events)))[1])))
	test.modes <- c(test.modes, mode.vec)
}

#print test modes
test.modes