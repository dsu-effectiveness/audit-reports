              WITH cte_enrolled_students AS (SELECT DISTINCT
                                                    (sfvregd_pidm) AS pidm,
                                                    swvstdn_program_1 AS cur_prgm
                                               FROM baninst1.sfvregd a
                                         INNER JOIN saturn.stvrsts b
                                                 ON b.stvrsts_code = a.sfvregd_rsts_code
                                         INNER JOIN dsc.dsc_swvstdn b
                                                 ON b.swvstdn_term_code = a.sfvregd_term_code AND b.swvstdn_pidm = a.sfvregd_pidm
                                              WHERE sfvregd_term_code = '202120'
                                                AND stvrsts_incl_sect_enrl = 'Y'
                                                AND sfvregd_camp_code != 'XXX'
                                                AND (SELECT count(*)
                                                       FROM sfrstcr, stvrsts, as_catalog_schedule
                                                      WHERE sfrstcr_pidm = sfvregd_pidm
                                                        AND sfrstcr_crn = crn_key
                                                        AND sfvregd_term_code = term_code_key
                                                        AND sfrstcr_term_code = term_code_key
                                                        AND sfrstcr_rsts_code = stvrsts_code
                                                        AND stvrsts_incl_sect_enrl = 'Y'
                                                        AND upper(title) NOT LIKE '%LITERACY EXAM%') > 0)
            SELECT pidm,
                   spriden_id AS banner_id,
                   spriden_last_name AS last_name,
                   spriden_first_name AS first_name,
                   f_format_name(pidm, 'FML') AS full_name,
                   sgvacur_majr_code_1 AS majr_code,
                   stvmajr_cipc_code AS cipc_code,
                   cur_prgm AS curr_prgm,
                   sgvacur_program AS scnd_prgm
              FROM cte_enrolled_students a
        INNER JOIN sgvacur b
                ON b.sgvacur_pidm = a.pidm
        INNER JOIN stvmajr c
                ON c.stvmajr_code = b.sgvacur_majr_code_1
        INNER JOIN sgbstdn d
                ON d.sgbstdn_pidm = a.pidm
        INNER JOIN spriden e
                ON e.spriden_pidm = a.pidm
             WHERE spriden_change_ind IS NULL
               AND sgvacur_cact_code = 'ACTIVE'
               AND sgvacur_order = '2'
               AND sgvacur_stdn_rowid = d.rowid
               AND sgbstdn_term_code_eff = (SELECT MAX(c.sgbstdn_term_code_eff)
                                              FROM sgbstdn c
                                             WHERE c.sgbstdn_pidm = pidm
                                               AND c.sgbstdn_term_code_eff <= '202120')
               AND NOT (sgvacur_majr_code_1 = 'RN' -- Ignore RN   if curr program is BS-NURS-P or AA-ADN
                AND (cur_prgm = 'BS-NURS-P' OR sgvacur_program = 'AAS-ADN'))
               AND NOT (sgvacur_majr_code_1 = 'DHYG' -- Ignore DHYG if curr program is BS-DHYG-P or AA-DHYG
                AND (cur_prgm = 'BS-DHYG-P' OR sgvacur_program = 'AAS-DHYG'))
               AND NOT (sgvacur_majr_code_1 = 'MLS' -- Ignore MLS  if curr program is BS-MLS-P  or AA-MLS
                AND (cur_prgm = 'BS-MLS-P' OR sgvacur_program = 'AAS-MLS'))
               AND NOT (cur_prgm = 'BS-BU' OR sgvacur_program = 'BS-BU') -- Ignore Business Degrees
               AND NOT ((cur_prgm = 'BS-PSY' AND sgvacur_program = 'BS-ASOC') -- Ignore Psychology & Sociology combo
                OR (cur_prgm = 'BS-ASOC' AND sgvacur_program = 'BS-PSY'))
               AND NOT sgvacur_program LIKE 'A%GENED'                    -- Filter out secondary programs of AA/AS-GENED
               AND NOT cur_prgm IN ('BIS-INDV', 'BS-INTS')               -- Filter out Indiv. Study. and Ind. Study.
               AND spriden_change_ind IS NULL
             ORDER BY sgvacur_program