library(bibliometrix)
library(treemap)
library(tm)
library(pander)
library(knitr)

Dtisi <- readFiles("~/MEGA/IMTOOL2/IMtool2/data/savedrecs.bib")
database <- convert2df(Dtisi, dbsource = "isi", format = "bibtex")
df <- biblioAnalysis(database, sep = ";")
df.summary <- summary(object = df, k = 10, pause = FALSE)

knitr::kable(df.summary$MostCitedPapers)

knitr::kable(df.summary$TCperCountries, align = 'c')

knitr::kable(df.summary$MostRelSources)

knitr::kable(df.summary$MostRelKeywords)
