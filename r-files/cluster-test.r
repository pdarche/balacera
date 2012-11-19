library(tm)

#read in balacera tweets
#raw data can be found at: https://raw.github.com/pdarche/balacera/master/assets/data/balacera.csv
tweets <- read.csv(file="~/Desktop/ccs/balacera/assets/data/balacera.csv")

#stopwords vector
stopwords <- c(stopwords('spanish'), 'rt')

#establish the corpus
text.corp <- Corpus(VectorSource(tweets$text)) 

#preprocess the corpus
test <- text.corp[1:1000]
test <- tm_map(test, stripWhitespace)
test <- tm_map(test, tolower)
test <- tm_map(test, removePunctuation)
test <- tm_map(test, removeWords, stopwords)

#turn corpus into DocumentTermMatrix
dtm <- DocumentTermMatrix(test)  #, control = params

#explore the data a little...
findFreqTerms(dtm, lowfreq=30)
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

#make 5 groups
groups <- cutree(fit, k=5)

#color them red
rect.hclust(fit, k=5, border="red")

clusters <- rect.hclust(fit, k=5, border="red")

cluster.df <- as.data.frame((clusters[[1]]))

cluster.vec <- as.vector(cluster.df[,])

#inspect tweets
inspect(cluster[cluster.vec])

#kmeans cluster
kfit <- kmeans(df.scale, 5)

#dimensional scaling
mds <- cmdscale(d, k=2)
plot(mds)

# cities.vector <- c("Juárez", "Culiacán", "Tijuana", "Chihuahua", "Acapulco de Juárez", "Gómez", "Palacio", "Torreón", "Mazatlán", "Nogales", "Durango", "Navolato", "Monterrey", "Morelia", "Ahome", "Tepic", "Reynosa", "Guasave", "Hidalgo del Parral", "Ecatepec de Morelos", "Uruapan")
cities.pattern <- "Ju[aá]rez|Culiac[aá]n|Tijuana|Chihuahua|Acapulco\\s+de\\s+Ju[aá]rez|G[oó]mez|Palacio|Torre[oó]n|Mazatl[aá]n|Nogales|Durango|Navolato|Monterrey|Morelia|Ahome|Tepic|Reynosa|Guasave|Hidalgo\\s+del\\s+Parral|Ecatepec\\s+de\\s+Morelos|Uruapan"

cities <- tm_filter(text.corp, grep(cities.pattern, text.corp, ignore.case=TRUE))


