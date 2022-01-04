# install pkg deps
# install.packages(
#   pkgs = c("rvest", "magrittr", "tibble", "dplyr", "readr"),
#   # pkgs = c("rvest", "magrittr", "tibble", "tidyr", "dplyr"),
#   dependencies = c("Depends", "Imports", "LinkingTo")
# )

#load libraries
library(rvest, include.only = c("read_html", "html_node", "html_nodes", "html_attr", "html_text", "html_table"))
library(tibble, include.only = c("as_tibble", "add_column"))
library(magrittr, include.only = c("%>%"))
library(dplyr, include.only = c("rename", "select"))
library(readr, include.only = c("write_csv"))

today <- as.character(Sys.Date())

output_file <- path.expand(sprintf("docs/%s.csv", today))
latest_file <- path.expand("docs/cisa_vendor_responses.csv")

db_url <- "https://github.com/cisagov/log4j-affected-db/blob/develop/SOFTWARE-LIST.md"

pg <- read_html(db_url)
tab <- html_table(pg, fill=TRUE)[[2]]

links <- pg %>%
  html_nodes(xpath = '//*[@id="readme"]/article/table[2]') %>% html_nodes("tr") %>% html_node("a") %>%
  html_attr("href") #just the first url in each tr
                                 
links_df <- as_tibble(links)
links_df <- links_df[-1,] # remove first row as that was the header row.                                   

log4jdb <- tab %>% tibble::add_column(links_df) %>%
  select("Vendor",  "Product",  "Version(s)",  "Status",  "Update Available", "value",  "Notes",  "Other References",  "Last Updated") %>%
  rename("Vendor Link" = value)

# write to latest
log4jdb %>% write_csv(latest_file, append = FALSE )

log4jdb %>% write_csv(output_file, append = FALSE )

