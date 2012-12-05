library(tm)
library(RWeka)
library(maps)

#read in tweets
tweets <- read.csv('http://stu.itp.nyu.edu/~pmd299/training-tweets.csv')
cities <- read.csv('~/Desktop/ccs/balacera/assets/data/cities_world.csv')
mexico <- cities[cities$Country == "Mexico",]
mex.cities <- mexico$CityName

stopwords <- c(stopwords('spanish'), 'rt', 'balacera')

#subset of events
event.10 <- tweets[tweets$event == 10,]
event.11 <- tweets[tweets$event == 11,]
event.12 <- tweets[tweets$event == 12,]
event.13 <- tweets[tweets$event == 13,]
event.14 <- tweets[tweets$event == 14,]
event.15 <- tweets[tweets$event == 15,]
event.16 <- tweets[tweets$event == 16,]
event.17 <- tweets[tweets$event == 17,]
event.18 <- tweets[tweets$event == 18,]
event.19 <- tweets[tweets$event == 19,]

#create data frame from events
combined <- rbind(event.10, event.11, event.12, event.13, event.14, event.15, event.16, event.17, event.18, event.19)

cities.pattern <- "ju[aá]rez|culiac[aá]n|tijuana|chihuahua|acapulco\\s+de\\s+ju[aá]rez|g[oó]mez|palacio|torre[oó]n|tierra\\s+blanca|cali|mazatl[aá]n|nogales|durango|navolato|monterrey|morelia|ahome|tepic|reynosa|guasave|tecom[aá]n|tocuyo|trancas|xalapa|hidalgo\\s+del\\s+parral|ecatepec\\s+de\\s+uorelos|uruapan|colonia\\s+del\\s+paseo\\s+residencial"
muertos.pattern <- "muert*(os|o|an)"
bala.en.pattern <-"balacera\\s+en"
pattern <- cities.pattern

#create the corpus
text.corp <- Corpus(VectorSource(combined$text))

#preprocess the corpus
text.corp <- tm_map(text.corp, stripWhitespace)
text.corp <- tm_map(text.corp, tolower)
text.corp <- tm_map(text.corp, removePunctuation)
text.corp <- tm_map(text.corp, removeWords, stopwords)

#insert pattern to filter by
filtered.corp <- tm_filter(text.corp, FUN=searchFullText, cities.pattern)

#convert corpus to dtm
dtm <- DocumentTermMatrix(filtered.corp) # tdm <- TermDocumentMatrix(text.corp) || # dtm <- DocumentTermMatrix(filtered.corp, control = list(tokenize = NGramTokenizer))

#filter out words that don't match the cities pattern
# names <- dtm$dimnames
# dtm.terms <- as.vector(dtm$dimnames)$Terms
# feature.cities <- grep(cities.pattern, dtm.terms)
# city.terms <- dtm.terms[feature.cities]

# transposed <- t(dtm)[city.terms]

# dtm <- t(transposed)

#convert to data frame
df <- as.data.frame(inspect(dtm)) #as.vector? # df <- as.data.frame(inspect(dtm2))

#scale
df.scale <- scale(df)

#find euclidian distance
d <- dist(df.scale, method = "euclidean")

#cluster with ward
fit <- hclust(d, method="ward")

#plot
plot(fit) 

#make n groups
cluster.num <- 10

#instantiate empty cluster number error vector	
clust.num.error <- c()
training.events <- c(10,11,12,13,14,15,16,17,18,19)
mode.matrix <- matrix(ncol = 10)
error.matrix <- matrix(ncol = 10)
error.vec <- c()

for (i in 1:ceiling(max(fit$height))){
	groups <- cutree(fit, h=i)
	rect.hclust(fit, h=i, border="red")
	clusters <- rect.hclust(fit, h=i, border="red")
	error <- c((length(clusters) - cluster.num)^2)
	clust.num.error <- c(clust.num.error, error) 
	# if (i == 1){
	# 	final.matrix <- matrix(ncol=length(clusters))		
	# }
	error.count <- c()
	event.count <- c()
	mode <- c()
	
	for (k in 1:length(training.events)){
		#test event equals training event k
		test.event <- training.events[k]
		#initialize var with most incidences of events  
		most <- 0
		#initialize index in events of event with most incidences for a given cluster 
		index <- 0
		#initialize error count
		# event.counts <- c()
		for (l in 1:length(clusters)){
			#unlist documents for lath cluster
			cluster <- unlist(clusters[[l]])
			#create dataframe of subset of corpus with indexes that have that event
			events <- as.data.frame(combined[cluster,]$event)
			unlisted <- unlist(events)
			df.ul <- as.data.frame(unlisted)
			event.count <- length(df.ul[df.ul$unlisted == test.event,])

			if (l == 1){
				most <- event.count
				index <- l			
			} else if ( event.count > most){
				most <- event.count
				index <- l
			}
		}
		mode <- c(mode, index)

		#num in actual corpus - number in modal cluster
		error <- (dim(combined[combined$event == k,])[1] - most)^2
		error.count <- c(error.count, error)
	}
	sum.sqrd <- sum(error.count)
	error.vec <- c(error.vec, c(sum.sqrd))
	error.matrix <- rbind(error.matrix, error.count)
	mode.matrix <- rbind(mode.matrix, mode)
}

#confusion matrix:
#true positive: all x in i
#false negative: all x not in i
#false positive: all not x in i
#true negative: all not x not in i





