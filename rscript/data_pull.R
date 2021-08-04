# Libraries ####
#library(tidyverse)
#library(DBI)
#library(odbc)
#library(here)
#library(janitor)
library(pins)

# # CONNECTION OBJECT ####
# source(here::here('rscript', 'dsu_odbc_prod_connection_object.R'))
# 
# # Pull Data from PROD
# student_sql <- get_data_from_sql("student.sql", "PROD")
# courses_sql <- get_data_from_sql('courses.sql',"PROD")
# # Used to check for duplicate SSN's
# spbpers_sql <- get_data_from_sql("spbpers.sql", "PROD")
# # Used to check for duplicate High Schools
# sorhsch_sql <- get_data_from_sql("sorhsch.sql", "PROD")
# 
# # Save data as file
# save_data_as_rds(student_sql, 'students.RData')
# save_data_as_rds(courses_sql, 'courses.RData')
# save_data_as_rds(spbpers_sql, 'spbpers.RData')
# save_data_as_rds(sorhsch_sql, 'sorhsch.RData')

# Obtain the API key from environment variable.
api_key <- Sys.getenv("RSCONNECT_SERVICE_USER_API_KEY")
# Register the connection to the pinning board.
board_register_rsconnect(key=api_key, server="https://data.dixie.edu")

# pull data from pins (pin names set from original pins)
student_sql <- pin_get("audit_reports_students_pin", board="rsconnect")
courses_sql <- pin_get("audit_reports_courses_pin", board="rsconnect")
spbpers_sql <- pin_get("audit_reports_spbpers_pin", board="rsconnect")
sorhsch_sql <- pin_get("audit_reports_sorhsch_pin", board="rsconnect")