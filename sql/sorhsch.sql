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
            AND b.spriden_entity_ind = 'P';