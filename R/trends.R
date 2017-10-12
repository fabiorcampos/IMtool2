library(gtrendsR)
library(forecast)
library(tseries)

keyword = c("autonomous vehicles", "self driving cars")

res = gtrends(keyword, geo = "", time = "all", gprop = "web", category = 0, hl = "en-US")

keyword_pt = "carro autonomo"

res_pt = gtrends(keyword_pt, geo = "BR", time = "all", gprop = "web", category = 0)

gt.fc.en <- res$interest_over_time
fc.en <- forecast(res$hits)

xt_en <- window(gt.fc.en[,2],end=218)
xf_en <- window(gt.fc.en[,2],start=219)

gt.fc.br <- res_pt$interest_over_time
fc.br <- forecast(res_pt$hits)

xt_pt <- window(gt.fc.br[,2],end=100)
xt_pt <- window(gt.fc.br[,2],start = 101)

plot(res)

rwd_en <- rwf(xt_en,drift=T,h=25)
plot(rwd_en,main="Random Walk with Drift Method",ylab="Level",xlab="Tseries")
lines(gt.fc.en[,2])

plot(res_pt)

rwd_br <- rwf(xt_pt,drift=T,h=66)
plot(rwd_br,main="Random Walk with Drift Method",ylab="Level",xlab="Months")
lines(gt.fc.br[,2])