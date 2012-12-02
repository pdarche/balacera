#import libraries
library(tm)
library(RWeka)
library(maps)

#get training data
tweets <- read.csv('~/Downloads/training-tweets.csv')

#stopwords vector
stopwords <- c(stopwords('spanish'), 'rt')

#world cities
data(world.cities)
cities <- world.cities

cities.pattern <- "ju[aá]rez|culiac[aá]n|tijuana|chihuahua|acapulco\\s+de\\s+ju[aá]rez|g[oó]mez|palacio|torre[oó]n|mazatl[aá]n|nogales|durango|navolato|monterrey|morelia|ahome|tepic|reynosa|guasave|hidalgo\\s+del\\s+parral|ecatepec\\s+de\\s+uorelos|uruapan"
muertos.pattern <- "muert*(os|o|an)"
narcos.pattern <- "narc*(os|o)"
bala.en.pattern <-"balacera\\s+en"

#establish the corpus
text.corp <- Corpus(VectorSource(tweets$text)) 

#preprocess the corpus
text.corp <- tm_map(text.corp, stripWhitespace)
text.corp <- tm_map(text.corp, tolower)
text.corp <- tm_map(text.corp, removePunctuation)
text.corp <- tm_map(text.corp, removeWords, stopwords)

pattern <- bala.en.pattern
filtered.corp <- tm_filter(text.corp, FUN=searchFullText, pattern)

#turn corpus into DocumentTermMatrix
dtm <- DocumentTermMatrix(filtered.corp)

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
cluster.num <- 2

groups <- cutree(fit, k=cluster.num)

#color them red
rect.hclust(fit, k=cluster.num, border="red")

clusters <- rect.hclust(fit, k=cluster.num, border="red")

for ( i in 1:cluster.num ){
	#get the vector of indices for the ith cluster
	cluster.vec <- unlist((clusters[[i]]))
	tweets$text[cluster.vec]
	tweets$event[cluster.vec]	
}

########## TEST WITH 2 SMALL EVENTS ##########

######## GET THE INDICES OF A COLUMN : which(combined$event %in% event.11$event)
tweets <- read.csv('http://stu.itp.nyu.edu/~pmd299/training-tweets.csv')

event.10 <- tweets[tweets$event == 10,]
event.11 <- tweets[tweets$event == 11,]
event.12 <- tweets[tweets$event == 12,]
event.13 <- tweets[tweets$event == 13,]
event.14 <- tweets[tweets$event == 14,]
event.15 <- tweets[tweets$event == 15,]

combined <- rbind(event.10, event.11, event.12, event.13, event.14, event.15)

#create the corpus
text.corp <- Corpus(VectorSource(combined$text)) 

#preprocess the corpus
text.corp <- tm_map(text.corp, stripWhitespace)
text.corp <- tm_map(text.corp, tolower)
text.corp <- tm_map(text.corp, removePunctuation)
text.corp <- tm_map(text.corp, removeWords, stopwords)

dtm <- DocumentTermMatrix(text.corp)

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

test.modes <- c()
training.events <- c(10,11,12,13,14,15)

for (j in 1:length(clusters)){
	#get modal value from each training cluster
	cluster <- unlist(clusters[[j]])
	events <- as.data.frame(combined[cluster,]$event)
	mode.vec <- as.vector(as.numeric(names(rev(sort(table(events)))[1])))
	test.modes <- c(test.modes, mode.vec)
}

test.modes
