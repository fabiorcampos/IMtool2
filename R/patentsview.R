library(patentsview)
library(dplyr)
library(highcharter)
library(DT)
library(knitr)
library(visNetwork)
library(magrittr)
library(stringr)

# We first need to write a query. Our query will look for "database" in either 
# the patent title or abstract...Note, this isn't a terribly good way to ID our 
# patents, but it will work for the purpose of demonstration. Users who are 
# interested in writing higher-quality queries could consult the large body of 
# research that has been done in patent document retrieval.
query <- with_qfuns(
      or(
            text_phrase(patent_abstract = "autonomous vehicles"),
            text_phrase(patent_title = "autonomous vehicles")
      )
)

query
#> {"_or":[{"_text_phrase":{"patent_abstract":"database"}},{"_text_phrase":{"patent_title":"database"}}]}

# Create a list of the fields we'll need for the analysis:
fields <- c("patent_number", "assignee_organization",
            "patent_num_cited_by_us_patents", "app_date", "patent_date",
            "assignee_total_num_patents")

# Send an HTTP request to the PatentsView API to get data:
pv_out <- search_pv(query = query, fields = fields, all_pages = TRUE)


dl <- unnest_pv_data(data = pv_out$data, pk = "patent_number")
dl
#> List of 3
#>  $ assignees   :'data.frame':    49183 obs. of  3 variables:
#>   ..$ patent_number             : chr [1:49183] "4024508" ...
#>   ..$ assignee_organization     : chr [1:49183] "Honeywell Information S"..
#>   ..$ assignee_total_num_patents: chr [1:49183] "744" ...
#>  $ applications:'data.frame':    48530 obs. of  2 variables:
#>   ..$ patent_number: chr [1:48530] "4024508" ...
#>   ..$ app_date     : chr [1:48530] "1975-06-19" ...
#>  $ patents     :'data.frame':    48530 obs. of  3 variables:
#>   ..$ patent_number                 : chr [1:48530] "4024508" ...
#>   ..$ patent_num_cited_by_us_patents: chr [1:48530] "25" ...
#>   ..$ patent_date                   : chr [1:48530] "1977-05-17" ...

# Create a data frame with the top 75 assignees:
top_asgns <-
      dl$assignees %>%
      filter(!is.na(assignee_organization)) %>% # some patents are not assigned to an org (only to an inventor)
      mutate(ttl_pats = as.numeric(assignee_total_num_patents)) %>%
      group_by(assignee_organization, ttl_pats) %>% # group by ttl_pats so we can retain ttl_pats
      summarise(db_pats = n()) %>% 
      mutate(frac_db_pats = round(db_pats / ttl_pats, 3)) %>%
      ungroup() %>%
      select(c(1, 3, 2, 4)) %>%
      arrange(desc(db_pats)) %>%
      slice(1:75)

# Create datatable:
datatable(
      data = top_asgns,
      rownames = FALSE,
      colnames = c("Assignee", "DB patents","Total patents", 
                   "DB patents / total patents"),
      caption = htmltools::tags$caption(
            style = 'caption-side: top; text-align: left; font-style: italic;',
            "Table 1: Top assignees in 'databases'"
      ),
      options = list(pageLength = 10)
)


# Create a data frame with patent counts by application year for each assignee:
data <- 
      top_asgns %>%
      select(-contains("pats")) %>%
      slice(1:5) %>%
      inner_join(dl$assignees) %>%
      inner_join(dl$applications) %>%
      mutate(app_yr = as.numeric(substr(app_date, 1, 4))) %>%
      group_by(assignee_organization, app_yr) %>%
      count() 

# Plot the data using highchartr:
hc_add_series_df(highchart(), data = data, "line", x = app_yr, y = n,
                 group = assignee_organization) %>%
      hc_plotOptions(series = list(marker = list(enabled = FALSE))) %>%
      hc_xAxis(title = list(text = "Application year")) %>%
      hc_yAxis(title = list(text = "DB patents")) %>%
      hc_title(text = "Top five assignees in 'databases'") %>%
      hc_subtitle(text = "Yearly patent applications over time")

# Write a ranking function that will be used to rank patents by their citation counts:
percent_rank2 <- function(x)
      (rank(x, ties.method = "average", na.last = "keep") - 1) / (sum(!is.na(x)) - 1)

# Create a data frame with normalized citation rates and stats from Step 2: 
asng_p_dat <-
      dl$patents %>%
      mutate(patent_yr = substr(patent_date, 1, 4)) %>%
      group_by(patent_yr) %>%
      mutate(perc_cite = percent_rank2(patent_num_cited_by_us_patents)) %>%
      inner_join(dl$assignees) %>%
      group_by(assignee_organization) %>%
      summarise(mean_perc = mean(perc_cite)) %>%
      inner_join(top_asgns) %>%
      arrange(desc(ttl_pats)) %>%
      filter(!is.na(assignee_organization)) %>%
      slice(1:20) %>%
      mutate(color = "#f1c40f") %>%
      as.data.frame()

kable(head(asng_p_dat), row.names = FALSE)

# Adapted from http://jkunst.com/highcharter/showcase.html
hchart(asng_p_dat, "scatter", hcaes(x = db_pats, y = mean_perc, size = frac_db_pats,
                                    group = assignee_organization, color = color)) %>%
      hc_xAxis(title = list(text = "DB patents"), type = "logarithmic",
               allowDecimals = FALSE, endOnTick = TRUE) %>%
      hc_yAxis(title = list(text = "Mean cite perc.")) %>%
      hc_title(text = "Top assignees in 'databases'") %>%
      hc_add_theme(hc_theme_flatdark()) %>%
      hc_tooltip(useHTML = TRUE, pointFormat = tooltip_table(
            x = c("DB patents", "Mean cite percentile", "Fraction DB patents"),
            y = c("{point.db_pats:.0f}","{point.mean_perc:.2f}", "{point.frac_db_pats:.3f}")
      )) %>%
      hc_legend(enabled = FALSE)

pat_title <- function(title, number) {
      temp_title <- str_wrap(title)
      i <- gsub("\\n", "<br>", temp_title)
      paste0('<a href="https://patents.google.com/patent/US', number, '">', i, '</a>')
}

# Write a query to get the patents that are assigned a CPC code of "Y10S707/933": 
query <- qry_funs$begins(cpc_subgroup_id = "Y10S707/933")

# Create a list of fields to pull from the API:
fields <- c(
      "patent_number", 
      "patent_title",
      "cited_patent_number", # Which patents do they cite?
      "citedby_patent_number" # Which patents cite them?
)

# Send a request to the API:
res <- search_pv(query = query, fields = fields, all_pages = TRUE)

# Unnest the data found in the list columns:
res_lst <- unnest_pv_data(res$data, pk = "patent_number")
res_lst
#> List of 3
#>  $ cited_patents  :'data.frame': 685 obs. of  2 variables:
#>   ..$ patent_number      : chr [1:685] "6339767" ...
#>   ..$ cited_patent_number: chr [1:685] "4847604" ...
#>  $ citedby_patents:'data.frame': 558 obs. of  2 variables:
#>   ..$ patent_number        : chr [1:558] "6339767" ...
#>   ..$ citedby_patent_number: chr [1:558] "6480854" ...
#>  $ patents        :'data.frame': 9 obs. of  2 variables:
#>   ..$ patent_number: chr [1:9] "6339767" ...
#>   ..$ patent_title : chr [1:9] "Using hyperbolic trees to visualize data"..


pat_title <- function(title, number) {
      temp_title <- str_wrap(title)
      i <- gsub("\\n", "<br>", temp_title)
      paste0('<a href="https://patents.google.com/patent/US', number, '">', i, '</a>')
}

edges <-
      res_lst$cited_patents %>%
      semi_join(x = ., y = ., by = c("cited_patent_number" = "patent_number")) %>%
      set_colnames(c("from", "to"))

nodes <-
      res_lst$patents %>%
      mutate(
            id = patent_number,
            label = patent_number,
            title = pat_title(patent_title, patent_number)
      )

visNetwork(nodes = nodes, edges = edges, height = "400px", width = "100%",
           main = "Citations among patent citation analysis (PCA) patents") %>%
      visEdges(arrows = list(to = list(enabled = TRUE))) %>%
      visIgraphLayout()

p3 <- c("7797336", "9075849", "6499026")
res_lst2 <- lapply(res_lst, function(x) x[x$patent_number %in% p3, ])

rel_pats <-
      res_lst2$cited_patents %>%
      rbind(setNames(res_lst2$citedby_patents, names(.))) %>% 
      select(-patent_number) %>%
      rename(patent_number = cited_patent_number) %>%
      bind_rows(data.frame(patent_number = p3)) %>% 
      distinct() %>%
      filter(!is.na(patent_number))

# Look up which patents the relevant patents cite:
rel_pats_res <- search_pv(
      query = list(patent_number = rel_pats$patent_number),
      fields =  c("cited_patent_number", "patent_number", "patent_title"), 
      all_pages = TRUE,
      method = "POST"
)

rel_pats_lst <- unnest_pv_data(rel_pats_res$data, pk = "patent_number")

cited_pats <-
      rel_pats_lst$cited_patents %>%
      filter(!is.na(cited_patent_number))

full_network <- 
      cited_pats %>%
      do({
            .$ind <- group_by(., patent_number) %>%  
                  group_indices()
            group_by(., patent_number) %>%  
                  mutate(sqrt_num_cited = sqrt(n()))
      }) %>%
      inner_join(x = ., y = ., by = "cited_patent_number") %>%
      filter(ind.x > ind.y) %>%
      group_by(patent_number.x, patent_number.y) %>% 
      mutate(cosine_sim = n() / (sqrt_num_cited.x * sqrt_num_cited.y)) %>% 
      ungroup() %>%
      select(matches("patent_number\\.|cosine_sim")) %>%
      distinct()

kable(head(full_network))

hist(full_network$cosine_sim, main = "Similarity scores between patents relevant to PCA",
     xlab = "Cosine similarity", ylab = "Number of patent pairs")

edges <- 
      full_network %>%
      filter(cosine_sim >= .1) %>% 
      rename(from = patent_number.x, to = patent_number.y, value = cosine_sim) %>%
      mutate(title = paste("Cosine similarity =", as.character(round(value, 3))))

nodes <-
      rel_pats_lst$patents %>%
      rename(id = patent_number) %>%
      mutate(
            color = ifelse(id %in% p3, "#97C2FC", "#DDCC77"),
            label = id,
            title = pat_title(patent_title, id)
      )

visNetwork(nodes = nodes, edges = edges, height = "700px", width = "100%",
           main = "Network of patents relevant to PCA") %>%
      visEdges(color = list(color = "#343434")) %>%
      visOptions(highlightNearest = list(enabled = TRUE, degree = 1)) %>%
      visIgraphLayout()