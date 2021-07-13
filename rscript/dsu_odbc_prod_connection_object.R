# LIBRARIES ####
library(here)
library(tidyverse)
library(odbc)
library(DBI)
library(janitor)
library(keyring)

# FUNCTIONS ####
get_conn <- function(dsn) {
  # Server-side db connection with RStudio Connect
  if ( DBI::dbCanConnect(odbc::odbc(), 
                         DSN="oracle") ) {
    conn <- DBI::dbConnect(odbc::odbc(), 
                           DSN="oracle")
    # Local db connection
  } else {
    conn <- DBI::dbConnect(odbc::odbc(),
                           DSN = dsn,
                           UID = keyring::key_get("sis_db", "username"),
                           PWD = keyring::key_get("sis_db", "password") )
  }
  return(conn)
}

get_data_from_sql <- function(file_name, dsn="BRPT") {
  conn <- get_conn(dsn)
  df <- dbGetQuery( conn, read_file( here::here('sql', file_name) ) ) %>% 
    mutate_if(is.factor, as.character) %>% 
    clean_names() %>% 
    as_tibble()
  return(df)
}

load_data_from_rds <- function(file_name) {
  df <- readRDS( here::here('data', file_name) )
  return(df)
}

save_data_as_rds <- function(df, file_name) {
  saveRDS(df, file=here::here('data', file_name), compress=FALSE )  
}