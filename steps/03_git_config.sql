
USE ROLE SECURITYADMIN;
SET MY_USER = CURRENT_USER();
CREATE ROLE IF NOT EXISTS GIT_ADMIN;
GRANT ROLE GIT_ADMIN to ROLE SYSADMIN;
GRANT ROLE GIT_ADMIN TO USER IDENTIFIER($MY_USER);


USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE GIT_REPO;
USE SCHEMA PUBLIC;
GRANT OWNERSHIP ON DATABASE GIT_REPO TO ROLE GIT_ADMIN;
USE DATABASE GIT_REPO;
GRANT OWNERSHIP ON SCHEMA PUBLIC TO ROLE GIT_ADMIN;


USE ROLE GIT_ADMIN;
USE DATABASE GIT_REPO;
USE SCHEMA PUBLIC;
CREATE OR REPLACE SECRET GIT_SECRET 
    TYPE = PASSWORD 
    USERNAME = '<your_git_user' 
    PASSWORD = '<your_personal_access_token>';

--Create an API integration for interacting with the repository API
USE ROLE ACCOUNTADMIN; 
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE GIT_ADMIN;
USE ROLE GIT_ADMIN;

CREATE OR REPLACE API INTEGRATION GIT_API_INTEGRATION 
    API_PROVIDER = GIT_HTTPS_API 
    API_ALLOWED_PREFIXES = ('https://github.com/<your_git_user>') 
    ALLOWED_AUTHENTICATION_SECRETS = (GIT_SECRET) 
    ENABLED = TRUE;
    
CREATE OR REPLACE GIT REPOSITORY DE_QUICKSTART 
    API_INTEGRATION = GIT_API_INTEGRATION 
    GIT_CREDENTIALS = GIT_SECRET 
    ORIGIN = '<your git repo URL ending in .git>';
    
SHOW GIT BRANCHES IN DE_QUICKSTART;
ls @DE_QUICKSTART/branches/main;

USE ROLE ACCOUNTADMIN;
SET MY_USER = CURRENT_USER();
EXECUTE IMMEDIATE
    FROM @GIT_REPO.PUBLIC.DE_QUICKSTART/branches/main/steps/03_setup_snowflake.sql
    USING (MY_USER=>$MY_USER);
    