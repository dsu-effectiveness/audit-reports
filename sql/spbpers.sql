         SELECT NULL AS term,
                spbpers_pidm,
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
            AND b.spriden_entity_ind = 'P';