CREATE SCHEMA IF NOT EXISTS data_access;
-- Always set the search path to the schema you are working in
SET SEARCH_PATH TO data_access;
CREATE TABLE status_code
(
    status_code_id     SERIAL PRIMARY KEY,
    status_code        VARCHAR(20)  NOT NULL,
    status_label       VARCHAR(255) NOT NULL,
    status_description VARCHAR(500) NOT NULL,
    effective_date     DATE         NOT NULL,
    expiry_date        DATE
);
-- Add index to code column
CREATE INDEX status_code_status_code_id_idx
    ON status_code (status_code);
-- comments on table columns
COMMENT ON COLUMN status_code.status_code_id IS 'Primary key';
COMMENT ON COLUMN status_code.status_code IS 'Unique code for the status, which is for used by the underlying system and mostly for machine readability';
COMMENT ON COLUMN status_code.status_label IS 'Label of the status, which is Human Readable and will be displayed to the user';
COMMENT ON COLUMN status_code.status_description IS 'Description of the status, which would contain extra verbose information about the status';
COMMENT ON COLUMN status_code.effective_date IS 'Date the status becomes effective';
COMMENT ON COLUMN status_code.expiry_date IS 'Date the status expires';
-- comments on table
COMMENT ON TABLE status_code IS 'Table to store status codes related to the workflows that will take place from submitting a request to the final decision';

CREATE TABLE data_security_classification
(
    data_security_classification_id SMALLSERIAL PRIMARY KEY,
    code                            VARCHAR(255) NOT NULL,
    description                     VARCHAR(500)         NOT NULL
);

-- Insert multiple rows
INSERT INTO data_security_classification (code, description)
VALUES ('Public', 'No harm to an individual, organization or government'),
       ('Protected A', 'Harm to an individual, organization or government'),
       ('Protected B', 'Serious harm to an individual, organization or government'),
       ('Protected C', 'Extremely grave harm to an individual, organization or government');

CREATE TABLE requester
(
    requester_id            BIGSERIAL PRIMARY KEY,
    requester_full_name     VARCHAR(255) NOT NULL,
    requester_idir          VARCHAR(255) NOT NULL,
    requester_idir_guid     VARCHAR(255) NOT NULL,
    requester_email         VARCHAR(255) NOT NULL,
    requester_ministry_name VARCHAR(255) NOT NULL,
    requester_branch_name   VARCHAR(255) NOT NULL,
    create_timestamp        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_timestamp        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_user             VARCHAR(255) NOT NULL,
    update_user             VARCHAR(255)
);
-- Add index to idir guid column
CREATE INDEX requester_requester_idir_guid_idx
    ON requester (requester_idir_guid);
-- Add index to idir column
CREATE INDEX requester_requester_idir_idx
    ON requester (requester_idir);
-- Add index to email column
CREATE INDEX requester_requester_email_idx
    ON requester (requester_email);

-- comments on table columns
COMMENT ON COLUMN requester.requester_id IS 'Primary key, Auto Generated Number by Postgres';
COMMENT ON COLUMN requester.requester_full_name IS 'Full Name of the requester';
COMMENT ON COLUMN requester.requester_idir IS 'IDIR name of the requester';
COMMENT ON COLUMN requester.requester_idir_guid IS 'IDIR GUID of the requester, this uniquely identifies the user';
COMMENT ON COLUMN requester.requester_email IS 'Email of the requester';
COMMENT ON COLUMN requester.requester_ministry_name IS 'Name of the ministry the requester belongs to';
COMMENT ON COLUMN requester.requester_branch_name IS 'Name of the ministry branch the requester belongs to';
COMMENT ON COLUMN requester.create_timestamp IS 'Date and Time the record was created';
COMMENT ON COLUMN requester.update_timestamp IS 'Date and Time the record was updated';
COMMENT ON COLUMN requester.create_user IS 'User who created the record';
COMMENT ON COLUMN requester.update_user IS 'User who updated the record';
-- comments on table
COMMENT ON TABLE REQUESTER IS 'Table to store the requester data. The IDIR GUID is used to uniquely identify the user. ';


CREATE TABLE project
(
    project_id                 BIGSERIAL PRIMARY KEY,
    project_overview           VARCHAR(255),
    project_documentation_link VARCHAR(255),
    project_tags               VARCHAR(255),
    data_usage_description     VARCHAR(500),
    end_user                   VARCHAR(255)
);
-- comments on table columns
COMMENT ON COLUMN project.project_id IS 'Primary key, Auto Generated Number by Postgres';
COMMENT ON COLUMN project.project_overview IS 'Description of the project for which access is being requested for';
COMMENT ON COLUMN project.project_documentation_link IS 'Link to the documentation of the project';
COMMENT ON COLUMN project.project_tags IS 'List of tags for the project. Store all the tags comma separated';
COMMENT ON COLUMN project.data_usage_description IS 'Description of the data usage, how the data will be used/consumed';
COMMENT ON COLUMN project.end_user IS 'Name of the end user';
-- comments on table
COMMENT ON TABLE PROJECT IS 'Table to store the project data related to a specific request.';

CREATE TABLE request
(
    request_id                      BIGSERIAL PRIMARY KEY,
    project_id                      BIGINT       NOT NULL,
    requester_id                    BIGINT       NOT NULL,
    data_tags                       VARCHAR(255),
    dataset                         VARCHAR(255),
    data_security_classification_id INT          NOT NULL,
    open_data_ind                   BOOLEAN,
    benefit_to_requester            VARCHAR(255),
    read_only_ind                   BOOLEAN,
    status_code_id                  INT          NOT NULL,
    create_timestamp                TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_timestamp                TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_user                     VARCHAR(255) NOT NULL,
    update_user                     VARCHAR(255)
);
-- Add foreign key to project table
ALTER TABLE request
    ADD CONSTRAINT request_project_id_fk
        FOREIGN KEY (project_id)
            REFERENCES project (project_id);
-- Add foreign key to requester table
ALTER TABLE request
    ADD CONSTRAINT request_requester_id_fk
        FOREIGN KEY (requester_id)
            REFERENCES requester (requester_id);
-- Add foreign key to status code table
ALTER TABLE request
    ADD CONSTRAINT request_status_code_id_fk
        FOREIGN KEY (status_code_id)
            REFERENCES status_code (status_code_id);
-- Add foreign key to data security classification table
ALTER TABLE request
    ADD CONSTRAINT request_data_security_classification_id_fk
        FOREIGN KEY (data_security_classification_id)
            REFERENCES data_security_classification (data_security_classification_id);
-- Add index to foreign key
CREATE INDEX request_project_id_idx
    ON request (project_id);
-- Add index to foreign key
CREATE INDEX request_requester_id_idx
    ON request (requester_id);
-- Add index to foreign key
CREATE INDEX request_status_code_id_idx
    ON request (status_code_id);
-- Add index to foreign key
CREATE INDEX request_data_security_classification_id_idx
    ON request (data_security_classification_id);
-- comments on table columns
COMMENT ON COLUMN request.request_id IS 'Primary key, Auto Generated Number by Postgres';
COMMENT ON COLUMN request.project_id IS 'Foreign key to the project table';
COMMENT ON COLUMN request.requester_id IS 'Foreign key to the requester table';
COMMENT ON COLUMN request.data_tags IS 'List of tags for the data. Store all the tags comma separated';
COMMENT ON COLUMN request.dataset IS 'Name of the dataset';
COMMENT ON COLUMN request.data_security_classification_id IS 'Foreign key to the data security classification table';
COMMENT ON COLUMN request.open_data_ind IS 'Boolean to indicate if the data is open data';
COMMENT ON COLUMN request.benefit_to_requester IS 'Description of the benefit to the requester';
COMMENT ON COLUMN request.read_only_ind IS 'Boolean to indicate if the data access is read only purposes';
COMMENT ON COLUMN request.status_code_id IS 'Foreign key to the status code table';
COMMENT ON COLUMN request.create_timestamp IS 'Date and Time the record was created';
COMMENT ON COLUMN request.update_timestamp IS 'Date and Time the record was updated';
COMMENT ON COLUMN request.create_user IS 'User who created the record';
COMMENT ON COLUMN request.update_user IS 'User who updated the record';
-- comments on table
COMMENT ON TABLE REQUEST IS 'Table to store the data access request data and related information.';

CREATE TABLE request_state
(
    request_state_id BIGSERIAL PRIMARY KEY,
    request_id       BIGINT    NOT NULL,
    status_code_id   INT       NOT NULL,
    actor_idir       VARCHAR(255),
    actor_idir_guid  VARCHAR(255),
    actor_email      VARCHAR(255),
    create_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- Add foreign key to request table
ALTER TABLE request_state
    ADD CONSTRAINT request_state_request_id_fk
        FOREIGN KEY (request_id)
            REFERENCES request (request_id);
-- Add foreign key to status code table
ALTER TABLE request_state
    ADD CONSTRAINT approval_status_code_id_fk
        FOREIGN KEY (status_code_id)
            REFERENCES status_code (status_code_id);
-- Add index to foreign key
CREATE INDEX approval_request_id_idx
    ON request_state (request_id);
-- Add index to foreign key
CREATE INDEX approval_status_code_id_idx
    ON request_state (status_code_id);
-- comments on table columns
COMMENT ON COLUMN request_state.request_state_id IS 'Primary key, Auto Generated Number by Postgres';
COMMENT ON COLUMN request_state.request_id IS 'Foreign key to the request table';
COMMENT ON COLUMN request_state.status_code_id IS 'Foreign key to the status code table';
COMMENT ON COLUMN request_state.actor_idir IS 'IDIR name of the person who acted the request, it is combined with status as  the actor could be from different group (DBA, Security, etc)';
COMMENT ON COLUMN request_state.actor_idir_guid IS 'IDIR GUID of the actor who acted on the request, it is combined with status as the actor could be from different group (DBA, Security, etc)';
COMMENT ON COLUMN request_state.actor_email IS 'Email of the person who approved the request, it is combined with status as the actor could be from different group (DBA, Security, etc)';
-- comments on table
COMMENT ON TABLE request_state IS 'Table to store the request state change data. For each state change  a new row will be inserted to this table. It serves the purpose of tracking the Approval/Denial process.';

