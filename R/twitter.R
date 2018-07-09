consumer_key <- 'YetGrrFzoeN0UUQfCZoQERsYg'
consumer_secret <- 'xb2sXMwcLOP5HNERJBgPw2gCHUPjSSFy0VLhRScgJjfkCaP79K'
access_token <- '293631173-p2Kv4K7BW41D0vNXc5OQgdBR5nCwR4D7pmiiTgyh'
access_secret <- 'JpO4Wik99qyREddOfi0zdnxhsUdhhv1PhjbL52i4gqoHv'
library(httr)
library(devtools)
library(twitteR)
library(base64enc)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets <- searchTwitter("Neymar",n=300,lang="en")
tweets_df = twListToDF(tweets)

library(tm)

mycorpus = Corpus(VectorSource(tweets_df$text))
removeURL <- function(x) gsub("http[^[:space:]]*", " ", x)
mycorpus <- tm_map(mycorpus, content_transformer(removeURL))
mycorpus = tm_map(mycorpus, stripWhitespace)
mycorpus = tm_map(mycorpus, tolower)
mycorpus = tm_map(mycorpus, removePunctuation)
mycorpus = tm_map(mycorpus, removeWords, stopwords(kind = "english"))

# keep a copy for stem completion later
myCorpusCopy <- mycorpus

dtm <- DocumentTermMatrix(mycorpus)

freq <- colSums(as.matrix(dtm))

ord <- order(freq,decreasing=TRUE)

freq[head(ord)]

tdm <- TermDocumentMatrix(mycorpus,
                          control = list(wordLengths = c(1, Inf)))

term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 20)
df <- data.frame(term = names(term.freq), freq = term.freq)

library(ggplot2)
ggplot(df, aes(x=term, y=freq)) + geom_bar(stat="identity") +
      xlab("Terms") + ylab("Count") + coord_flip() +
      theme(axis.text=element_text(size=7))

wordcloud(words = df$term, freq = df$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.30, 
          colors=brewer.pal(8, "Dark2"))
