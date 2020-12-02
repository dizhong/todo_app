USE todo_db;

-- function for calculating total number of students in a class
DROP FUNCTION IF EXISTS students_in_class;
DELIMITER //
CREATE FUNCTION students_in_class(class_num VARCHAR(45))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    
    RETURN count;
END //
DELIMITER ;

SELECT students_in_class('shire') as num_of_students1;


-- function for calculating total number of tasks (finished/unfinished)


-- stored procedures are labled with one of the letters from CRUD
-- to indicate which kind of action it is

-- R: for student to view total number of finished tasks,
-- unfinished tasks, registered classes, register-pending
-- classes (my status?)


-- R: create procedure? so that students can view unfinished tasks
-- along with description, module, class
DROP PROCEDURE IF EXISTS track_unfinished_tasks;
DELIMITER //
CREATE PROCEDURE track_unfinished_tasks(chosen_id INT)
BEGIN
    SELECT tmc.taskId, descrip, title, finished, st.studentId
    FROM student_tasks as st 
         JOIN (SELECT t.taskId, t.descrip, mc.subtitle, mc.title FROM tasks t JOIN 
			      (SELECT m.subtitle, c.title, m.moduleId FROM modules m JOIN 
                       classes c ON m.classId = c.classId) as mc
                  ON t.moduleId = mc.moduleId) as tmc
         ON st.taskId = tmc.taskId
    WHERE (st.studentId = chosen_id) and finished = 0;
END //
DELIMITER ;

CALL track_unfinished_tasks(1);

-- R: create procedure? so that students can view finished tasks
-- along with description, module, class
DROP PROCEDURE IF EXISTS track_finished_tasks;
DELIMITER //
CREATE PROCEDURE track_finished_tasks(chosen_id INT)
BEGIN
    SELECT tmc.taskId, descrip, title, finished, st.studentId
    FROM student_tasks as st 
         JOIN (SELECT t.taskId, t.descrip, mc.subtitle, mc.title FROM tasks t JOIN 
			      (SELECT m.subtitle, c.title, m.moduleId FROM modules m JOIN 
                       classes c ON m.classId = c.classId) as mc
                  ON t.moduleId = mc.moduleId) as tmc
         ON st.taskId = tmc.taskId
    WHERE (st.studentId = chosen_id) and finished = 1;
END //
DELIMITER ;

CALL track_finished_tasks(1);

-- R: create procedure? so that students can view all tasks
-- along with description, module, class
DROP PROCEDURE IF EXISTS track_all_tasks;
DELIMITER //
CREATE PROCEDURE track_all_tasks(chosen_id INT)
BEGIN
    SELECT tmc.taskId, descrip, title, finished, st.studentId
    FROM student_tasks as st 
         JOIN (SELECT t.taskId, t.descrip, mc.subtitle, mc.title FROM tasks t JOIN 
			      (SELECT m.subtitle, c.title, m.moduleId FROM modules m JOIN 
                       classes c ON m.classId = c.classId) as mc
                  ON t.moduleId = mc.moduleId) as tmc
         ON st.taskId = tmc.taskId
    WHERE (st.studentId = chosen_id);
END //
DELIMITER ;

CALL track_all_tasks(1);

-- R: for student to view list of their approved classes and the 
-- class's associated teachers
DROP PROCEDURE IF EXISTS track_approved_classes;
DELIMITER //
CREATE PROCEDURE track_approved_classes(chosenId INT)
BEGIN
    SELECT classId, title, cstc.approved, cstc.name_first, cstc.name_last
    FROM students s JOIN
        (SELECT cs.studentId, cs.classId, cs.approved, tc.title, tc.name_first, tc.name_last FROM class_students cs JOIN
            (SELECT c.classId, c.title, t.name_first, t.name_last FROM classes c JOIN teachers t
            ON c.teacherId = t.teacherId) AS tc
		ON cs.classId = tc.classId) as cstc
	ON s.studentId = cstc.studentId
	WHERE s.studentId = chosenId and approved = 1;
END //
DELIMITER ;

CALL track_approved_classes(1);

-- R: for student to view list of their all classes and the class's
-- associated teachers
DROP PROCEDURE IF EXISTS track_all_classes;
DELIMITER //
CREATE PROCEDURE track_all_classes(chosenId INT)
BEGIN
    SELECT classId, title, cstc.approved, cstc.name_first, cstc.name_last
    FROM students s JOIN
        (SELECT cs.studentId, cs.classId, cs.approved, tc.title, tc.name_first, tc.name_last FROM class_students cs JOIN
            (SELECT c.classId, c.title, t.name_first, t.name_last FROM classes c JOIN teachers t
            ON c.teacherId = t.teacherId) AS tc
		ON cs.classId = tc.classId) as cstc
	ON s.studentId = cstc.studentId
	WHERE s.studentId = chosenId;
END //
DELIMITER ;

CALL track_all_classes(1);

-- R: for student to view all available classes and number
-- of students registered for each class


-- U: for student to register for classes


-- C: for student to register, aka create new student entry


-- U: for teacher to update tasks


-- C: for teacher to create tasks


-- D: for teacher to delete tasks


-- R: for teacher to view tasks


-- U: for teacher to approve student class registration
-- this also triggers an update of student-task table



-- U: for teacher to approve student account registration


-- D: for teacher to delete student whose registration were not approved

