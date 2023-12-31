
CREATE TABLE regions
    ( region_id      NUMERIC 
       CONSTRAINT  region_id_nn NOT NULL 
    , region_name    VARCHAR(25) 
    );

CREATE UNIQUE INDEX reg_id_pk
ON regions (region_id);

ALTER TABLE regions
ADD  CONSTRAINT regid_pk
       		 PRIMARY KEY (region_id)
    ;

/* 
********************************************************************
REM Create the COUNTRIES table to hold country information for customers
REM and company locations. 
REM OE.CUSTOMERS table and HR.LOCATIONS have a foreign key to this table.

Prompt ******  Creating COUNTRIES table ....
*/
CREATE TABLE countries 
    ( country_id      CHAR(2) 
       CONSTRAINT  country_id_nn NOT NULL 
    , country_name    VARCHAR(40) 
    , region_id       NUMERIC 
    , CONSTRAINT     country_c_id_pk 
        	     PRIMARY KEY (country_id) 
    ) ; 

ALTER TABLE countries
ADD  CONSTRAINT countr_reg_fk
        	 FOREIGN KEY (region_id)
          	  REFERENCES regions(region_id) 
     ;

/*
REM ********************************************************************
REM Create the LOCATIONS table to hold address information for company departments.
REM HR.DEPARTMENTS has a foreign key to this table.

Prompt ******  Creating LOCATIONS table ....
*/
CREATE TABLE locations
    ( location_id    NUMERIC(4)
    , street_address VARCHAR(40)
    , postal_code    VARCHAR(12)
    , city       VARCHAR(30)
	CONSTRAINT     loc_city_nn  NOT NULL
    , state_province VARCHAR(25)
    , country_id     CHAR(2)
    ) ;

CREATE UNIQUE INDEX loc_id_pk
ON locations (location_id) ;

ALTER TABLE locations
 ADD  CONSTRAINT location_id_pk PRIMARY KEY (location_id), 
 ADD  CONSTRAINT location_c_id_fk FOREIGN KEY (country_id) REFERENCES countries(country_id) 
    ;

/*
Rem 	Useful for any subsequent addition of rows to locations table
Rem 	Starts with 3300
*/

CREATE SEQUENCE locations_seq
 START WITH     3300
 INCREMENT BY   100
 MAXVALUE       9900
;

/*
REM ********************************************************************
REM Create the DEPARTMENTS table to hold company department information.
REM HR.EMPLOYEES and HR.JOB_HISTORY have a foreign key to this table.

Prompt ******  Creating DEPARTMENTS table ....
*/

CREATE TABLE departments
    ( department_id    NUMERIC(4)
    , department_name  VARCHAR(30)
	CONSTRAINT  dept_name_nn  NOT NULL
    , manager_id       NUMERIC(6)
    , location_id      NUMERIC(4)
    ) ;

CREATE UNIQUE INDEX dept_id_pk
ON departments (department_id) ;

ALTER TABLE departments
ADD  CONSTRAINT department_id_pk PRIMARY KEY (department_id),
ADD  CONSTRAINT department_loc_fk FOREIGN KEY (location_id) REFERENCES locations (location_id)
    ;
/*
Rem 	Useful for any subsequent addition of rows to departments table
Rem 	Starts with 280 
*/

CREATE SEQUENCE departments_seq
 START WITH     280
 INCREMENT BY   10
 MAXVALUE       9990
;
/*
REM ********************************************************************
REM Create the JOBS table to hold the different names of job roles within the company.
REM HR.EMPLOYEES has a foreign key to this table.

Prompt ******  Creating JOBS table ....
*/

CREATE TABLE jobs
    ( job_id         VARCHAR(10)
    , job_title      VARCHAR(35)
	CONSTRAINT     job_title_nn  NOT NULL
    , min_salary     NUMERIC(6)
    , max_salary     NUMERIC(6)
    ) ;

CREATE UNIQUE INDEX job_id_pk 
ON jobs (job_id) ;

ALTER TABLE jobs
  ADD CONSTRAINT jobid_pk PRIMARY KEY(job_id)  ;
/*
REM ********************************************************************
REM Create the EMPLOYEES table to hold the employee personnel 
REM information for the company.
REM HR.EMPLOYEES has a self referencing foreign key to this table.

Prompt ******  Creating EMPLOYEES table ....
*/

CREATE TABLE employees
    ( employee_id    NUMERIC(6)
    , first_name     VARCHAR(20)
    , last_name      VARCHAR(25)
	 CONSTRAINT     emp_last_name_nn  NOT NULL
    , email          VARCHAR(25)
	CONSTRAINT     emp_email_nn  NOT NULL
    , phone_number   VARCHAR(20)
    , hire_date      DATE
	CONSTRAINT     emp_hire_date_nn  NOT NULL
    , job_id         VARCHAR(10)
	CONSTRAINT     emp_job_nn  NOT NULL
    , salary         NUMERIC(8,2)
    , commission_pct NUMERIC(2,2)
    , manager_id     NUMERIC(6)
    , department_id  NUMERIC(4)
    , CONSTRAINT     emp_salary_min
                     CHECK (salary > 0) 
    , CONSTRAINT     emp_email_uk
                     UNIQUE (email)
    ) ;

CREATE UNIQUE INDEX emp_emp_id_pk
ON employees (employee_id) ;


ALTER TABLE employees
ADD  CONSTRAINT     emp_id_pk
                     PRIMARY KEY (employee_id),
ADD  CONSTRAINT     emp_dept_fk
                     FOREIGN KEY (department_id)
                      REFERENCES departments,
ADD  CONSTRAINT     emp_job_fk
                     FOREIGN KEY (job_id)
                      REFERENCES jobs (job_id),
ADD CONSTRAINT     emp_manager_fk
                     FOREIGN KEY (manager_id)
                      REFERENCES employees
     ;

/*Added after inserting data ----
ALTER TABLE departments
ADD  CONSTRAINT dept_mgr_fk
      		 FOREIGN KEY (manager_id)
      		  REFERENCES employees (employee_id)
     ;
*/

/*
Rem 	Useful for any subsequent addition of rows to employees table
Rem 	Starts with 207 

*/

CREATE SEQUENCE employees_seq
 START WITH     207
 INCREMENT BY   1
 ;
/*
REM ********************************************************************
REM Create the JOB_HISTORY table to hold the history of jobs that 
REM employees have held in the past.
REM HR.JOBS, HR_DEPARTMENTS, and HR.EMPLOYEES have a foreign key to this table.

Prompt ******  Creating JOB_HISTORY table ....
*/

CREATE TABLE job_history
    ( employee_id   NUMERIC(6)
	 CONSTRAINT    jhist_employee_nn  NOT NULL
    , start_date    DATE
	CONSTRAINT    jhist_start_date_nn  NOT NULL
    , end_date      DATE
	CONSTRAINT    jhist_end_date_nn  NOT NULL
    , job_id        VARCHAR(10)
	CONSTRAINT    jhist_job_nn  NOT NULL
    , department_id NUMERIC(4)
    , CONSTRAINT    jhist_date_interval
                    CHECK (end_date > start_date)
    ) ;

CREATE UNIQUE INDEX jhist_emp_id_st_date_pk 
ON job_history (employee_id, start_date) ;

ALTER TABLE job_history
ADD CONSTRAINT jhistemp_id_st_date_pk
      PRIMARY KEY (employee_id, start_date),
ADD CONSTRAINT     jhist_job_fk
                     FOREIGN KEY (job_id)
                     REFERENCES jobs,
ADD CONSTRAINT     jhist_emp_fk
                     FOREIGN KEY (employee_id)
                     REFERENCES employees,
ADD CONSTRAINT     jhist_dept_fk
                     FOREIGN KEY (department_id)
                     REFERENCES departments
    ;
/*
REM ********************************************************************
REM Create the EMP_DETAILS_VIEW that joins the employees, jobs, 
REM departments, jobs, countries, and locations table to provide details
REM about employees.

Prompt ******  Creating EMP_DETAILS_VIEW view ...
*/

CREATE OR REPLACE VIEW emp_details_view
  (employee_id,
   job_id,
   manager_id,
   department_id,
   location_id,
   country_id,
   first_name,
   last_name,
   salary,
   commission_pct,
   department_name,
   job_title,
   city,
   state_province,
   country_name,
   region_name)
AS SELECT
  e.employee_id, 
  e.job_id, 
  e.manager_id, 
  e.department_id,
  d.location_id,
  l.country_id,
  e.first_name,
  e.last_name,
  e.salary,
  e.commission_pct,
  d.department_name,
  j.job_title,
  l.city,
  l.state_province,
  c.country_name,
  r.region_name
FROM
  employees e,
  departments d,
  jobs j,
  locations l,
  countries c,
  regions r
WHERE e.department_id = d.department_id
  AND d.location_id = l.location_id
  AND l.country_id = c.country_id
  AND c.region_id = r.region_id
  AND j.job_id = e.job_id 
;


