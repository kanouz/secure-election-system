-- ============================================================================
-- 1. TABLE DE STAGING (IMPORT CSV)
-- ============================================================================
CREATE TABLE stg_votes(
    voter_id        NUMBER,
    first_name      VARCHAR2(50),
    last_name       VARCHAR2(50),
    region          VARCHAR2(50),
    election_year   NUMBER,
    candidate_id    NUMBER,
    vote_timestamp  DATE,
    vote_hash       VARCHAR2(64)
) TABLESPACE ts_vote_data;

ALTER TABLE stg_votes MODIFY (vote_hash VARCHAR2(4000));

-- ============================================================================
-- 2. TABLE METIER : VOTES
-- ============================================================================
CREATE TABLE votes (
    vote_id        NUMBER GENERATED ALWAYS AS IDENTITY,
    voter_id       NUMBER NOT NULL,
    election_id    NUMBER NOT NULL,
    candidate_id   NUMBER NOT NULL,
    vote_timestamp DATE NOT NULL,
    vote_hash      VARCHAR2(64) NOT NULL,
    CONSTRAINT pk_votes PRIMARY KEY (vote_id)
) TABLESPACE ts_vote_data;

ALTER TABLE votes MODIFY (vote_hash VARCHAR2(4000));
ALTER TABLE votes ADD CONSTRAINT uk_votes_voter UNIQUE (voter_id);

INSERT INTO votes (voter_id, election_id, candidate_id, vote_timestamp, vote_hash)
SELECT
    s.voter_id,
    e.election_id,
    s.candidate_id,
    s.vote_timestamp,
    s.vote_hash
FROM stg_votes s
JOIN elections e ON s.election_year = e.election_year;
COMMIT;

-- ============================================================================
-- 3. NORMALISATION DES DONNEES
-- ============================================================================
CREATE TABLE regions (
    region_id   NUMBER GENERATED ALWAYS AS IDENTITY,
    region_name VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_regions PRIMARY KEY (region_id),
    CONSTRAINT uq_region UNIQUE (region_name)
) TABLESPACE ts_vote_data;

INSERT INTO regions (region_name)
SELECT DISTINCT region FROM stg_votes;
COMMIT;

CREATE TABLE elections (
    election_id NUMBER GENERATED ALWAYS AS IDENTITY,
    election_year NUMBER NOT NULL,
    election_type VARCHAR2(30),
    CONSTRAINT pk_elections PRIMARY KEY (election_id),
    CONSTRAINT uq_election UNIQUE (election_year)
) TABLESPACE ts_vote_data;

INSERT INTO elections (election_year, election_type)
SELECT DISTINCT election_year, 'Législatives'
FROM stg_votes;
COMMIT;

CREATE TABLE candidates (
    candidate_id NUMBER PRIMARY KEY,
    candidate_name VARCHAR2(50),
    party VARCHAR2(50)
) TABLESPACE ts_vote_data;

INSERT INTO candidates (candidate_id, candidate_name, party)
SELECT DISTINCT candidate_id,
       'Candidate ' || candidate_id,
       'Party ' || candidate_id
FROM stg_votes;
COMMIT;

CREATE TABLE voters (
    voter_id   NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name  VARCHAR2(50),
    region_id  NUMBER,
    created_at DATE DEFAULT SYSDATE,
    CONSTRAINT fk_voter_region FOREIGN KEY (region_id)
        REFERENCES regions(region_id)
) TABLESPACE ts_vote_data;

INSERT INTO voters (voter_id, first_name, last_name, region_id)
SELECT DISTINCT
    s.voter_id,
    s.first_name,
    s.last_name,
    r.region_id
FROM stg_votes s
JOIN regions r ON s.region = r.region_name;
COMMIT;

