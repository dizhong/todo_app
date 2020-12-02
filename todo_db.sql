DROP DATABASE IF EXISTS todo_db;
CREATE DATABASE  IF NOT EXISTS todo_db;
USE todo_db;


-- create student table and populate it
-- is_active: 0 == False, 1 = True
-- registration_approved: 0 == False, 1 == True, 2 == Pending
CREATE TABLE IF NOT EXISTS students(
    studentId INT NOT NULL AUTO_INCREMENT,
    std_password VARCHAR(45) NOT NULL,
    name_first VARCHAR(45) NOT NULL,
    name_last VARCHAR(45) NOT NULL,
    is_active BOOL,
    registration_approved ENUM('approved', 'rejected', 'pending'),
    PRIMARY KEY (studentId)
);

INSERT INTO `students` VALUES (NULL, '12345', 'amy', 'wang', 1, 'approved'),
                              (NULL, '67890', 'star', 'warehouse', 0, 'pending'),
                              (NULL, '20486', 'true', 'isit', 0, 'approved'),
                              (NULL, '29476', 'like', 'trees', 1, 'approved');


-- create teachers table and populate it
CREATE TABLE IF NOT EXISTS teachers(
    teacherId INT NOT NULL AUTO_INCREMENT,
    tea_password VARCHAR(45) NOT NULL,
    name_first VARCHAR(45) NOT NULL,
    name_last VARCHAR(45) NOT NULL,
    PRIMARY KEY (teacherId)
);

INSERT INTO `teachers` VALUES (NULL, '12345', 'pluto', 'death'),
                              (NULL, '78901', 'strike', 'blow'),
                              (NULL, '39583', 'pierce', 'through');


-- create classes table and populate it
CREATE TABLE IF NOT EXISTS classes(
    classId INT NOT NULL AUTO_INCREMENT,
    teacherId INT NOT NULL,
    title VARCHAR(45) NOT NULL,
    PRIMARY KEY (classId, teacherId)
);

INSERT INTO `classes` VALUES (NULL, 1, 'and what is the wonder'),
                             (NULL, 1, 'i tell you the breeze'),
                             (NULL, 3, 'SLAM');


-- create modules table and populate it
-- modules can be cruded by teacher
-- modules can be read by student
CREATE TABLE IF NOT EXISTS modules(
    moduleId INT NOT NULL AUTO_INCREMENT,
    classId INT NOT NULL,
    subtitle VARCHAR(45) NOT NULL,
    PRIMARY KEY (moduleId),
    CONSTRAINT of_class
        FOREIGN KEY (classId)
        REFERENCES classes (classId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO `modules` VALUES (NULL, 1, '1 beginning of the end'),
                             (NULL, 1, '2 it all goes down from here'),
                             (NULL, 2, '1 welcome to hell');


-- create tasks table and populate it
-- tasks can be created, viewed, updated and deleted by teacher 
-- teaching the class for the module
-- tasks cannot be read by students
CREATE TABLE IF NOT EXISTS tasks(
    taskId INT NOT NULL AUTO_INCREMENT,
    moduleId INT NOT NULL,
    descrip VARCHAR(45) NOT NULL,
    PRIMARY KEY (taskId),
    CONSTRAINT of_module
        FOREIGN KEY (moduleId)
        REFERENCES modules (moduleId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO `tasks` VALUES (NULL, 1, 'write about your feelings'),
                           (NULL, 1, 'burn it with fire'),
                           (NULL, 1, 'along with whats left of your hair'),
                           (NULL, 1, 'it will never grow back'),
                           (NULL, 2, 'now cry');


-- create student_classes table and populate it?
-- student can register for classes, but the registration needs to be
-- approved by the teacher teaching the class
-- approved: 0 == False, 1 == True, 2 == Pending
-- teacher can delete disapproved registrations
CREATE TABLE IF NOT EXISTS class_students(
    classId INT NOT NULL,
    studentId INT NOT NULL,
    approved ENUM('approved', 'rejected', 'pending'),
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

INSERT INTO `class_students` VALUES (1, 1, 'approved'),
									(2, 1, 'pending'),
                                    (3, 1, 'approved'),
                                    (1, 2, 'pending'),
                                    (2, 3, 'rejected'),
                                    (1, 4, 'pending');


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


