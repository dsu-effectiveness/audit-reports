# Libraries ####

library(tidyverse)
library(DBI)
library(odbc)
library(here)
library(janitor)

# CONNECTION OBJECT ####
source(here::here('rscript', 'dsu_odbc_prod_connection_object.R'))

# Pull Data from PROD
student_sql <- get_data_from_sql("student.sql", "PROD")
courses_sql <- get_data_from_sql('courses.sql',"PROD")

# Save data as file
save_data_as_rds(courses_sql, 'courses.RData')
save_data_as_rds(student_sql, 'students.RData')

