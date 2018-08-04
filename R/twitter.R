### Libraries
library(httr)
library(devtools)
library(twitteR)
library(base64enc)
library(tm)
library(rvest)
library(tidytext)

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets = searchTwitter("Neymar",n=300,lang="pt")
tweets_df = twListToDF(tweets)

### Clean and organize data
mycorpus = tweets_df$text
mycorpus = VCorpus(VectorSource(mycorpus))
toSpace = content_transformer(function(x, pattern) gsub(pattern, " ", x))
mycorpus = tm_map(mycorpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
mycorpus = tm_map(mycorpus, toSpace, "@[^\\s]+")
mycorpus = tm_map(mycorpus, content_transformer(tolower))
mycorpus = tm_map(mycorpus, function(x) iconv(enc2utf8(x), sub = "byte"))
mycorpus = tm_map(mycorpus, removeWords, stopwords("portuguese"))
mycorpus = tm_map(mycorpus, stemDocument, language = "portuguese")
mycorpus = tm_map(mycorpus, removeNumbers)
mycorpus = tm_map(mycorpus, stripWhitespace)
mycorpus = tm_map(mycorpus, PlainTextDocument)

### Term Document Matrix
tdm = TermDocumentMatrix(mycorpus)
corpus_tf_idf = weightTfIdf(tdm, normalize = FALSE)

