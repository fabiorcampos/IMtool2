remove.packages(c("RMySQL","DBI"))
install.packages("devtools")
devtools::install_version("DBI", version = "0.5", repos = "http://cran.us.r-project.org")
devtools::install_version("RMySQL", version = "0.10.9", repos = "http://cran.us.r-project.org") 