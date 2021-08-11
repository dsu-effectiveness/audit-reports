
                   SELECT sfrstcr_pidm,
                          sfrstcr_term_code,
                          sfrstcr_levl_code,
                          sfrstcr_credit_hr AS attempted_hours,
                          sfrstcr_crn,
                          ssbsect_subj_code,
                          ssbsect_crse_numb,
                          ssbsect_ssts_code,
                          ssbsect_camp_code,
                          CASE
                             WHEN ssbsect_subj_code = 'CED' THEN 'Yes'
                          END AS community_ed_ind
                     FROM sfrstcr a
               INNER JOIN saturn.stvrsts b
                       ON b.stvrsts_code = a.sfrstcr_rsts_code
               LEFT JOIN saturn.ssbsect c ON c.ssbsect_crn = a.sfrstcr_crn
                     AND c.ssbsect_term_code = sfrstcr_term_code
                    WHERE (sfrstcr_term_code = (SELECT dsc.f_get_term(SYSDATE,'nterm') - 10 AS prior_term FROM dual)
                       OR sfrstcr_term_code = (SELECT dsc.f_get_term(SYSDATE,'nterm')  AS current_term FROM dual)
                       OR sfrstcr_term_code = (SELECT dsc.f_get_term(SYSDATE,'nterm') + 10 AS future_term FROM dual))
                      AND stvrsts_incl_sect_enrl = 'Y'
                      AND sfrstcr_camp_code != 'XXX';

