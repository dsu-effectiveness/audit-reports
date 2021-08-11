/* Sets current term and calculates prior, next term, etc... */
WITH cte_term AS (SELECT x.stvterm_code,
                          x.stvterm_desc,
                          x.season,
                          stvterm_code + term_cal_future AS next_term,
                          stvterm_code + term_cal_future + term_cal_future_2 AS next_term_2,
                          stvterm_code - term_cal_prior AS prior_term,
                          stvterm_code - term_cal_prior - term_cal_prior_2 AS prior_term_2,
                          CASE
                             WHEN dsc.f_get_term(SYSDATE, 'nterm') = stvterm_code THEN 1 ELSE 0 END AS current_term_ind
                     FROM (SELECT a.stvterm_code,
                                  a.stvterm_desc,
                                  CASE
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '4' THEN 'Fall'
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '3' THEN 'Summer'
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '2' THEN 'Spring'
                                     END AS season,
                                  CASE
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '4' THEN 80
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '3' THEN 10
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '2' THEN 10
                                     END AS term_cal_future,
                                  CASE
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '4' THEN 10
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '3' THEN 80
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '2' THEN 10
                                     END AS term_cal_future_2,
                                  CASE
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '4' THEN 10
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '3' THEN 10
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '2' THEN 80
                                     END AS term_cal_prior,
                                  CASE
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '4' THEN 10
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '3' THEN 80
                                     WHEN SUBSTR(stvterm_code, 5, 1) = '2' THEN 10
                                     END AS term_cal_prior_2
                             FROM stvterm a
                            WHERE stvterm_code > '200220'
                              AND stvterm_code != '999999'
                            ORDER BY stvterm_code) x)

          SELECT DISTINCT ssbsect_term_code AS term,
                CASE
                   WHEN SUBSTR(ssbsect_term_code, 5,1) = '4' THEN 'Fall'
                   WHEN SUBSTR(ssbsect_term_code, 5,1) = '3' THEN 'Summer'
                   WHEN SUBSTR(ssbsect_term_code, 5,1) = '2' THEN 'Spring'
                END AS season,
                ssbsect_crn AS crn,
                ssbsect_subj_code AS subject_code,
                ssbsect_crse_numb AS course_number,
                ssbsect_seq_numb AS section_number,
                ssbsect_insm_code AS instruction_method,
                ssbsect_schd_code AS schedule_code,
                stvschd_desc AS schedule_desc,
                ssbsect_camp_code AS campus_code,
                ssbsect_enrl AS enrollment,
                ssbsect_ssts_code AS active_ind,
                ssrsccd_sccd_code AS budget_code,
                bldg_code1 AS building_code_1,
                room_code1 AS room_code_1,
                bldg_code2 AS building_code_2,
                room_code2 AS room_code_2,
                bldg_code2 AS building_code_3,
                room_code2 AS room_code_3,
                bldg_code2 AS building_code_4,
                room_code2 AS room_code_4,
                bldg_code2 AS building_code_5,
                room_code2 AS room_code_5,
                begin_time1 AS start_time_1,
                scbcrse_credit_hr_low AS credit_hours,
                scbcrse_lec_hr_low AS lecture_hours,
                scbcrse_lab_hr_low AS lab_hours,
                scbcrse_oth_hr_low AS other_hours
           FROM as_catalog_schedule a
     INNER JOIN ssbsect b
             ON b.ssbsect_crn = a.crn_key
            AND b.ssbsect_term_code = a.term_code_key
     INNER JOIN ssrsccd c
             ON c.ssrsccd_crn = b.ssbsect_crn
            AND c.ssrsccd_term_code = a.term_code_key
     LEFT JOIN (SELECT MAX(scbcrse_eff_term) AS max_scbcrse_eff_term,
                       scbcrse_subj_code,
                       scbcrse_crse_numb
                 FROM scbcrse
                GROUP BY scbcrse_subj_code,
                         scbcrse_crse_numb) d ON d.scbcrse_subj_code = b.ssbsect_subj_code
                                            AND d.scbcrse_crse_numb = b.ssbsect_crse_numb
     LEFT JOIN scbcrse e
            ON e.scbcrse_subj_code = d.scbcrse_subj_code
           AND e.scbcrse_crse_numb = d.scbcrse_crse_numb
           AND e.scbcrse_eff_term = d.max_scbcrse_eff_term
    LEFT JOIN stvschd f
           ON f.stvschd_code = b.ssbsect_schd_code
        WHERE a.ssts_code = 'A'
          AND camp_code != 'XXX'
          AND ssbsect_term_code BETWEEN (SELECT prior_term FROM cte_term WHERE current_term_ind = 1) AND (SELECT next_term_2 FROM cte_term WHERE current_term_ind = 1);

