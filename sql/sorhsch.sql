 WITH cte_enrolled AS (SELECT DISTINCT
                          sfrstcr_pidm,
                          sfrstcr_term_code
                     FROM sfrstcr a
               INNER JOIN saturn.stvrsts b
                       ON b.stvrsts_code = a.sfrstcr_rsts_code
                    WHERE (sfrstcr_term_code = (SELECT dsc.f_get_term(SYSDATE,'nterm') - 10 AS prior_term FROM dual)
                       OR sfrstcr_term_code = (SELECT dsc.f_get_term(SYSDATE,'nterm')  AS current_term FROM dual)
                       OR sfrstcr_term_code = (SELECT dsc.f_get_term(SYSDATE,'nterm') + 10 AS future_term FROM dual))
                      AND stvrsts_incl_sect_enrl = 'Y'
                      AND sfrstcr_camp_code != 'XXX')

 SELECT NULL AS term,
                sorhsch_pidm,
                spriden_id AS banner_id,
                spriden_first_name AS first_name,
                spriden_last_name AS last_name,
                sorhsch_graduation_date AS hs_graduation_date,
                sorhsch_sbgi_code AS hs_code,
                stvsbgi_desc AS hs_description
           FROM sorhsch a
     INNER JOIN spriden b
             ON b.spriden_pidm = a.sorhsch_pidm
     INNER JOIN stvsbgi c ON c.stvsbgi_code = sorhsch_sbgi_code
          WHERE b.spriden_change_ind IS NULL
            AND b.spriden_entity_ind = 'P'
            AND sorhsch_pidm IN (SELECT DISTINCT sfrstcr_pidm FROM cte_enrolled);