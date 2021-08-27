library(tidyverse)
library(lubridate)
library(janitor)

courses_columns01 <- c('term', 'season', 'crn', 'subject_code', 'course_number', 'section_number')
courses_columns02 <- c('enrollment', 'error_message')

#Function Definitions
fn_return_data <- function(data, category, message, table_name="", column_name="") {
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
  select(all_of(courses_columns01), all_of(courses_columns02))



crse_check_02 <- filter(courses_sql,
                        active_ind == 'A' & 
                        start_time_1 > '1700' & 
                        str_detect(section_number, '^5', negate = TRUE) &
                        str_detect(section_number, '^7', negate = TRUE) &
                        str_detect(section_number, '^9', negate = TRUE)
                        ) %>%
  fn_return_data('Courses', 'Evening course not in 50s Series Section') %>%
  select(all_of(courses_columns01), start_time_1, all_of(courses_columns02))

crse_check_03 <- filter(courses_sql, active_ind == 'A' & is.na(budget_code) & subject_code != 'CED' |
                        (!budget_code %in% c('BA','BC','BU','BV','BY','SD','SF','SM','SP','SQ') & subject_code != 'CED')) %>%
  fn_return_data('Courses', 'Missing budget code') %>%
  select(all_of(courses_columns01), budget_code, all_of(courses_columns02))

crse_check_04 <- filter(courses_sql, 
                        active_ind == 'A' & 
                        (!budget_code %in% c('BC', 'SF') &
                        (str_detect(section_number, 'V') |
                        str_detect(section_number, 'S^') |
                        str_detect(section_number, 'S') |
                        str_detect(section_number, 'X') |
                        str_detect(section_number, 'J'))) |
                        (budget_code %in% c('BC', 'SF') &
                        (
                          str_detect(section_number, 'V', negate = TRUE) &
                          str_detect(section_number, 'S', negate =TRUE) &
                          str_detect(section_number, 'S^', negate = TRUE) &
                          str_detect(section_number, 'X', negate = TRUE) &
                          str_detect(section_number, 'J', negate = TRUE)))
                        ) %>%
  fn_return_data('Courses', 'HS course assigned to budget schedule code') %>%
  select(all_of(courses_columns01), budget_code, all_of(courses_columns02))

# crse_check_05 <- filter(courses_sql, 
#                         active_ind == 'A' & 
#                         occs_code == 'A') %>%
#   fn_return_data('Courses', 'OCCS should be coded as V') %>%
#   select(all_of(courses_columns01), occs_code, all_of(courses_columns02))

crse_check_06 <- filter(courses_sql,
                       (campus_code != 'O01' & str_detect(section_number, '^4') & instruction_method == 'I' |
                       campus_code %in% c('O01', 'UOS') & str_detect(section_number, '^4') & instruction_method != 'I' |
                       campus_code == 'O01' & str_detect(section_number, '^4', negate = TRUE) & instruction_method == 'I' |
                       campus_code != 'O01' & str_detect(section_number, '^4', negate = TRUE) & instruction_method == 'I' |
                       campus_code %in% c('O01', 'UOS') & str_detect(section_number, '^4', negate = TRUE) & instruction_method == 'I' |
                       campus_code %in% c('O01', 'UOS') & str_detect(section_number, '4', negate = TRUE) & instruction_method != 'I')) %>%
                fn_return_data('Courses', 'Online Error') %>%
                select(all_of(courses_columns01), campus_code, instruction_method, all_of(courses_columns02))

crse_check_07 <- filter(courses_sql, 
                        !instruction_method %in% c('I', 'E') &
                        !building_code_1 %in% c('VIRT', 'ONLINE') &
                        !is.na(building_code_1) &
                        is.na(room_code_1)
                        ) %>%
                fn_return_data('Courses', 'Courses with no room specified') %>%
                select(all_of(courses_columns01), building_code_1, room_code_1, all_of(courses_columns02))

#Schedule Type
schd_check_01 <- filter(courses_sql,
                        subject_code != 'CED' &
                        enrollment != 0 &
                        schedule_code %in% c('LEC', 'LEX') &
                        (!is.na(lecture_hours) &
                        !is.na(other_hours) & 
                        other_hours > 0)) %>%
                fn_return_data('Schedule Type', paste(schedule_desc, ' type should only have lecture hours')) %>%
                select(all_of(courses_columns01), schedule_code, credit_hours, lecture_hours, lab_hours, other_hours, all_of(courses_columns02))
 

schd_check_02 <- filter(courses_sql,
                        subject_code != 'CED' &
                        enrollment != 0 &
                        schedule_code %in% c('LAB', 'LBC', 'ACT') & 
                        is.na(lab_hours)) %>%
                        fn_return_data('Schedule Type', paste(schedule_desc, ' type should only have lab hours')) %>%
                        select(all_of(courses_columns01), schedule_code, credit_hours, lecture_hours, lab_hours, other_hours, all_of(courses_columns02))

schd_check_03 <- filter(courses_sql,
                        subject_code != 'CED' &
                        enrollment != 0 &
                        schedule_code == 'LAB' & 
                        credit_hours != 0) %>%
                        fn_return_data('Schedule Type', paste(schedule_desc, ' type should have zero hours')) %>%
                        select(all_of(courses_columns01), schedule_code, credit_hours, lecture_hours, lab_hours, other_hours, all_of(courses_columns02))

schd_check_04 <- filter(courses_sql,
                        subject_code != 'CED' &
                        enrollment != 0 &
                        schedule_code == 'LBC' & 
                        is.na(credit_hours)) %>%
                        fn_return_data('Schedule Type', paste(schedule_desc, ' type should have zero hours')) %>%
                        select(all_of(courses_columns01), schedule_code, credit_hours, lecture_hours, lab_hours, other_hours, all_of(courses_columns02))

schd_check_05 <- filter(courses_sql,
                        subject_code != 'CED' &
                        enrollment != 0 &
                        schedule_code == 'LEL' & 
                        (is.na(credit_hours) | is.na(lab_hours))) %>%
                        fn_return_data('Schedule Type', paste(schedule_desc, ' type should have lecture/lab hours')) %>%
                        select(all_of(courses_columns01), schedule_code, credit_hours, lecture_hours, lab_hours, other_hours, all_of(courses_columns02))

schd_check_06 <- filter(courses_sql,
                        subject_code != 'CED' &
                        enrollment != 0 &
                        !schedule_code %in% c('LEC', 'LEX', 'LEL') & 
                        lecture_hours > 0) %>%
                        fn_return_data('Schedule Type', paste(schedule_desc, ' type is not a lecture course')) %>%
                        select(all_of(courses_columns01), schedule_code, credit_hours, lecture_hours, lab_hours, other_hours, all_of(courses_columns02))

schd_check_07 <- filter(courses_sql,
                        subject_code != 'CED' &
                        enrollment != 0 &
                        !schedule_code %in% c('LAB', 'LBC', 'LEL', 'ACT') & 
                        lab_hours > 0) %>%
                        fn_return_data('Schedule Type', paste(schedule_desc, ' type is not a lab course')) %>%
                        select(all_of(courses_columns01), schedule_code, credit_hours, lecture_hours, lab_hours, other_hours, all_of(courses_columns02))


