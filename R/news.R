library(tm.plugin.webmining)
library(tm)
yahoonews <- WebCorpus(YahooNewsSource("Autonomous vehicles"))
googlenews <- WebCorpus(GoogleNewsSource("Autonomous vehicles"))
reutersnews <- Corpus(ReutersNewsSource("Autonomous vehicles"))

corp <- tm_map(googlenews, removeWords, stopwords("english"))
myStopwords <- c(stopwords('english'), "tag", "news", "cluster","https")
minFreq <- 2
TermsDocsMat <- TermDocumentMatrix(corp, control = list(removePunctuation = FALSE, bounds = list(global = c(minFreq,Inf))))

DocsTermsMat <- DocumentTermMatrix(corp, control = list(removePunctuation = FALSE, bounds = list(global = c(minFreq,Inf))))
tdm <- as.matrix(TermsDocsMat)
dtm <- as.matrix(DocsTermsMat)

(freq.terms <- findFreqTerms(TermsDocsMat, lowfreq= 30))

term.freq <- rowSums(tdm)
term.freq <- subset(term.freq, term.freq>=minFreq)
word_freqs = sort(term.freq, decreasing=FALSE) 
vocab <- names(word_freqs)
# create a data frame with words and their frequencies
df = data.frame(terms=vocab, freq=word_freqs)

library(ggplot2)
df$terms <- factor( df$terms, levels=unique(as.character(df$terms)) )
ggplot(df, aes(terms,freq)) + geom_bar(stat= "identity") 
+ scale_x_discrete(name="Terms", labels=df$terms) 
+ xlab("Terms") + ylab("Freq") 
+ coord_flip()

library(DT)
datatable(df)

