/* Sets current term and calculates prior, next term */
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
                            ORDER BY stvterm_code) x),
      cte_enrolled AS (SELECT
                          sfrstcr_pidm,
                          sfrstcr_term_code,
                          sfrstcr_levl_code,
                          SUM(sfrstcr_credit_hr) AS attempted_hours,
                          CASE
                             WHEN SUM(sfrstcr_credit_hr) >= '12' THEN 'F'
                             WHEN SUM(sfrstcr_credit_hr) >= '0.5' THEN 'P'
                             ELSE 'N'
                             END AS full_part_time
                     FROM sfrstcr a
               INNER JOIN saturn.stvrsts b
                       ON b.stvrsts_code = a.sfrstcr_rsts_code
                    WHERE sfrstcr_term_code BETWEEN (SELECT prior_term FROM cte_term WHERE current_term_ind = 1) AND (SELECT next_term FROM cte_term WHERE current_term_ind = 1)
                      AND stvrsts_incl_sect_enrl = 'Y'
                      AND sfrstcr_camp_code != 'XXX'
                 GROUP BY sfrstcr_pidm,
                          sfrstcr_term_code,
                          sfrstcr_levl_code)

                SELECT DISTINCT
                      a.sfrstcr_pidm AS pidm,
                      spriden_id AS banner_id,
                      spriden_first_name AS first_name,
                      spriden_last_name AS last_name,
                      f_format_name(a.sfrstcr_pidm, 'FML') AS full_name,
                      swvstdn_styp_code AS student_type,
                      a.sfrstcr_levl_code AS student_level,
                      swvstdn_blck_code AS block,
                      SYSDATE AS daterun,
                      sfrstcr_term_code AS term,
                      CASE
                        WHEN SUBSTR(sfrstcr_term_code, 5,1) = '4' THEN 'Fall'
                        WHEN SUBSTR(sfrstcr_term_code, 5,1) = '3' THEN 'Summer'
                        WHEN SUBSTR(sfrstcr_term_code, 5,1) = '2' THEN 'Spring'
                      END AS season,
                      stvterm_desc AS term_desc,
                      stvterm_start_date AS term_start_date,
                      a.attempted_hours,
                      CASE
                         WHEN attempted_hours >= '12' THEN 'F'
                         WHEN attempted_hours >= '0.5' THEN 'P'
                         ELSE 'N'
                         END AS full_part_time,
                         swvstdn_degc_code_1 AS degree,
                         swvstdn_program_1 AS cur_prgm,
                         swvstdn_program_2 as cur_prgm_2,
                         major_code,
                         stvmajr_desc AS major_description,
                         stvmajr_cipc_code AS cipc_code,
                         concentration_1,
                         concentration_2,
                      swvstdn_resd_code AS residency,
                      spbpers_sex as gender,
                      spbpers_ssn AS ssn,
                      '***-**-' || SUBSTR(spbpers_ssn, 5,4) AS ssn_masked,
                      spbpers_birth_date AS birth_date,
                      spbpers_citz_code AS citz_code,
                      gorvisa_vtyp_code AS visa_type,
                      gorvisa_visa_expire_date AS visa_expire_date,
                      e2.sorhsch_graduation_date AS high_school_grad_date,
                      e2.sorhsch_sbgi_code AS high_school_code,
                      e3.stvsbgi_desc AS high_school_desc,
                      f_calculate_age(SYSDATE, spbpers_birth_date, spbpers_dead_date) AS age,
                      sabsupl_cnty_code_admit AS admit_county,
                      sabsupl_stat_code_admit AS admit_state,
                      sabsupl_natn_code_admit AS admit_country,
                      sabsupl_natn_code_birth AS nationality_code,
                      stvnatn_nation AS nationality_desc,
                      sabsupl_appl_no AS app_num,
                      COALESCE(shrtgpa_first_term_enrolled, sfrstcr_first_term_enrolled) AS first_term_enrolled,
                      COALESCE(shrtgpa_first_term_enrolled_start_date, sfrstcr_first_term_enrolled_start_date) AS first_term_enrolled_start_date,
                      COALESCE(sfrstcr_last_term_enrolled, shrtgpa_last_term_enrolled) AS last_term_enrolled,
                      COALESCE(sfrstcr_last_term_enrolled_end_date, shrtgpa_last_term_enrolled_end_date) AS last_term_enrolled_end_date,
                      last_transfer_term,
                      last_transfer_term_start_date,
                      --transfer_credits
                     f_calc_entry_action_4(a.sfrstcr_pidm, sfrstcr_term_code) AS entry_action,
                     m.sgrchrt_chrt_code,
                     m.sgrchrt_term_code_eff
                 FROM cte_enrolled a
           INNER JOIN dsc.dsc_swvstdn b
                   ON b.swvstdn_term_code = a.sfrstcr_term_code AND b.swvstdn_pidm = a.sfrstcr_pidm
           INNER JOIN saturn.spbpers c
                   ON c.spbpers_pidm = a.sfrstcr_pidm
           INNER JOIN saturn.spriden d
                   ON d.spriden_pidm = a.sfrstcr_pidm
                  AND d.spriden_change_ind IS NULL
             LEFT JOIN (SELECT MAX(sorhsch_graduation_date) AS high_school_grad_date,
                              sorhsch_pidm
                         FROM sorhsch
                     GROUP BY sorhsch_pidm) e
                           ON e.sorhsch_pidm = a.sfrstcr_pidm
            LEFT JOIN sorhsch e2 ON e2.sorhsch_graduation_date = e.high_school_grad_date
                          AND e2.sorhsch_pidm = e.sorhsch_pidm
            LEFT JOIN stvsbgi e3 ON e3.stvsbgi_code = e2.sorhsch_sbgi_code
            LEFT JOIN (SELECT MAX(sabsupl_appl_no||sabsupl_term_code_entry) sabsupl_key,
                              sabsupl_pidm
                         FROM sabsupl
                        WHERE sabsupl_term_code_entry <= (SELECT dsc.f_get_term(SYSDATE,'nterm') FROM dual) -- Current Term
                          AND sabsupl_term_code_entry != '999999'
                      GROUP BY sabsupl_pidm) f ON f.sabsupl_pidm = a.sfrstcr_pidm
            LEFT JOIN sabsupl g ON g.sabsupl_pidm = f.sabsupl_pidm
                  AND g.sabsupl_appl_no||g.sabsupl_term_code_entry = f.sabsupl_key
            LEFT JOIN stvnatn g2 ON g2.stvnatn_code = g.sabsupl_natn_code_birth
            LEFT JOIN gorvisa h
                   ON h.gorvisa_pidm = a.sfrstcr_pidm
            /* Enrollment History: first check SHRTGPA, then check in SFRSTCR */
            LEFT JOIN (SELECT DISTINCT shrtgpa_pidm,
                           shrtgpa_levl_code,
                           MAX(shrtgpa_term_code) AS shrtgpa_last_term_enrolled,
                           MAX(stvterm_start_date) AS shrtgpa_last_term_enrolled_start_date,
                           MAX(stvterm_end_date) AS shrtgpa_last_term_enrolled_end_date,
                           MIN(shrtgpa_term_code) AS shrtgpa_first_term_enrolled,
                           MIN(stvterm_start_date) AS shrtgpa_first_term_enrolled_start_date
                      FROM shrtgpa a
           LEFT JOIN stvterm b ON b.stvterm_code = a.shrtgpa_term_code
           LEFT JOIN (SELECT MAX(sorhsch_graduation_date) AS high_school_grad_date,
                              sorhsch_pidm
                         FROM sorhsch
                     GROUP BY sorhsch_pidm) c ON c.sorhsch_pidm = a.shrtgpa_pidm
               WHERE shrtgpa_term_code < (SELECT dsc.f_get_term(SYSDATE,'nterm') FROM dual) -- Current Term
                 AND shrtgpa_gpa_type_ind = 'I'
                 AND stvterm_start_date > c.high_school_grad_date
            GROUP BY shrtgpa_pidm, shrtgpa_levl_code) l ON l.shrtgpa_pidm = a.sfrstcr_pidm
                                                       AND l.shrtgpa_levl_code = a.sfrstcr_levl_code
           LEFT JOIN (SELECT DISTINCT sfrstcr_pidm,
                                      sfrstcr_levl_code,
                                      MAX(sfrstcr_term_code) AS sfrstcr_last_term_enrolled,
                                      MAX(stvterm_start_date) AS sfrstcr_last_term_enrolled_start_date,
                                      MAX(stvterm_end_date) AS sfrstcr_last_term_enrolled_end_date,
                                      MIN(sfrstcr_term_code) AS sfrstcr_first_term_enrolled,
                                      MIN(stvterm_start_date) AS sfrstcr_first_term_enrolled_start_date
                                 FROM sfrstcr a
                            LEFT JOIN stvterm b ON b.stvterm_code = a.sfrstcr_term_code
                            LEFT JOIN (SELECT MAX(sorhsch_graduation_date) AS high_school_grad_date,
                                              sorhsch_pidm
                                         FROM sorhsch
                                     GROUP BY sorhsch_pidm) c ON c.sorhsch_pidm = a.sfrstcr_pidm
                                WHERE sfrstcr_rsts_code IN (SELECT DISTINCT stvrsts_code FROM stvrsts WHERE stvrsts_incl_sect_enrl = 'Y')
                                  AND stvterm_start_date > c.high_school_grad_date
                                  AND sfrstcr_term_code < (SELECT dsc.f_get_term(SYSDATE,'nterm') FROM dual) -- Current Term
                             GROUP BY sfrstcr_pidm, sfrstcr_levl_code) l ON l.sfrstcr_pidm = a.sfrstcr_pidm
                                                                        AND l.sfrstcr_levl_code = a.sfrstcr_levl_code
            /* Primary Major */
            LEFT JOIN (SELECT sgvacur_pidm,
                       sgvacur_majr_code_1 AS major_code,
                       sgvacur_majr_code_conc_1 AS concentration_1,
                       sgvacur_majr_code_conc_2 AS concentration_2
                  FROM sgvacur a
            INNER JOIN sgbstdn b ON b.sgbstdn_pidm = a.sgvacur_pidm
                   AND sgvacur_cact_code = 'ACTIVE'
                   AND sgvacur_order = 1
                   AND sgvacur_stdn_rowid = b.ROWID
                   AND sgbstdn_term_code_eff = (SELECT MAX(a1.sgbstdn_term_code_eff)
                                                  FROM sgbstdn a1
                                                 WHERE a1.sgbstdn_pidm = b.sgbstdn_pidm
                                                   AND a1.sgbstdn_term_code_eff <= (SELECT dsc.f_get_term(SYSDATE,'nterm') FROM dual))
                    ) i ON i.sgvacur_pidm = a.sfrstcr_pidm
            LEFT JOIN stvmajr j ON j.stvmajr_code = i.major_code
--          /* Transfers */
            LEFT JOIN (
               SELECT
                      shrtgpa_pidm,
                      shrtgpa_levl_code,
                      MAX(shrtgpa_term_code) AS last_transfer_term,
                      MAX(stvterm_start_date) AS last_transfer_term_start_date
                 FROM shrtgpa a1
            LEFT JOIN shrtrit b1 ON b1.shrtrit_pidm = a1.shrtgpa_pidm
                  AND b1.shrtrit_seq_no = a1.shrtgpa_trit_seq_no
            LEFT JOIN stvsbgi c1 ON c1.stvsbgi_code = b1.shrtrit_sbgi_code
            LEFT JOIN stvterm d1 ON d1.stvterm_code = a1.shrtgpa_term_code
                WHERE shrtgpa_gpa_type_ind = 'T' -- Transfer GPA
                  AND stvsbgi_type_ind = 'C' -- From a College
                  AND stvsbgi_srce_ind = 'Y'
                  AND shrtgpa_term_code < (SELECT dsc.f_get_term(SYSDATE,'nterm') FROM dual)
             GROUP BY shrtgpa_pidm,
                      shrtgpa_levl_code
               ) k ON k.shrtgpa_pidm = a.sfrstcr_pidm AND k. shrtgpa_levl_code = a.sfrstcr_levl_code
             LEFT JOIN stvterm l ON l.stvterm_code = a.sfrstcr_term_code
             LEFT JOIN sgrchrt m ON m.sgrchrt_pidm = a.sfrstcr_pidm
                   AND (m.sgrchrt_chrt_code LIKE 'FT%'
                     OR m.sgrchrt_chrt_code LIKE 'TU%');