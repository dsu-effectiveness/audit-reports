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
     LEFT JOIN scbcrse d
            ON d.scbcrse_subj_code = b.ssbsect_subj_code
           AND d.scbcrse_crse_numb = b.ssbsect_crse_numb
           AND d.scbcrse_eff_term = (SELECT MAX(scbcrse_eff_term)
                                       FROM scbcrse d1
                                      WHERE d1.scbcrse_subj_code = d.scbcrse_subj_code
                                        AND d1.scbcrse_crse_numb = d.scbcrse_crse_numb)
     LEFT JOIN stvschd e
            ON e.stvschd_code = b.ssbsect_schd_code
          WHERE a.ssts_code = 'A'
            AND camp_code != 'XXX'
            AND (ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') - 10 AS prior_term FROM dual)
             OR ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') AS current_term FROM dual)
             OR ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') + 10 AS future_term FROM dual)
             OR ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') - 10 + 100 AS future_term_2 FROM dual));