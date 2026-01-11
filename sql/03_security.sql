-- ============================================================================
-- 1. Blocage des modifications de votes
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_no_update_votes
BEFORE UPDATE OR DELETE ON votes
BEGIN
   RAISE_APPLICATION_ERROR(-20001,'Modification des votes interdite');
END;
/

-- ============================================================================
-- 2. Vérification cryptographique du vote
-- ============================================================================

CREATE OR REPLACE FUNCTION check_vote_hash (
    p_voter_id NUMBER,
    p_candidate_id NUMBER,
    p_vote_timestamp DATE,
    p_vote_hash VARCHAR2
) RETURN NUMBER IS
    v_raw_hash RAW(32);
    v_hash     VARCHAR2(64);
BEGIN
    v_raw_hash := DBMS_CRYPTO.HASH(
        UTL_RAW.CAST_TO_RAW(
            p_voter_id || ':' ||
            p_candidate_id || ':' ||
            TO_CHAR(p_vote_timestamp,'YYYYMMDDHH24MISS')
        ),
        DBMS_CRYPTO.HASH_SH256
    );

    v_hash := LOWER(RAWTOHEX(v_raw_hash));

    IF v_hash = LOWER(p_vote_hash) THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
/

SHOW ERRORS;

-- ============================================================================
-- 3. Tests de fraude / scénarios
-- ============================================================================

-- Exemple de tentative de fraude
UPDATE votes SET candidate_id = 99 WHERE vote_id = 1;

-- Désactivation temporaire des triggers pour test
ALTER TRIGGER vote_app.trg_no_update_votes DISABLE;
ALTER TRIGGER vote_app.trg_no_double_vote DISABLE;

-- Reset des votes pour tests
TRUNCATE TABLE vote_app.votes;

-- Réactivation des triggers
ALTER TRIGGER vote_app.trg_no_update_votes ENABLE;
ALTER TRIGGER vote_app.trg_no_double_vote ENABLE;

-- ============================================================================
-- 4. Insertion finale des votes
-- ============================================================================

INSERT INTO votes (
    voter_id,
    election_id,
    candidate_id,
    vote_timestamp,
    vote_hash
)
SELECT
    s.voter_id,
    e.election_id,
    s.candidate_id,
    s.vote_timestamp,
    s.vote_hash
FROM stg_votes s
JOIN elections e
  ON e.election_year = s.election_year;

SELECT * FROM votes;

-- Suppression du trigger anti double vote après finalisation
DROP TRIGGER trg_no_double_vote;

-- Résultats électoraux
SELECT
    c.candidate_name,
    COUNT(*) total_votes
FROM votes v
JOIN candidates c ON c.candidate_id = v.candidate_id
GROUP BY c.candidate_name;

-- Nettoyage final des votes
DELETE FROM votes;
COMMIT;

-- Réactivation du trigger de sécurité
ALTER TRIGGER trg_no_update_votes ENABLE;

