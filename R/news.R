library(tm)
library(tm.plugin.webmining)
library(wordcloud)

yahoonews <- WebCorpus(YahooNewsSource("Autonomous vehicles"))
googlenews <- WebCorpus(GoogleNewsSource("Autonomous vehicles"))

wordcloud(googlenews, scale = c(5,0.5), max.words = 100, random.order = FALSE, rot.per = 0.35,
          use.r.layout = FALSE, colors = brewer.pal(8, "Dark2"))

wordcloud(yahoonews, scale = c(5,0.5), max.words = 100, random.order = FALSE, rot.per = 0.35,
          use.r.layout = FALSE, colors = brewer.pal(8, "Dark2"))

