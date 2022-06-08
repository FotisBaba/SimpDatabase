CREATE OR REPLACE FUNCTION insert_grades(year integer, season semester_season_type) 
RETURNS TABLE(ramka integer, rserial_number character, rcourse_code character, rexam_grade numeric, rfinal_grade numeric, rlab_grade numeric, rregister_status register_status_type)
AS $$
DECLARE
st record;
BEGIN
	FOR st IN (SELECT * FROM "Register" r
				WHERE course_code IN (SELECT course_code FROM "Course" WHERE typical_season=season AND typical_year=year) AND register_status='approved')
	LOOP
		IF st.exam_grade IS NOT NULL THEN
			rexam_grade:=(SELECT st.exam_grade FROM st WHERE st.amka=r.amka AND st.course_code=r.course_code);
		ELSE
			rexam_grade:=(SELECT * FROM random_between(1,10));
		END IF;
		
		IF st.lab_grade IS NOT NULL AND st.lab_grade >=5 THEN
			rlab_grade:=(SELECT r.lab_grade FROM "Register" r WHERE r.amka=st.amka AND r.course_code=st.course_code);
		ELSE
			rlab_grade:=(SELECT * FROM random_between(1,10));
		END IF;
		ramka:=st.amka;
		rserial_number:=st.serial_number;
		rcourse_code:=st.course_code;
		rfinal_grade:=st.finale_grade;
		rregister_status:=st.register_status;
		RETURN NEXT;
	END LOOP;
END;
$$
LANGUAGE 'plpgsql'


CREATE OR REPLACE FUNCTION four_point_one_find_prof_labstaff() RETURNS void AS
$$
BEGIN
	SELECT DISTINCT per_name, per_surname, per_amka FROM "Person" p, "Room" r, "Participates" pa
							WHERE r.capacity>30 AND pa.role_t='responsible' AND p.per_amka=pa.part_amka;
END
$$
language 'plpgsql'


