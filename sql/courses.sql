         SELECT ssbsect_term_code AS term,
                ssbsect_crn AS crn,
                ssbsect_subj_code AS subject_code,
                ssbsect_crse_numb AS course_number,
                ssbsect_seq_numb AS section_number,
                ssbsect_insm_code AS instruction_method,
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
                begin_time1 AS start_time_1
 --               d.scbsupp_occs_code AS occs_code
           FROM as_catalog_schedule a
     INNER JOIN ssbsect b
             ON b.ssbsect_crn = a.crn_key
            AND b.ssbsect_term_code = a.term_code_key
     INNER JOIN ssrsccd c
             ON c.ssrsccd_crn = b.ssbsect_crn
            AND c.ssrsccd_term_code = a.term_code_key
--       LEFT JOIN (SELECT *
--                 FROM scbsupp a1
--           INNER JOIN voccrs_current b1 ON b1.subj = a1.scbsupp_subj_code
--                  AND b1.crse = a1.scbsupp_crse_numb
--                  AND scbsupp_eff_term  =
--                     (SELECT MAX(b.scbsupp_eff_term)
--                        FROM scbsupp b, scbcrky c
--                       WHERE b.scbsupp_subj_code = scbcrky_subj_code
--                         AND b.scbsupp_crse_numb = scbcrky_crse_numb
--                         AND b.scbsupp_subj_code = a.scbcrse_subj_code
--                         AND b.scbsupp_crse_numb = a.scbcrse_crse_numb
--                         AND c.scbcrky_term_code_end = '999999'
--                    GROUP BY b.scbsupp_subj_code,
--                             b.scbsupp_crse_numb
--                     )
--                  ) d ON d.scbsupp_crse_numb = b.ssbsect_crse_numb
--            AND scbsupp_eff_term = b.ssbsect_term_code
          WHERE ssts_code = 'A'
            AND camp_code <> 'XXX'
            AND (ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') - 10 AS prior_term FROM dual)
             OR ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') AS current_term FROM dual)
             OR ssbsect_term_code = (SELECT dsc.f_get_term(SYSDATE, 'nterm') + 10 AS future_term FROM dual));
