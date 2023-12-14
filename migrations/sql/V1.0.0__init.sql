CREATE SCHEMA IF NOT EXISTS data_access;
-- Always set the search path to the schema you are working in
SET SEARCH_PATH TO data_access;
CREATE TABLE status_code
(
    id             SERIAL PRIMARY KEY,
    code           VARCHAR(255) NOT NULL,
    description    TEXT         NOT NULL,
    effective_date DATE         NOT NULL,
    expiry_date    DATE
);
-- Add index to code column
CREATE INDEX status_codes_code_idx
    ON status_code (code);
-- comments on table columns
COMMENT ON COLUMN status_code.id IS 'Primary key';
COMMENT ON COLUMN status_code.code IS 'Unique code for the status';
COMMENT ON COLUMN status_code.description IS 'Description of the status';
COMMENT ON COLUMN status_code.effective_date IS 'Date the status becomes effective';
COMMENT ON COLUMN status_code.expiry_date IS 'Date the status expires';
-- comments on table
COMMENT ON TABLE status_code IS 'Table to store status codes related to the workflows that will take place from submitting a request to the final decision';

CREATE TABLE data_security_classification
(
    id          SMALLSERIAL PRIMARY KEY,
    code        VARCHAR(255) NOT NULL,
    description TEXT         NOT NULL
);

-- Insert multiple rows
INSERT INTO data_security_classification (code, description)
VALUES ('Public', 'No harm to an individual, organization or government'),
       ('Protected A', 'Harm to an individual, organization or government'),
       ('Protected B', 'Serious harm to an individual, organization or government'),
       ('Protected C', 'Extremely grave harm to an individual, organization or government');

CREATE TABLE requester
(
    id               BIGSERIAL PRIMARY KEY,
    full_name        VARCHAR(255) NOT NULL,
    idir             VARCHAR(255) NOT NULL,
    idir_guid        VARCHAR(255) NOT NULL,
    email            VARCHAR(255) NOT NULL,
    ministry_name    VARCHAR(255) NOT NULL,
    branch_name      VARCHAR(255) NOT NULL,
    create_timestamp TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_timestamp TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_user      VARCHAR(255) NOT NULL,
    update_user      VARCHAR(255)
);
-- Add index to idir guid column
CREATE INDEX requester_idir_guid_idx
    ON requester (idir_guid);
-- Add index to idir column
CREATE INDEX requester_idir_idx
    ON requester (idir);
-- Add index to email column
CREATE INDEX requester_email_idx
    ON requester (email);

-- comments on table columns
COMMENT ON COLUMN requester.id IS 'Primary key';
COMMENT ON COLUMN requester.name IS 'Full Name of the requester';
COMMENT ON COLUMN requester.idir IS 'IDIR name of the requester';
COMMENT ON COLUMN requester.idir_guid IS 'IDIR GUID of the requester, this uniquely identifies the user';
COMMENT ON COLUMN requester.email IS 'Email of the requester';
COMMENT ON COLUMN requester.ministry_name IS 'Name of the ministry the requester belongs to';
COMMENT ON COLUMN requester.branch_name IS 'Name of the branch the requester belongs to';
COMMENT ON COLUMN requester.create_timestamp IS 'Date and Time the record was created';
COMMENT ON COLUMN requester.update_timestamp IS 'Date and Time the record was updated';
COMMENT ON COLUMN requester.create_user IS 'User who created the record';
COMMENT ON COLUMN requester.update_user IS 'User who updated the record';
-- comments on table
COMMENT ON TABLE REQUESTER IS 'Table to store the requester data. The IDIR GUID is used to uniquely identify the user. ';


CREATE TABLE project
(
    id                     BIGSERIAL PRIMARY KEY,
    project_overview       TEXT,
    documentation_link     TEXT,
    project_tags           TEXT,
    data_usage_description TEXT,
    end_user               TEXT
);
-- comments on table columns
COMMENT ON COLUMN project.id IS 'Primary key, Auto Generated Number by Postgres';
COMMENT ON COLUMN project.project_overview IS 'Description of the project for which access is being requested for';
COMMENT ON COLUMN project.documentation_link IS 'Link to the documentation of the project';
COMMENT ON COLUMN project.project_tags IS 'List of tags for the project. Store all the tags comma separated';
COMMENT ON COLUMN project.data_usage_description IS 'Description of the data usage, how the data will be used/consumed';
COMMENT ON COLUMN project.end_user IS 'Name of the end user';
-- comments on table
COMMENT ON TABLE PROJECT IS 'Table to store the project data related to a specific request.';

CREATE TABLE request
(
    id                              BIGSERIAL PRIMARY KEY,
    project_id                      BIGINT       NOT NULL,
    requester_id                    BIGINT       NOT NULL,
    data_tags                       TEXT,
    dataset                         TEXT,
    data_security_classification_id INT          NOT NULL,
    open_data_ind                   BOOLEAN,
    benefit_to_requester            TEXT,
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
            REFERENCES project (id);
-- Add foreign key to requester table
ALTER TABLE request
    ADD CONSTRAINT request_requester_id_fk
        FOREIGN KEY (requester_id)
            REFERENCES requester (id);
-- Add foreign key to status code table
ALTER TABLE request
    ADD CONSTRAINT request_status_code_id_fk
        FOREIGN KEY (status_code_id)
            REFERENCES status_code (id);
-- Add foreign key to data security classification table
ALTER TABLE request
    ADD CONSTRAINT request_data_security_classification_id_fk
        FOREIGN KEY (data_security_classification_id)
            REFERENCES data_security_classification (id);
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
COMMENT ON COLUMN request.id IS 'Primary key, Auto Generated Number by Postgres';
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

CREATE TABLE approval
(
    id                 BIGSERIAL PRIMARY KEY,
    request_id         BIGINT    NOT NULL,
    status_code_id     INT       NOT NULL,
    approver_idir      VARCHAR(255),
    approver_idir_guid VARCHAR(255),
    approver_email     VARCHAR(255),
    create_timestamp   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- Add foreign key to request table
ALTER TABLE approval
    ADD CONSTRAINT approval_request_id_fk
        FOREIGN KEY (request_id)
            REFERENCES request (id);
-- Add foreign key to status code table
ALTER TABLE approval
    ADD CONSTRAINT approval_status_code_id_fk
        FOREIGN KEY (status_code_id)
            REFERENCES status_code (id);
-- Add index to foreign key
CREATE INDEX approval_request_id_idx
    ON approval (request_id);
-- Add index to foreign key
CREATE INDEX approval_status_code_id_idx
    ON approval (status_code_id);
-- comments on table columns
COMMENT ON COLUMN approval.id IS 'Primary key, Auto Generated Number by Postgres';
COMMENT ON COLUMN approval.request_id IS 'Foreign key to the request table';
COMMENT ON COLUMN approval.status_code_id IS 'Foreign key to the status code table';
COMMENT ON COLUMN approval.approver_idir IS 'IDIR name of the person who approved the request, it is combined with status as there could be multiple levels of approval (DBA, Security, etc)';
COMMENT ON COLUMN approval.approver_idir_guid IS 'IDIR GUID of the person who approved the request, it is combined with status as there could be multiple levels of approval (DBA, Security, etc)';
COMMENT ON COLUMN approval.approver_email IS 'Email of the person who approved the request, it is combined with status as there could be multiple levels of approval (DBA, Security, etc)';
-- comments on table
COMMENT ON TABLE APPROVAL IS 'Table to store the approval data. For each state of Approval (Data Custodian, DBA, Security) a new row will be inserted to this table. It servers the purpose of tracking the approval process.';

