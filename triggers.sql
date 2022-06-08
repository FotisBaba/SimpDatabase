CREATE OR REPLACE FUNCTION DateDiff (units VARCHAR(30), start_t TIME, end_t TIME) 
RETURNS INT AS
$$
DECLARE
  diff_interval INTERVAL; 
  diff INT = 0;
BEGIN
  -- Minus operator for TIME returns interval 'HH:MI:SS'  
  diff_interval = end_t - start_t;

  diff = DATE_PART('hour', diff_interval);

  IF units IN ('hh', 'hour') THEN
    RETURN diff;
  END IF;

  diff = diff * 60 + DATE_PART('minute', diff_interval);

  IF units IN ('mi', 'n', 'minute') THEN
     RETURN diff;
  END IF;

  diff = diff * 60 + DATE_PART('second', diff_interval);

  RETURN diff;
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION five_point_one() 
RETURNS TRIGGER AS 
$$
DECLARE
tmp RECORD;
max INTEGER:=0;
labmax INTEGER;
BEGIN

  labmax=(SELECT c.lab_hours FROM "Course" c
            WHERE c.course_code=NEW.course_code);

  max=(SELECT * FROM datediff('hour',NEW.start_time,NEW.end_time));
  FOR tmp IN SELECT * FROM "Participates" par
  WHERE par.amka = NEW.amka

  LOOP

    IF tmp.start_time=NEW.start_time AND tmp.end_time=NEW.end_time
    AND tmp.weekday=NEW.weekday THEN
      RAISE EXCEPTION 'Cant Insert %',NEW.amka; 
    END IF;

    IF NEW.amka IN (SELECT p.amka FROM "Person" p
              WHERE p.person_type='Student') THEN
      IF NEW.room_id IN (SELECT r.room_id FROM "Room" r
                 WHERE r.room_type='computer_room' OR
                 r.room_type='lab_room') THEN
      max=(SELECT * FROM datediff('hour',tmp.start_time,tmp.end_time))+max;
      END IF;

      IF max>=labmax THEN
        RAISE EXCEPTION 'Overload';
      END IF;
      
    END IF;

  END LOOP;

  RETURN NEW;
END;
$$


CREATE TRIGGER five_point_one_trigger
  BEFORE INSERT OR UPDATE
  ON "Participates"
  FOR EACH ROW
  EXECUTE PROCEDURE five_point_one();






CREATE OR REPLACE FUNCTION five_point_two() 
RETURNS TRIGGER AS 
$$
DECLARE
  tmp RECORD;
BEGIN

    IF NEW.weekday>6 AND NEW.weekday<0 THEN
      RAISE EXCEPTION 'Invalid day';
    END IF;

    IF datediff('hour',NEW.start_time,NEW.end_time)<0 THEN
      RAISE EXCEPTION 'Invalid times';
    END IF;

    IF NEW.start_time IS NULL OR NEW.end_time IS NULL OR NEW.weekday IS NULL THEN
            RAISE EXCEPTION 'Null inputs';
    END IF;


    
    FOR tmp IN SELECT * FROM "LearningActivity" la
    WHERE la.room_id=NEW.room_id
    LOOP

     IF tmp.weekday=NEW.weekday THEN
 
       IF datediff('hour',NEW.start_time,tmp.start_time)<=0 AND datediff('hour',NEW.start_time,tmp.end_time)>0 AND NEW.serial_number=tmp.serial_number THEN
           RAISE EXCEPTION 'Invalid operation';
       END IF;

       IF datediff('hour',NEW.end_time,tmp.end_time)<0 AND datediff('hour',NEW.start_time,tmp.start_time)>=0 AND NEW.serial_number=tmp.serial_number THEN
           RAISE EXCEPTION 'Invalid operation';
       END IF;
 
       IF datediff('hour',NEW.end_time,tmp.end_time)>=0 AND datediff('hour',NEW.end_time,tmp.start_time)<0 AND NEW.serial_number=tmp.serial_number THEN
           RAISE EXCEPTION 'Invalid operation';
       END IF;
 
 
     END IF;

    END LOOP;

    RETURN NEW;

END;
$$


CREATE TRIGGER five_point_two_trigger
  BEFORE INSERT OR UPDATE
  ON "LearningActivity"
  FOR EACH ROW
  EXECUTE PROCEDURE five_point_two();



CREATE OR REPLACE FUNCTION five_point_three() 
RETURNS TRIGGER AS 
$$
DECLARE
tmp RECORD;
BEGIN

  IF NEW.semester_status = 'future' THEN

    FOR tmp IN (SELECT * FROM "Course" co WHERE co.typical_season=NEW.academic_season)
    LOOP

        INSERT INTO "CourseRun"(course_code, serial_number, exam_min, lab_min, exam_percentage, labuses, semesterrunsin, amka_prof1, amka_prof2)
        SELECT a.course_code,NEW.semester_id,a.exam_min,a.lab_min,
        a.exam_percentage,a.labuses,NEW.semester_id,a.amka_prof1,
        a.amka_prof2 
        FROM (SELECT * FROM "CourseRun" co
              WHERE co.course_code=tmp.course_code AND
            co.serial_number IN (SELECT cou.serial_number
                       FROM "CourseRun" cou
                       WHERE cou.course_code=tmp.course_code
                       AND cou.serial_number<NEW.semester_id
                       ORDER BY cou.serial_number DESC
                       LIMIT 1)) a;
    END LOOP;

    RETURN NEW;

  END IF;


END;
$$


CREATE TRIGGER five_point_three_trigger
AFTER INSERT OR UPDATE
ON "Semester"
FOR EACH ROW
EXECUTE PROCEDURE five_point_three();



CREATE VIEW six_point_one 
AS 
 SELECT count(r.amka) AS count,
    r.course_code,
    c.typical_season
   FROM "Register" r
     JOIN "Course" c ON c.course_code = r.course_code
  WHERE r.register_status = 'pass' AND r.lab_grade >= 8
  GROUP BY c.typical_season, r.course_code;



CREATE VIEW six_point_two
AS
 SELECT par.room_id,par.weekday, par.start_time, par.end_time, per.name, per.surname, par.course_code
   FROM "Participates" par
     JOIN "Person" per ON par.amka = per.amka
     JOIN "Room" roo ON roo.room_id = par.room_id
  WHERE per.person_type = 'Professor' AND r.room_type = 'lecture_room'
  ORDER BY pa.room_id;















