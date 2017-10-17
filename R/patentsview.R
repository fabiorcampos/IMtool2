library(patentsview)
library(dplyr)
library(highcharter)
library(DT)
library(knitr)

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

# Unnest the data frames that are stored in the assignee list column:
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
            "Table 1: Top assignees in 'Autonomous Vehicles'"
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

hchart <- hc_add_series(highchart(), data = data, "line", x = app_yr, y = n,
                           group = assignee_organization) %>%
      hc_plotOptions(series = list(marker = list(enabled = FALSE))) %>%
      hc_xAxis(title = list(text = "Application year")) %>%
      hc_yAxis(title = list(text = "DB patents")) %>%
      hc_title(text = "Top five assignees in 'Autonomous vehicles'") %>%
      hc_subtitle(text = "Yearly patent applications over time")

export_hc(hchart, filename = "chart.png")

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
