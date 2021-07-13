library(tidyverse)
library(lubridate)
library(janitor)

source(here::here('rscript', 'dsu_odbc_prod_connection_object.R'))

courses_sql <- load_data_from_rds('courses.RData')

courses_columns01 <- c('term', 'crn', 'subject_code', 'section_number')
courses_columns02 <- c('error_message')

#Function Definitions
fn_return_data <- function(data, category, message, table_name, column_name) {
  output_data <- {{data}} %>%
    mutate(category = {{category}},
           error_message = {{message}},
           banner_table = {{table_name}},
           banner_column = {{column_name}}) %>%
    ungroup() %>%
    ## Sorting Data
    arrange(term, crn) %>%
    return (output_data)
}

#Courses
crse_check_01 <- filter(courses_sql, active_ind != 'A' & enrollment > 0) %>%
  fn_return_data('Courses', 'Cancelled course still has enrollments') %>%
  select(all_of(courses_columns01), enrollment, all_of(courses_columns02))



crse_check_02 <- filter(courses_sql,
                        active_ind == 'A' & 
                        start_time_1 > '1700' & 
                        str_detect(section_number, '^5', negate = TRUE) &
                        str_detect(section_number, '^7', negate = TRUE) &
                        str_detect(section_number, '^9', negate = TRUE)
                        ) %>%
  fn_return_data('Courses', 'Evening course not in 50s Series Section') %>%
  select(all_of(courses_columns01), enrollment, start_time_1, all_of(courses_columns02))

crse_check_03 <- filter(courses_sql, active_ind == 'A' & is.na(budget_code)) %>%
  fn_return_data('Courses', 'Missing schedule code') %>%
  select(all_of(courses_columns01), enrollment, budget_code, all_of(courses_columns02))

crse_check_04 <- filter(courses_sql, 
                        active_ind == 'A' & 
                        (!budget_code %in% c('BC', 'SF') &
                        (str_detect(section_number, 'V') |
                        str_detect(section_number, 'S^') |
                        str_detect(section_number, 'S') |
                        str_detect(section_number, 'X') |
                        str_detect(section_number, 'J'))) |
                        (budget_code %in% c('BC', 'SF') &
                        (str_detect(section_number, 'V', negate = TRUE) &
                        str_detect(section_number, 'S', negate =TRUE) &
                        str_detect(section_number, 'S^', negate = TRUE) &
                        str_detect(section_number, 'X', negate = TRUE) &
                        str_detect(section_number, 'J', negate = TRUE)))
                        ) %>%
  fn_return_data('Courses', 'HS course assigned to budget schedule code') %>%
  select(all_of(courses_columns01), enrollment, budget_code, all_of(courses_columns02))

# crse_check_05 <- filter(courses_sql, 
#                         active_ind == 'A' & 
#                         occs_code == 'A') %>%
#   fn_return_data('Courses', 'OCCS should be coded as V') %>%
#   select(all_of(courses_columns01), occs_code, all_of(courses_columns02))

