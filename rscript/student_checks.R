library(tidyverse)
library(lubridate)
library(janitor)

#Function Definitions
fn_return_data <- function(data, category, message, table_name="", column_name="") {
  output_data <- {{data}} %>%
    mutate(category = {{category}},
           error_message = {{message}},
           banner_table = {{table_name}},
           banner_column = {{column_name}}) %>%
    ungroup() %>%
    ## Sorting Data
    arrange(term, last_name, first_name) %>%
  return (output_data)
}

#Variables
student_columns01 <- c('term', 'season', 'banner_id', 'first_name', 'last_name')
student_columns02 <- c('error_message')
student_columns03 <- c('banner_table', 'banner_column')

#Demographics - Gender
demo_check_01 <- filter(student_sql,!gender %in% c('M', 'F') | is.na(gender)) %>%
  fn_return_data('Demographics', 'Gender is blank', 'spbpers', 'spbpers_sex') %>%
  select(all_of(student_columns01), gender, all_of(student_columns02), all_of(student_columns03))

#Demographics - County
demo_check_02 <- filter(student_sql, admit_country == 'US' & is.na(admit_county)) %>%
  fn_return_data('Demographics', 'Missing County', 'sabsupl', 'sabsupl_cnty_code_admit') %>%
  select(all_of(student_columns01), admit_country, admit_state, admit_county, all_of(student_columns02), all_of(student_columns03))

#Demographics - State
demo_check_03 <- filter(student_sql, admit_country == 'US' & is.na(admit_state)) %>%
  fn_return_data('Demographics', 'Missing State', 'sabsupl', 'sabsupl_stat_code_admit') %>%
  select(all_of(student_columns01), admit_state, all_of(student_columns02), all_of(student_columns03))

#Demographics - County
demo_check_04 <- filter(student_sql, admit_state == 'UT' & is.na(admit_county)) %>%
  fn_return_data('Demographics', 'Utah applicant missing county', 'sabsupl', 'sabsupl_cnty_code_admit') %>%
  select(all_of(student_columns01), admit_country, admit_state, admit_county, all_of(student_columns02), all_of(student_columns03))

#Demographics - Country
demo_check_05 <- filter(student_sql, admit_state == 'UT' & is.na(admit_country)) %>%
  fn_return_data('Demographics', 'Missing Country', 'sabsupl', 'sabsupl_natn_code_admit') %>%
  select(all_of(student_columns01), admit_country, admit_state, all_of(student_columns02), all_of(student_columns03))

#Demographics - High School Code
demo_check_06 <- filter(student_sql, is.na(high_school_code) & age < 20) %>%
fn_return_data('Demographics', 'Missing HS Code', 'sorhsch', 'sorhsch_sbgi_code') %>%
  select(all_of(student_columns01), age, high_school_code, all_of(student_columns02), all_of(student_columns03))

#Demographics - High School Graduation Date
demo_check_07 <- filter(student_sql, birth_date >= high_school_grad_date)%>%
  fn_return_data('Demographics', 'DOB must be before HS Graduation Date', 'sorhsch, spbpers', 'sorhsch_graduation_date, spbpers_birth_date') %>%
  select(all_of(student_columns01), age, high_school_grad_date, all_of(student_columns02), all_of(student_columns03))

#Demographics - Duplicate SSN's
demo_check_08 <- filter(spbpers_sql, !is.na(spbpers_sql$ssn)) %>%
  get_dupes(ssn) %>%
  fn_return_data('Demographics', 'Duplicate SSN', 'spbpers', 'spbpers_ssn') %>%
  select(term, season, banner_id, first_name, last_name, ssn_masked, birth_date, all_of(student_columns02), all_of(student_columns03)) %>%
  arrange(ssn_masked)

#Demographics - Null citizenship
demo_check_09 <- filter(student_sql, is.na(citz_code)) %>%
  fn_return_data('Demographics', 'Null citizenship code found', 'spbpers', 'spbpers_citz_code') %>%
  select(all_of(student_columns01), citz_code, all_of(student_columns02), all_of(student_columns03))

#Demographics - High School Graduation Date is NULL
demo_check_10 <- filter(student_sql, is.na(high_school_grad_date) & student_type != 'P') %>%
  fn_return_data('Demographics', 'Missing High School Graduation Date', 'sorhsch', 'sorhsch_graduation_date') %>%
  select(all_of(student_columns01), student_type, high_school_grad_date, age, all_of(student_columns02), all_of(student_columns03))

#Demographics - Duplicate HS
demo_check_11 <- filter(sorhsch_sql, !is.na(sorhsch_sql$hs_code)) %>%
  get_dupes(sorhsch_pidm) %>%
  fn_return_data('Demographics', 'Duplicate High School Found', 'sorhsch', 'sorhsch_pidm') %>%
  select(term, season, banner_id, first_name, last_name, hs_code, hs_description, hs_graduation_date, all_of(student_columns02), all_of(student_columns03), dupe_count)

#Demographics - US non citzen nationals
demo_check_12 <- filter(student_sql, 
                       (citz_code != '5' & 
                        admit_state == 'AS') | 
                       (citz_code == '5' &
                        admit_state != 'AS')) %>%
  fn_return_data('Demographics', 'Incorrect citizen code assigned', 'spbpers', 'spbpers_citz_code') %>%
  select(all_of(student_columns01), citz_code, admit_state, all_of(student_columns02), all_of(student_columns03))

#Demographics - Undocumented students - Need to add HS Desc
demo_check_13 <- filter(student_sql, 
                        citz_code == '4' & 
                       (admit_state != 'UT' |
                        str_detect(high_school_code, '^45', negate = TRUE))
) %>%
  fn_return_data('Demographics', 'Undocumented student not from UT or from a high school outside of UT', 'spbpers', 'spbpers_citz_code') %>%
  select(all_of(student_columns01), citz_code, admit_state, high_school_code, high_school_desc, all_of(student_columns02), all_of(student_columns03))


#INTERNATIONAL STUDENTS
#Visa Errors
today <- lubridate::now()
int_error_01 <- filter(student_sql,(
  citz_code != '2' & !is.na(visa_type)
  | citz_code == '2' & is.na(visa_type)
  | !citz_code %in% c('2', '3') & !is.na(visa_type)
  | citz_code == '2' & is.na(visa_type))
  & (visa_expire_date > today | is.na(visa_expire_date))
) %>%
fn_return_data('Demographics', 'Invalid Visa Type or Citz Code', 'spbpers, gorvisa', 'spbpers_citz_code, gorvisa_vtyp_code') %>%
  select(all_of(student_columns01), citz_code, visa_type, nationality_desc, all_of(student_columns02), all_of(student_columns03))

#PROGRAM CHECKS
programs_check_01 <- filter(student_sql, 
                            !is.na(cur_prgm_2) & 
                            !cur_prgm %in% c('BS-NURS-P', 'BS-DHYG-P', 'BS-MLS-P', 'AAS-MLS', 'BS-BU', 'BS-PSY', 'BS-ASOC', 'BIS-INDV','BS-INTS') &
                            !cur_prgm_2 %in% c('AAS-ADN', 'AAS-DHYG', 'AAS-MLS', 'BS-BU', 'BS-ASOC', 'BS-PSY', 'AS-GENED')
                            ) %>%
  fn_return_data('Programs', 'Checking for valid 2nd programs', 'sorlcur', 'sorlcur_program') %>%
  select(all_of(student_columns01),  cur_prgm, cur_prgm_2, all_of(student_columns02), all_of(student_columns03))

#Programs - HS students with no ND-CONC
programs_check_02 <- filter(student_sql, !cur_prgm %in% c('ND-CONC','ND-SA','ND-CE', 'ND-ACE') & entry_action == 'HS' & !is.na(cur_prgm)) %>%
  fn_return_data('Programs', 'Entry Action is HS and not a Non-Degree Program', 'sorlcur', 'sorlcur_program') %>%
  select(all_of(student_columns01), student_type, entry_action, cur_prgm, high_school_grad_date, all_of(student_columns02), all_of(student_columns03))

#Programs - Blank Programs
#Identify Students enrolled in Community Ed Courses
programs_check_03 <- filter(student_sql, is.na(cur_prgm)) %>%
  fn_return_data('Programs', 'Blank Program', 'sorlcur', 'sorlcur_program') %>%
  select(all_of(student_columns01), degree, major_code, cur_prgm, all_of(student_columns02), all_of(student_columns03))


#STUDENT TYPE CHECKS

#Student Type - Checks to make sure student is returning student
stype_check_01 <- filter(student_sql,
                         student_type == 'R' &
                         is.na(first_term_enrolled_start_date)) %>%
  fn_return_data('Student Type', 'First term enrolled is blank') %>%
  select(all_of(student_columns01), student_type, entry_action, first_term_enrolled_start_date, high_school_grad_date, all_of(student_columns02))


#Student Type - HS Concurrent Enrollment
stype_check_02 <- filter(student_sql, term_start_date > high_school_grad_date & student_type == 'H') %>%
  fn_return_data('Student Type', 'Start Term Date is Greater Than HS Grad Date', 'shrtgpa, sfrstcr', 'shrtgpa_term_code, sfrstcr_term_code') %>%
  select(all_of(student_columns01), term_start_date, high_school_grad_date, student_type, entry_action, all_of(student_columns02))

stype_check_03 <- filter(student_sql, 
                         student_type == 'H' & 
                         !cur_prgm %in% c('ND-ACE', 'ND-CONC', 'ND-SA') &
                         (season != 'Summer' | cur_prgm != 'ND-CE')
                         ) %>%
  fn_return_data('Student Type', 'High School Student not in a HS Program') %>%
  select(all_of(student_columns01), cur_prgm, high_school_grad_date, student_type, entry_action, all_of(student_columns02))

#Student Type - Personal Interest Students - NM
stype_check_04 <- filter(student_sql, student_type == 'P' & !cur_prgm %in% c('ND-CE', 'ND-ESL') & ! is.na(cur_prgm)) %>%
  fn_return_data('Student Type', 'Degree Seeking Program, but Personal Interest Student Type') %>%
  select(all_of(student_columns01), cur_prgm, student_type, entry_action, all_of(student_columns02))

#Student Level
stype_check_05 <- filter(student_sql, 
                         !student_level == 'GR' & student_type == '1' | #New GR
                         !student_level == 'GR' & student_type == '5' | #Continuing GR
                          student_level == 'GR' & student_type == '5' & is.na(first_term_enrolled) |
                         !student_level == 'GR' & student_type == '2' | #Transfer GR
                         !student_level == 'GR' & student_type == '4' | #Readmit GR
                         !student_level == 'UG' & student_type == 'T' | #UG Transfers
                         !student_level == 'UG' & student_type == 'F' | #First-time Freshman (FF)
                         !student_level == 'UG' & student_type == 'N' | #First-time Freshman Highschool (FH)
                         !student_level == 'UG' & entry_action == 'FF' | #Entry Action (FF)
                         !student_level == 'UG' & entry_action == 'FH' #Entry Action (FH)
                         ) %>%
  fn_return_data('Student Type', 'Student level and student type does not align') %>%
  select(all_of(student_columns01), student_level, student_type, entry_action, all_of(student_columns02))

stype_check_06 <- filter(student_sql, 
                         student_level == 'GR' & student_type %in% c('1', '2') & !is.na(first_term_enrolled) & first_term_enrolled != term |
                         student_level == 'UG' & student_type == 'T' & !is.na(first_term_enrolled) & first_term_enrolled != term |
                         student_level == 'UG' & student_type %in% c('F', 'N') & !is.na(first_term_enrolled) & first_term_enrolled < term & first_term_enrolled_start_date > high_school_grad_date |
                         student_level == 'UG' & entry_action %in% c('FF', 'FH') & !is.na(first_term_enrolled) & first_term_enrolled < term & first_term_enrolled_start_date > high_school_grad_date
                         ) %>%
  fn_return_data('Student Type', 'Student has already attended.  Student Type must be C or R.') %>%
  select(all_of(student_columns01), student_level, first_term_enrolled, student_type, entry_action, all_of(student_columns02))

stype_check_07 <- filter(student_sql, 
                         student_level == 'GR' & student_type == '1' & !is.na(last_transfer_term) |
                         student_level == 'UG' & student_type %in% c('N', 'F') &  !is.na(last_transfer_term) & high_school_grad_date < last_transfer_term_start_date
                         ) %>%
  fn_return_data('Student Type', 'Student has transfer record') %>%
  select(all_of(student_columns01), student_level, last_transfer_term, student_type, entry_action, all_of(student_columns02))

stype_check_08 <- select(student_sql, everything()) %>%
                  mutate(days_since_last_enrolled = difftime(term_start_date,last_term_enrolled_end_date)) %>%
                  filter(student_level == 'GR' & student_type == '4' & ! is.na(first_term_enrolled)|
                         student_level == 'GR' & student_type == '4' & days_since_last_enrolled < 240
                         ) %>%
  fn_return_data('Student Type', 'Student has not attended before') %>%
  select(all_of(student_columns01), student_level, first_term_enrolled, student_type, entry_action, all_of(student_columns02))

stype_check_09 <- filter(student_sql, 
                         student_level == 'UG' & student_type %in% c('T', 'F', 'N') & !is.na(sgrchrt_chrt_code) & sgrchrt_term_code_eff != term |
                         student_level == 'UG' & entry_action %in% c('FF', 'FH') & !is.na(sgrchrt_chrt_code) & sgrchrt_term_code_eff != term) %>%
  fn_return_data('Student Type', 'Student has a cohort record.  Student Type must be C or R.') %>%
  select(all_of(student_columns01), student_type, sgrchrt_chrt_code, last_term_enrolled, entry_action, all_of(student_columns02))

stype_check_10 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           student_type == 'F' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation < 365
         )  %>%
  fn_return_data('Student Type', 'Graduated from HS within a year') %>%
  select(all_of(student_columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(student_columns02))

stype_check_11 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           student_type == 'N' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation > 365
  ) %>%
  fn_return_data('Student Type', 'Graduated from HS within a year') %>%
  select(all_of(student_columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(student_columns02))

stype_check_12 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           entry_action == 'FF' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation < 365
  ) %>%
  fn_return_data('Student Type', 'Graduated from HS within a year') %>%
  select(all_of(student_columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(student_columns02))

stype_check_13 <- select(student_sql, everything()) %>%
  mutate(days_since_hs_graduation = difftime(term_start_date, high_school_grad_date)) %>%
  filter(student_level == 'UG'  & 
           entry_action == 'FH' & !is.na(first_term_enrolled) & 
           days_since_hs_graduation > 365
  ) %>%
  fn_return_data('Student Type', 'Graduated from HS within a year') %>%
  select(all_of(student_columns01), first_term_enrolled, term_start_date, high_school_grad_date, days_since_hs_graduation, student_type, entry_action, all_of(student_columns02))

stype_check_14 <- filter(student_sql, is.na(student_level)) %>%
  fn_return_data('Student Level', 'Student Level is missing') %>%
  select(all_of(student_columns01), student_level, all_of(student_columns02))

#IE Checks
ie_check_01 <-  mutate(student_sql, entry_action_mapped = case_when(
                                         entry_action == 'CS' ~ 'C',
                                         entry_action == 'FF' ~ 'F',
                                         entry_action == 'FH' ~ 'F',
                                         entry_action == 'HS' ~ 'H',
                                         entry_action == 'RS' ~ 'R',
                                         entry_action == 'NM' ~ 'P',
                                         entry_action == 'TU' ~ 'T',
                                         entry_action == 'NG' ~ '1',
                                         entry_action == 'RG' ~ '3',
                                         entry_action == 'CG' ~ '5',
                                         entry_action == 'NM' ~ '0',
                                         entry_action == 'TG' ~ '2'
                                         )
         ) %>%
    filter(entry_action_mapped != student_type) %>%
    fn_return_data('Student Type', 'Entry Action does not match student type') %>%
    select(all_of(student_columns01), student_type, entry_action, first_term_enrolled, last_term_enrolled, all_of(student_columns02))
