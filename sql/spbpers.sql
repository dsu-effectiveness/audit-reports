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
                NULL AS season,
                spbpers_pidm AS pidm,
                spriden_id AS banner_id,
                spriden_first_name AS first_name,
                spriden_last_name AS last_name,
                spbpers_ssn AS ssn,
                '***-**-' || SUBSTR(spbpers_ssn, 5,4) AS ssn_masked,
                spbpers_birth_date AS birth_date
           FROM spbpers a
      LEFT JOIN spriden b
             ON b.spriden_pidm = a.spbpers_pidm
          WHERE b.spriden_change_ind IS NULL
            AND spbpers_ssn IS NOT NULL
            AND b.spriden_entity_ind = 'P'
            AND spbpers_pidm IN (SELECT DISTINCT sfrstcr_pidm FROM cte_enrolled);