DROP DATABASE IF EXISTS todo_db;
CREATE DATABASE  IF NOT EXISTS todo_db;
USE todo_db;


-- create student table and populate it
-- is_active: 0 == False, 1 = True
-- registration_approved: 0 == False, 1 == True, 2 == Pending
CREATE TABLE IF NOT EXISTS students(
    studentId INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(45) UNIQUE NOT NULL,
    std_password VARCHAR(45) NOT NULL,
    name_first VARCHAR(45) NOT NULL,
    name_last VARCHAR(45) NOT NULL,
    is_active BOOL,
    registration_approved ENUM('approved', 'rejected', 'pending'),
    PRIMARY KEY (studentId)
);

INSERT INTO `students` VALUES (NULL, 's1', '12345', 'amy', 'wang', 1, 'approved'),
                              (NULL, 's2', '67890', 'star', 'warehouse', 0, 'pending'),
                              (NULL, 's3', '20486', 'sam', 'will', 0, 'approved'),
                              (NULL, 's4', '29476', 'like', 'trees', 1, 'approved');


-- create teachers table and populate it
CREATE TABLE IF NOT EXISTS teachers(
    teacherId INT NOT NULL AUTO_INCREMENT,
	username VARCHAR(45) UNIQUE NOT NULL,
    tea_password VARCHAR(45) NOT NULL,
    name_first VARCHAR(45) NOT NULL,
    name_last VARCHAR(45) NOT NULL,
    PRIMARY KEY (teacherId)
);

INSERT INTO `teachers` VALUES (NULL, 'teacher1', '12345', 'pluto', 'planet'),
                              (NULL, 'teacher2', '78901', 'sun', 'star'),
                              (NULL, 'teacher3', '39583', 'earth', 'planet');


-- create classes table and populate it
CREATE TABLE IF NOT EXISTS classes(
    classId INT NOT NULL AUTO_INCREMENT,
    teacherId INT NOT NULL,
    title VARCHAR(45) NOT NULL,
    PRIMARY KEY (classId, teacherId)
);

INSERT INTO `classes` VALUES (NULL, 1, 'physics'),
                             (NULL, 1, 'biology'),
                             (NULL, 3, 'math');



-- create tasks table and populate it
-- tasks can be created, viewed, updated and deleted by teacher 
-- teaching the class for the module
-- tasks cannot be read by students
CREATE TABLE IF NOT EXISTS tasks(
    taskId INT NOT NULL AUTO_INCREMENT,
    classId INT NOT NULL,
    descrip VARCHAR(45) NOT NULL,
    PRIMARY KEY (taskId),
    CONSTRAINT of_class
        FOREIGN KEY (classId)
        REFERENCES classes (classId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO `tasks` VALUES (NULL, 1, 'falling apple'),
                           (NULL, 1, 'black hole'),
                           (NULL, 1, 'quantum'),
                           (NULL, 1, 'cat'),
                           (NULL, 2, 'marine life');


-- create student_classes table and populate it?
-- student can register for classes, but the registration needs to be
-- approved by the teacher teaching the class
-- approved: 0 == False, 1 == True, 2 == Pending
-- teacher can delete disapproved registrations
CREATE TABLE IF NOT EXISTS class_students(
    classId INT NOT NULL,
    studentId INT NOT NULL,
    PRIMARY KEY (studentId, classId),
    CONSTRAINT class_exists
        FOREIGN KEY (classId)
        REFERENCES classes (classId)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT student_exists
        FOREIGN KEY (studentId)
        REFERENCES students (studentId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO `class_students` VALUES (1, 1),
									(2, 1),
                                    (3, 1),
                                    (2, 3),
                                    (1, 4);


-- create student_tasks table and populate it?
-- student can update the task to be finished
-- finished: 0 == False, 1 == True
-- can be viewed by teachers
CREATE TABLE IF NOT EXISTS student_tasks(
    studentId INT NOT NULL,
    taskId INT NOT NULL,
    finished BOOL,
    PRIMARY KEY (studentId, taskId),
    CONSTRAINT is_student
        FOREIGN KEY (studentId)
        REFERENCES students (studentId)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT is_task
        FOREIGN KEY (taskId)
        REFERENCES tasks (taskId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO `student_tasks` VALUES (1, 1, 1),
                                   (1, 2, 0),
                                   (1, 3, 0);


