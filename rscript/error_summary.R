library(tidyverse)
library(visdat)

load(here::here('data', 'demographics.RData'))

#stats
a <- select(demographics_sql, 
            pidm, 
            banner_id, 
            gender,
            high_school_code,
            age,
            entry_action,
            attempted_hours, 
            full_part_time,
            student_type,
            degree,
            cur_prgm,
            residency
)




