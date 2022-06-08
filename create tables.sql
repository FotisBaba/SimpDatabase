CREATE TABLE "Room"(
	room_id VARCHAR(10) primary key NOT NULL,
	room_t room_type,
	Capacity integer NOT NULL
);

CREATE TABLE "LearningActivity"(
	start_time integer NOT NULL,
	end_time integer NOT NULL,
	weekday integer NOT NULL,
	room_id VARCHAR(10) NOT NULL,
	serial_number integer NOT NULL,
	course_code character NOT NULL,
	FOREIGN KEY (serial_number, course_code) REFERENCES "CourseRun"(serial_number, course_code),
	PRIMARY KEY (start_time, end_time, weekday, room_id, serial_number, course_code),
	activity_t activity_type
);

ALTER TABLE "LearningActivity"
	ADD CONSTRAINT "LearningActivity_room_id_fk" FOREIGN KEY (room_id)
	REFERENCES "Room" (room_id)
	ON UPDATE CASCADE
	ON DELETE CASCADE;
	
ALTER TABLE "LearningActivity"
	ADD CONSTRAINT "LearningActivity_pk" UNIQUE (start_time, end_time, weekday, room_id, serial_number, course_code);

CREATE TABLE "Participates"(
	amka integer NOT NULL,
	start_time integer UNIQUE NOT NULL,
	end_time integer NOT NULL,
	weekday integer NOT NULL,
	room_id VARCHAR(10) NOT NULL,
	serial_number integer NOT NULL,
	course_code character NOT NULL,
	FOREIGN KEY (amka) REFERENCES "Person"(amka),
	FOREIGN KEY (start_time, end_time, weekday, room_id, serial_number, course_code) REFERENCES "LearningActivity"(start_time, end_time, weekday, room_id, serial_number, course_code),
	PRIMARY KEY(amka, start_time, end_time, weekday, room_id, serial_number, course_code),
	role_t role_type
);


CREATE TABLE "Person"(
	amka integer primary key NOT NULL,
	email character varying(100) NOT NULL,
	name character varying(50) NOT NULL,
	father_name character varying(50) NOT NULL,
	surname character varying(50) NOT NULL	
);


ALTER TABLE "Person"
	ADD CONSTRAINT "Person_UN" UNIQUE (per_amka, per_name, per_father_name, per_surname, per_email);


ALTER TABLE "Student"
	ADD CONSTRAINT "Person_amka_fkey" FOREIGN KEY (amka, name, father_name, surname, email)
	REFERENCES "Person" (per_amka, per_name, per_father_name, per_surname, per_email)
	ON UPDATE CASCADE
	ON DELETE CASCADE;


ALTER TABLE "LearningActivity" DROP CONSTRAINT "LearningActivity_room_id_fk";
ALTER TABLE "Participates" DROP CONSTRAINT "Participates_start_time_fkey";


ALTER TABLE "Room"
	ALTER COLUMN room_id TYPE VARCHAR(10);
	
ALTER TABLE "LearningActivity"
	ALTER COLUMN room_id TYPE VARCHAR(10);
	
ALTER TABLE "Participates"
	ALTER COLUMN room_id TYPE VARCHAR(10);

UPDATE "Room"
SET "room_t" = 'computer_room'
WHERE
	"room_id"='M.K.';



CREATE OR REPLACE FUNCTION insert_rooms()
	RETURNS void AS
$$
BEGIN
	INSERT INTO "Room"
	VALUES
	 ('141Π98', 'lecture_room', '300'),
	 ('145Π42', 'lecture_room', '60'),
	 ('145Π58', 'lecture_room', '60'),
	 ('145Π39', 'lecture_room', '60'),
	 ('2041', 'lecture_room', '50'),
	 ('2042', 'lecture_room', '50'),
	 ('M.K.', 'computer_room', '50'),
	 ('MHLLAB', 'lab_room', '30'),
	 ('ELELAB', 'lab_room', '30'),
	 ('PHYLAB', 'lab_room', '30'),
	 ('COMLAB', 'lab_room', '30'),
	 ('TELLAB', 'lab_room', '30'),
	 ('OFF1', 'office', '20'),
	 ('OFF2', 'office', '20'),
 	 ('OFF3', 'office', '20');
END;
$$
LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION create_email(n VARCHAR(30), s VARCHAR(30)) RETURNS VARCHAR(30) AS $$
DECLARE
  email VARCHAR(30);  
BEGIN
  email = concat(name::VARCHAR(1), surname, '@isc.tuc.gr');
   RETURN email; 
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_student_amka() RETURNS integer AS 
$$
DECLARE 
	amk integer;
BEGIN
	SELECT amka INTO amk 
	FROM "Student"
	WHERE amka = (SELECT MAX(amka)
				  FROM "Student");
	amk= amk +1;
	RETURN amk;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_professor_amka() RETURNS integer AS 
$$
DECLARE 
	amk integer;
BEGIN
	SELECT "amka" INTO amk 
	FROM "Professor"
	WHERE amka = (SELECT MAX(amka)
				  FROM "Professor");
	amk= amk +1;
	RETURN amk;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_labstaff_amka() RETURNS integer AS 
$$
DECLARE 
	amk integer;
BEGIN
	SELECT "amka" INTO amk 
	FROM "LabStaff"
	WHERE amka = (SELECT MAX(amka)
				  FROM "LabStaff");
	amk= amk +1;
	RETURN amk;
END
$$
LANGUAGE plpgsql;



	 
 




create type person_type as ENUM('Professor', 'Labstaff', 'Student');

ALTER TABLE "Person" ADD person_t person_type;

create table "PersonType"(
	p_t person_type
);

insert into "PersonType"
values 
	('Student'),
	('Professor'),
	('Labstaff');






CREATE OR REPLACE FUNCTION random_fnames(n integer) RETURNS table(father_name character, id integer) AS $$
BEGIN
	RETURN QUERY
	SELECT fn.name, row_number() OVER ()::integer
	FROM (SELECT "Name".name
	FROM "Name"
	WHERE ("Name".sex)='M'
	ORDER BY random() LIMIT n) as fn;
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_students(year integer, num integer) RETURNS void AS $$
BEGIN
		INSERT INTO "Student"
		SELECT create_student_amka(), name, father_name, adapt_surname(surname,sex), create_email(name, adapt_surname(surname,sex)),
		create_am(year, n.id), to_date(year 'YYYY')
		FROM random_names(num) n JOIN random_surnames(num) s USING (id) JOIN random_fnames(num) fn USING (id);

END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION random_rank() RETURNS rank_type AS $$
DECLARE ty rank_type;
BEGIN
	execute format(
    $sql$
      select elem 
      from unnest(enum_range(null::%1$I)) as elem
      order by random() 
      limit 1;
    $sql$,
    pg_typeof(null::rank_type)
  ) into ty;
  RETURN ty;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_lab() RETURNS integer AS $$
BEGIN
	RETURN l. lab_code
	FROM "Lab" l
	ORDER BY random() LIMIT 1;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_level() RETURNS level_type AS $$
DECLARE ty level_type;
BEGIN
	execute format(
    $sql$
      select elem 
      from unnest(enum_range(null::%1$I)) as elem
      order by random() 
      limit 1;
    $sql$,
    pg_typeof(null::level_type)
  ) into ty;
  RETURN ty;

END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_professor(num integer) RETURNS void AS $$
BEGIN

		INSERT INTO "Professor"
		SELECT create_professor_amka(), name, father_name, adapt_surname(surname,sex), create_email(name, adapt_surname(surname,sex)),
		random_lab(), random_rank()
		FROM random_names(num) n JOIN random_surnames(num) s USING (id) JOIN random_fnames(num) fn USING (id);

END
$$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION insert_labstaff(num integer) RETURNS void AS $$
BEGIN

		INSERT INTO "LabStaff"
		SELECT create_labstaff_amka(), name, father_name, adapt_surname(surname,sex), create_email(name, adapt_surname(surname,sex)),
		random_lab(), random_level()
		FROM random_names(num) n JOIN random_surnames(num) s USING (id) JOIN random_fnames(num) fn USING (id);

END
$$
LANGUAGE plpgsql;


INSERT INTO "Person"(per_amka, per_name, per_email, per_father_name, per_surname, person_t)
SELECT amka, name, email, father_name, surname, p_t
FROM "Student", "PersonType"
WHERE p_t='Student';


INSERT INTO "Person"(per_amka, per_name, per_email, per_father_name, per_surname, person_t)
SELECT amka, name, email, father_name, surname, p_t
FROM "Professor", "PersonType"
WHERE p_t='Professor';

INSERT INTO "Person"(per_amka, per_name, per_email, per_father_name, per_surname, person_t)
SELECT amka, name, email, father_name, surname, p_t
FROM "LabStaff", "PersonType"
WHERE p_t='Labstaff';


DO
$$
BEGIN
	INSERT INTO "LearningActivity"
	VALUES
	 ('12', '14', '2', '141Π98', '23', 'ΑΓΓ 101', 'lecture'),
	 ('15', '17', '6', '145Π42', '23', 'ΑΓΓ 101', 'lecture'),
	 ('9', '12', '2', '141Π98', '1', 'ΠΛΗ 101', 'lecture'),
	 ('11', '13', '5', '2041', '1', 'ΠΛΗ 101', 'tutorial'),
	 ('13', '14', '3', 'M.K.', '1', 'ΠΛΗ 101', 'lab'),
	 ('10', '13', '6', '141Π98', '9', 'ΜΑΘ 101', 'lecture'),
	 ('13', '14', '6', '141Π98', '9', 'ΜΑΘ 101', 'tutorial'),
 	 ('10', '12', '4', '141Π98', '3', 'ΗΡΥ 101', 'lecture'),
 	 ('9', '11', '5', '141Π98', '3', 'ΗΡΥ 101', 'lecture'),
 	 ('12', '14', '4', 'MHLLAB', '3', 'ΗΡΥ 101', 'lab'),
	 ('14', '17', '5', '145Π58', '15', 'ΧΗΜ 101', 'lecture'),	 
	 
	 
	 ('12', '14', '2', '141Π98', '6', 'ΦΥΣ 102', 'lecture'),
	 ('13', '14', '6', '141Π98', '6', 'ΦΥΣ 102', 'tutorial'),
 	 ('12', '14', '4', 'PHYLAB', '6', 'ΦΥΣ 102', 'lab'),
	 ('15', '17', '6', '141Π98', '4', 'ΗΡΥ 102', 'lecture'),
	 ('11', '13', '5', '145Π42', '4', 'ΗΡΥ 102', 'tutorial'),
	 ('9', '11', '5', 'ELELAB', '4', 'ΗΡΥ 102', 'lab'),
	 ('9', '12', '2', '141Π98', '18', 'ΠΛΗ 102', 'lecture'),
	 ('10', '12', '4', '145Π39', '18', 'ΠΛΗ 102', 'tutorial'),
	 ('13', '14', '3', 'M.K.', '18', 'ΠΛΗ 102', 'lab'),
	 ('10', '13', '6', '145Π58', '2', 'ΠΛΗ 111', 'lecture'),
 	 ('14', '15', '3', '2042', '2', 'ΠΛΗ 111', 'tutorial'),


	 
	 ('10', '12', '4', '141Π98', '7', 'ΗΡΥ 201', 'lecture'),
 	 ('9', '11', '5', '141Π98', '7', 'ΗΡΥ 201', 'tutorial'),
 	 ('14', '16', '3', 'MHLLAB', '7', 'ΗΡΥ 201', 'lab'),
	 ('10', '13', '6', '145Π42', '21', 'ΠΛΗ 211', 'lecture'),
	 ('13', '14', '6', '145Π58', '21', 'ΠΛΗ 211', 'tutorial'),
	 ('12', '14', '4', 'M.K.', '21', 'ΠΛΗ 211', 'lab'),	 
	 ('12', '14', '2', '141Π98', '15', 'ΗΡΥ 202', 'lecture'),
	 ('15', '17', '6', '145Π42', '15', 'ΗΡΥ 202', 'tutorial'),
	 ('12', '14', '4', 'ELELAB', '15', 'ΗΡΥ 202', 'lab'),
	 ('14', '17', '5', '141Π98', '5', 'ΤΗΛ 201', 'lecture'),	
	 ('11', '13', '5', '145Π39', '5', 'ΤΗΛ 201', 'tutorial'),
	 ('13', '14', '3', 'M.K.', '5', 'ΤΗΛ 201', 'lab'),
	 

	 
	 
 	 ('11', '14', '5', '141Π98', '20', 'ΗΡΥ 203', 'lecture'),
	 ('9', '11', '5', '141Π98', '20', 'ΗΡΥ 203', 'tutorial'),
	 ('14', '16', '3', 'MHLLAB', '20', 'ΗΡΥ 203', 'lab'),
	 ('10', '13', '6', '145Π42', '20', 'ΠΛΗ 202', 'lecture'),
	 ('12', '14', '4', '145Π42', '20', 'ΠΛΗ 202', 'tutorial'),
	 ('13', '14', '3', 'M.K.', '20', 'ΠΛΗ 202', 'lab'),	 
 	 ('10', '12', '4', '141Π98', '10', 'ΑΓΓ 202', 'lecture'),	
	 ('12', '14', '2', '141Π98', '10', 'ΑΓΓ 202', 'lecture'),	 
	 ('14', '17', '5', '2041', '18', 'ΤΗΛ 211', 'lecture'),	
	 ('13', '14', '6', '2041', '18', 'ΤΗΛ 211', 'tutorial'),
	 ('12', '14', '4', 'TELLAB', '18', 'ΤΗΛ 211', 'lab'),



	 ('17', '19', '2', 'OFF1', '23', 'ΑΓΓ 101', 'office_hours'),
	 ('17', '19', '2', 'OFF2', '1', 'ΠΛΗ 101', 'office_hours'),
	 ('14', '16', '5', 'OFF3', '1', 'ΠΛΗ 101', 'office_hours'),
	 ('17', '19', '6', 'OFF3', '9', 'ΜΑΘ 101', 'office_hours'),
 	 ('15', '16', '4', 'OFF1', '3', 'ΗΡΥ 101', 'office_hours'),
	 ('12', '14', '3', 'OFF2', '15', 'ΧΗΜ 101', 'office_hours'),	 
	 
	
	 ('17', '19', '2', 'OFF1', '18', 'ΦΥΣ 102', 'office_hours'),
	 ('17', '19', '2', 'OFF2', '2', 'ΗΡΥ 102', 'office_hours'),
	 ('14', '16', '5', 'OFF3', '2', 'ΗΡΥ 102', 'office_hours'),
	 ('17', '19', '6', 'OFF3', '20', 'ΠΛΗ 102', 'office_hours'),
 	 ('15', '16', '4', 'OFF1', '20', 'ΠΛΗ 102', 'office_hours'),
	 ('12', '14', '3', 'OFF2', '24', 'ΠΛΗ 111', 'office_hours'),
	
	
	 ('17', '19', '2', 'OFF1', '23', 'ΗΡΥ 201', 'office_hours'),
	 ('17', '19', '2', 'OFF2', '1', 'ΠΛΗ 211', 'office_hours'),
	 ('14', '16', '5', 'OFF3', '1', 'ΗΡΥ 202', 'office_hours'),
	 ('17', '19', '6', 'OFF3', '9', 'ΗΡΥ 202', 'office_hours'),
 	 ('15', '16', '4', 'OFF1', '3', 'ΤΗΛ 201', 'office_hours'),
	 ('12', '14', '3', 'OFF2', '15', 'ΠΛΗ 211', 'office_hours'),

	
	 
	 ('17', '19', '2', 'OFF1', '10', 'ΗΡΥ 203', 'office_hours'),
	 ('17', '19', '2', 'OFF2', '18', 'ΠΛΗ 202', 'office_hours'),
	 ('14', '16', '5', 'OFF3', '18', 'ΠΛΗ 202', 'office_hours'),
	 ('17', '19', '6', 'OFF3', '4', 'ΑΓΓ 202', 'office_hours'),
 	 ('15', '16', '4', 'OFF1', '8', 'ΤΗΛ 211', 'office_hours'),
	 ('12', '14', '3', 'OFF2', '10', 'ΗΡΥ 203', 'office_hours');
END
$$
LANGUAGE 'plpgsql';


DO
$$
BEGIN
INSERT INTO "Participates"(part_amka, part_start_time, part_end_time, part_weekday, part_room_id, part_serial_number, part_course_code, role_t)
		SELECT  (SELECT per_amka FROM "Person" OFFSET floor(random()*245) LIMIT 1) as part_amka,
		la_start_time as part_start_time, la_end_time as part_end_time, la_weekday as part_weekday, la_room_id as part_room_id, la_serial_number as part_serial_number,
		la_course_code as part_course_code, (CASE person_t
		WHEN 'Student' THEN
			'participant'::role_type
		ELSE
			'responsible'::role_type
		END) as role_t
		FROM "Person" , "LearningActivity";
END
$$;