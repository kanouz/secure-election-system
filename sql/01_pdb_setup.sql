-- ============================================================================
-- 1. Création de la PDB et connexion
-- ============================================================================
show con_name;

CREATE PLUGGABLE DATABASE vote_pdb
ADMIN USER vote_admin IDENTIFIED BY vote
FILE_NAME_CONVERT = ('pdbseed','vote_pdb');

ALTER PLUGGABLE DATABASE vote_pdb OPEN;

ALTER SESSION SET CONTAINER=vote_pdb;

-- ============================================================================
-- 2. Tablespaces
-- ============================================================================
CREATE TABLESPACE ts_vote_data
DATAFILE '/opt/oracle/oradata/ORCLCDB/vote_pdb/ts_vote_data01.dbf'
SIZE 200M AUTOEXTEND ON NEXT 50M MAXSIZE 1G;

CREATE TABLESPACE ts_vote_index
DATAFILE '/opt/oracle/oradata/ORCLCDB/vote_pdb/ts_vote_index01.dbf'
SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE 500M;

CREATE TABLESPACE ts_vote_audit
DATAFILE '/opt/oracle/oradata/ORCLCDB/vote_pdb/ts_vote_audit01.dbf'
SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE 500M;

-- ============================================================================
-- 3. Profil utilisateur
-- ============================================================================
CREATE PROFILE vote_profile LIMIT
SESSIONS_PER_USER 3
CPU_PER_SESSION 10000
CONNECT_TIME 120
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LIFE_TIME 90;

-- ============================================================================
-- 4. Création utilisateur vote_app
-- ============================================================================
CREATE USER vote_app IDENTIFIED BY vote
DEFAULT TABLESPACE ts_vote_data
TEMPORARY TABLESPACE temp
PROFILE vote_profile;

ALTER USER vote_app QUOTA 300M ON ts_vote_data;
ALTER USER vote_app QUOTA 100M ON ts_vote_index;

GRANT CONNECT, RESOURCE, CREATE SESSION, CREATE TABLE, CREATE VIEW TO vote_app;
GRANT EXECUTE ON DBMS_CRYPTO TO vote_app;

SELECT object_name, status
FROM dba_objects
WHERE object_name = 'DBMS_CRYPTO';

-- ============================================================================
-- 5. Archivage
-- ============================================================================
ALTER DATABASE ARCHIVELOG;

-- ============================================================================
-- 6. Export / import data
-- ============================================================================
sqlldr vote_app/vote@vote_pdb control=load_votes.ctl log=load_votes.log bad=load_votes.bad;
SELECT * FROM votes;



