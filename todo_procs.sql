USE todo_db;

-- function for calculating total number of students in a class
DROP FUNCTION IF EXISTS students_in_class;
DELIMITER //
CREATE FUNCTION students_in_class(class_num int)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT count(*) INTO count FROM class_students WHERE classId = class_num; 
    RETURN count;
END //
DELIMITER ;

-- SELECT students_in_class(1) as num_of_students1;


-- function for calculating total number of unfinished/finished tasks
DROP FUNCTION IF EXISTS unfinished_tasks_num;
DELIMITER //
CREATE FUNCTION unfinished_tasks_num(student_num int)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT count(*) INTO count FROM student_tasks WHERE studentId = student_num AND finished = 0; 
    RETURN count;
END //
DELIMITER ;

-- SELECT unfinished_tasks_num(1) as num_of_tasks_unfinished;


DROP FUNCTION IF EXISTS finished_tasks_num;
DELIMITER //
CREATE FUNCTION finished_tasks_num(student_num int)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT count(*) INTO count FROM student_tasks WHERE studentId = student_num AND finished = 1; 
    RETURN count;
END //
DELIMITER ;

-- SELECT finished_tasks_num(1) as num_of_tasks_finished;

-- function for calculating number of registerd
DROP FUNCTION IF EXISTS registered_classes_num;
DELIMITER //
CREATE FUNCTION registered_classes_num(student_num int)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT count(*) INTO count FROM class_students WHERE studentId = student_num; 
    RETURN count;
END //
DELIMITER ;

-- SELECT registered_classes_num(1) as num_of_classes_registered;



-- stored procedures are labled with one of the letters from CRUD
-- to indicate which kind of action it is

-- R: for student to view total number of finished tasks,
-- unfinished tasks, 
-- registered classes, register-pending
-- classes (my status?)
DROP PROCEDURE IF EXISTS view_my_status;
DELIMITER //
CREATE PROCEDURE view_my_status(my_id INT)
BEGIN
select unfinished_tasks_num(my_id) as unfinished_tasks, 
       finished_tasks_num(my_id) as finished_tasks, 
       registered_classes_num(my_id) as registered_classes;
END //
DELIMITER ;

-- CALL view_my_status(1);

-- R: create procedure? so that students can view unfinished tasks
-- along with description, module, class
DROP PROCEDURE IF EXISTS track_unfinished_tasks;
DELIMITER //
CREATE PROCEDURE track_unfinished_tasks(chosen_id INT)
BEGIN
    SELECT mc.taskId, descrip, title, finished, st.studentId
    FROM student_tasks as st 
         JOIN (SELECT t.taskId, t.descrip, c.title FROM tasks t JOIN 
                       classes c ON t.classId = c.classId) as mc
         ON st.taskId = mc.taskId
    WHERE (st.studentId = chosen_id) and finished = 0;
END //
DELIMITER ;

-- CALL track_unfinished_tasks(1);

-- R: create procedure? so that students can view finished tasks
-- along with description, module, class
DROP PROCEDURE IF EXISTS track_finished_tasks;
DELIMITER //
CREATE PROCEDURE track_finished_tasks(chosen_id INT)
BEGIN
    SELECT mc.taskId, descrip, title, finished, st.studentId
    FROM student_tasks as st 
         JOIN (SELECT t.taskId, t.descrip, c.title FROM tasks t JOIN 
                       classes c ON t.classId = c.classId) as mc
         ON st.taskId = mc.taskId
    WHERE (st.studentId = chosen_id) and finished = 1;
END //
DELIMITER ;

-- CALL track_finished_tasks(1);

-- R: create procedure? so that students can view all tasks
-- along with description, module, class
DROP PROCEDURE IF EXISTS track_all_tasks;
DELIMITER //
CREATE PROCEDURE track_all_tasks(chosen_id INT)
BEGIN
    SELECT mc.taskId, descrip, title, finished, st.studentId
    FROM student_tasks as st 
         JOIN (SELECT t.taskId, t.descrip, c.title FROM tasks t JOIN 
                       classes c ON t.classId = c.classId) as mc
         ON st.taskId = mc.taskId
    WHERE (st.studentId = chosen_id);
END //
DELIMITER ;

-- CALL track_all_tasks(1);


-- R: for student to view list of their all classes and the class's
-- associated teachers
DROP PROCEDURE IF EXISTS track_all_classes;
DELIMITER //
CREATE PROCEDURE track_all_classes(chosenId INT)
BEGIN
    SELECT classId, title, cstc.teacher_name_first, cstc.teacher_name_last
    FROM students s JOIN
        (SELECT cs.studentId, cs.classId, tc.title, tc.teacher_name_first, tc.teacher_name_last FROM class_students cs JOIN
            (SELECT c.classId, c.title, t.teacher_name_first, t.teacher_name_last FROM classes c JOIN teachers t
            ON c.teacherId = t.teacherId) AS tc
		ON cs.classId = tc.classId) as cstc
	ON s.studentId = cstc.studentId
	WHERE s.studentId = chosenId;
END //
DELIMITER ;

-- CALL track_all_classes(1);

-- R: for student to view all available classes and number
-- of students registered for each class
DROP PROCEDURE IF EXISTS view_available_classes;
DELIMITER //
CREATE PROCEDURE view_available_classes()
BEGIN
    SELECT c.classId, title, b.num_student
    FROM classes c JOIN
        (SELECT classId, COUNT(*) as num_student FROM class_students GROUP BY classId) as b
	ON c.classId = b.classId;
END //
DELIMITER ;

-- CALL view_available_classes();

-- C: for student to register for classes
DROP PROCEDURE IF EXISTS register_class;
DELIMITER //
CREATE PROCEDURE register_class(student_id INT, class_id INT)
BEGIN
    INSERT INTO class_students VALUES (class_id, student_id);
END //
DELIMITER ;

DROP TRIGGER IF EXISTS student_task_after_register;
DELIMITER //
CREATE TRIGGER student_task_after_register
AFTER INSERT ON class_students FOR EACH ROW
BEGIN
    DECLARE studentId INT;
    DECLARE classId INT;
    DECLARE taskId INT;
    SET studentId = NEW.studentId;
    SET classId = NEW.classId;
    INSERT INTO student_tasks VALUES (SELECT studentId, taskId
                                      FROM studentId JOIN tasks t
                                      WHERE t.classId = classId;
END //
DELIMITER ;

-- SELECT * FROM class_students as classes_for_student1 where studentId = 3;
-- CALL register_class(3, 1);
-- SELECT * FROM class_students as classes_for_student1 where studentId = 3;

-- C: for student to register, aka create new student entry
DROP PROCEDURE IF EXISTS register_student;
DELIMITER //
CREATE PROCEDURE register_student(username VARCHAR(45), std_password VARCHAR(45), name_first VARCHAR(45), name_last VARCHAR(45))
BEGIN
    INSERT INTO students VALUES (NULL, username, std_password, name_first, name_last, 1, 'pending');
END //
DELIMITER ;

-- SELECT * FROM students;
-- CALL register_student('s16', 'foo', 'one', 'two');
-- SELECT * FROM students;

-- U: for student to update their todo task to be finished
DROP PROCEDURE IF EXISTS update_task;
DELIMITER //
CREATE PROCEDURE update_task(finished_task INT, student INT)
BEGIN
    UPDATE student_tasks
    SET finished = 1
    WHERE studentId = student and taskId = finished_Task;
END //
DELIMITER ;

-- C: for teacher to create a task
DROP PROCEDURE IF EXISTS create_task;
DELIMITER //
CREATE PROCEDURE create_task(classId int, descript VARCHAR(45))
BEGIN
    INSERT INTO tasks VALUES (NULL, classId, descript);
END //
DELIMITER ;

-- SELECT * FROM tasks;
-- CALL create_task(1, "sample insert");
-- SELECT * FROM tasks;

-- D: for teacher to delete tasks
DROP PROCEDURE IF EXISTS delete_task;
DELIMITER //
CREATE PROCEDURE delete_task(id INT)
BEGIN
    DELETE FROM tasks WHERE taskId = id;
END //
DELIMITER ;

-- SELECT * FROM tasks;
-- CALL delete_task(6);
-- SELECT * FROM tasks;

-- R: for teacher to view tasks
DROP PROCEDURE IF EXISTS view_tasks;
DELIMITER //
CREATE PROCEDURE view_tasks()
BEGIN
    SELECT * FROM tasks;
END //
DELIMITER ;

-- CALL view_tasks();


-- U: for teacher to approve student account registration
DROP PROCEDURE IF EXISTS update_student_registration;
DELIMITER //
CREATE PROCEDURE update_student_registration(student INT, approval VARCHAR(45))
BEGIN
    UPDATE students
    SET registration_approved = approval
    WHERE studentId = student;
END //
DELIMITER ;

-- CALL update_student_registration(2, "approved");
-- CALL update_student_registration(2, "pending");

-- D: for teacher to delete students whose registration were not approved
DROP PROCEDURE IF EXISTS delete_rejected_students;
DELIMITER //
CREATE PROCEDURE delete_rejected_students()
BEGIN
    DELETE FROM students WHERE registration_approved = "rejected";
END //
DELIMITER ;

-- SELECT * FROM students;
-- CALL delete_rejected_students();
-- SELECT * FROM students;

DROP PROCEDURE IF EXISTS all_teacher_usernames;
DELIMITER //
CREATE PROCEDURE all_teacher_usernames()
BEGIN
	SELECT username from teachers;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS all_student_usernames;
DELIMITER //
CREATE PROCEDURE all_student_usernames()
BEGIN
	SELECT username from students;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS all_students;
DELIMITER //
CREATE PROCEDURE all_students()
BEGIN
	SELECT * from students;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS student_id_and_password;
DELIMITER //
CREATE PROCEDURE student_id_and_password(username VARCHAR(45))
BEGIN
	SELECT studentId, std_password, registration_approved from students as s where s.username = username;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS teacher_id_and_password;
DELIMITER //
CREATE PROCEDURE teacher_id_and_password(username VARCHAR(45))
BEGIN
	SELECT teacherId, tea_password from teachers as t where t.username = username;
END //
DELIMITER ;
