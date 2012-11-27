library(tm)


tweets <- read.csv('~/Desktop/ccs/balacera/assets/data/balacera.csv') 	 	

#stopwords vector
stopwords <- c(stopwords('spanish'), 'rt')

######################## module one: filter and cluster by pattern ########################

##options for improvement: weighting terms - weighting matched patter?

# cities.vector <- c("Juárez", "Culiacán", "Tijuana", "Chihuahua", "Acapulco de Juárez", "Gómez", "Palacio", "Torreón", "Mazatlán", "Nogales", "Durango", "Navolato", "Monterrey", "Morelia", "Ahome", "Tepic", "Reynosa", "Guasave", "Hidalgo del Parral", "Ecatepec de Morelos", "Uruapan")
cities.pattern <- "ju[aá]rez|culiac[aá]n|tijuana|chihuahua|acapulco\\s+de\\s+ju[aá]rez|g[oó]mez|palacio|torre[oó]n|mazatl[aá]n|nogales|durango|navolato|monterrey|morelia|ahome|tepic|reynosa|guasave|hidalgo\\s+del\\s+parral|ecatepec\\s+de\\s+uorelos|uruapan"
muertos.pattern <- "muert*(os|o|an)"
narcos.pattern <- "narc*(os|o)"

#establish the corpus
text.corp <- Corpus(VectorSource(tweets$text)) 

#preprocess the corpus
text.corp <- tm_map(text.corp, stripWhitespace)
text.corp <- tm_map(text.corp, tolower)
text.corp <- tm_map(text.corp, removePunctuation)
text.corp <- tm_map(text.corp, removeWords, stopwords)

#insert pattern to filter by
pattern <- muertos.pattern

filtered.corp <- tm_filter(text.corp, FUN=searchFullText, pattern)

#turn corpus into DocumentTermMatrix
dtm <- DocumentTermMatrix(filtered.corp)  #, control = params
#ngrams
# dtm <- DocumentTermMatrix(filtered.corp, control = list(tokenize = NGramTokenizer))

#explore the data a little...
findFreqTerms(dtm, lowfreq=10)
findAssocs(dtm, 'muertos', 0.20)

#back to business.  remove sparce terms
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
cluster.num <- 3

groups <- cutree(fit, k=cluster.num)

#color them red
rect.hclust(fit, k=cluster.num, border="red")

clusters <- rect.hclust(fit, k=cluster.num, border="red")

#inspect the clusters 
for ( i in 1:cluster.num ){
	#get the vector of indices for the ith cluster
	cluster.vec <- unlist((clusters[[i]]))
	inspect(text.corp[cluster.vec])	
}

#kmeans cluster
kfit <- kmeans(df.scale, 5)

#dimensional scaling
mds <- cmdscale(d, k=2)
plot(mds)


######################## time series ########################
#hist of tweet creation times
h <- hist(tweets$created_at_seconds, 100)

counts <- h$counts 

plot(counts, type='l') 

acf <- acf(counts, lag=100)

abline(v=which(counts > 5), col=2)

acf <- acf(counts, lag=100)

rev(order(acf$acf))

######################## module two: group by city ########################

######################## module three: n-grams ########################

##TO DO 
## process: 
## 1: have luis hand annotate which events are happening
## 2: run through variations of algorithms to see which of those things match with what's happening.
## 3:  
#finish script that easily show filtering algos 

# filter out information poor tweets
# 

#take only tweets that are not retweeted
#capitalized words
#key words
#cities names
#numbers, dates

# tag tweets. number of event + -1 (non-filted)
# turning tweets into feature vectors
# levels of h which match labeling best   

