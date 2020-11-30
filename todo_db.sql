DROP DATABASE IF EXISTS todo_db;
CREATE DATABASE  IF NOT EXISTS todo_db;
USE todo_db;


-- create student table and populate it
-- is_active: 0 == False, 1 = True
-- registration_approved: 0 == False, 1 == True, 2 == Pending
CREATE TABLE IF NOT EXISTS students(
    studentId INT NOT NULL,
    std_password VARCHAR(45) NOT NULL,
    name_first VARCHAR(45) NOT NULL,
    name_last VARCHAR(45) NOT NULL,
    is_active INT NOT NULL,
    registration_approved INT NOT NULL,
    PRIMARY KEY (studentId)
);

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (1, '12345', 'amy', 'wang', 1, 1),
                              (2, '67890', 'star', 'warehouse', 0, 2),
                              (3, '20486', 'true', 'isit', 0, 1),
                              (4, '29476', 'like', 'trees', 1, 1);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

-- create teachers table and populate it
CREATE TABLE IF NOT EXISTS teachers(
    teacherId INT NOT NULL,
    tea_password VARCHAR(45) NOT NULL,
    name_first VARCHAR(45) NOT NULL,
    name_last VARCHAR(45) NOT NULL,
    PRIMARY KEY (teacherId)
);

LOCK TABLES `teachers` WRITE;
INSERT INTO `teachers` VALUES (1, '12345', 'pluto', 'death'),
                              (2, '78901', 'strike', 'blow'),
                              (3, '39583', 'pierce', 'through');
UNLOCK TABLES;

-- create classes table and populate it
CREATE TABLE IF NOT EXISTS classes(
    classId INT NOT NULL,
    teacherId INT NOT NULL,
    title VARCHAR(45) NOT NULL,
    PRIMARY KEY (classId, teacherId)
);

LOCK TABLES `classes` WRITE;
INSERT INTO `classes` VALUES (1, 1, 'and what is the wonder'),
                             (2, 1, 'i tell you the breeze'),
                             (3, 3, 'SLAM');
UNLOCK TABLES;

-- create modules table and populate it
-- modules can be cruded by teacher
-- modules can be read by student
CREATE TABLE IF NOT EXISTS modules(
    moduleId INT NOT NULL,
    classId INT NOT NULL,
    subtitle VARCHAR(45) NOT NULL,
    PRIMARY KEY (moduleId),
    CONSTRAINT of_class
        FOREIGN KEY (classId)
        REFERENCES classes (classId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

LOCK TABLES `modules` WRITE;
INSERT INTO `modules` VALUES (1, 1, '1 beginning of the end'),
                             (2, 1, '2 it all goes down from here'),
                             (3, 2, '1 welcome to hell');
UNLOCK TABLES;

-- create tasks table and populate it
-- tasks can be created, viewed, updated and deleted by teacher 
-- teaching the class for the module
-- tasks cannot be read by students
CREATE TABLE IF NOT EXISTS tasks(
    taskId INT NOT NULL,
    moduleId INT NOT NULL,
    descrip VARCHAR(45) NOT NULL,
    PRIMARY KEY (taskId),
    CONSTRAINT of_module
        FOREIGN KEY (moduleId)
        REFERENCES modules (moduleId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

LOCK TABLES `tasks` WRITE;
INSERT INTO `tasks` VALUES (1, 1, 'write about your feelings'),
                           (2, 1, 'burn it with fire'),
                           (3, 1, 'along with whats left of your hair'),
                           (4, 1, 'it will never grow back'),
                           (5, 2, 'now cry');
UNLOCK TABLES;

-- create student_classes table and populate it?
-- student can register for classes, but the registration needs to be
-- approved by the teacher teaching the class
-- approved: 0 == False, 1 == True, 2 == Pending
-- teacher can delete disapproved registrations
CREATE TABLE IF NOT EXISTS class_students(
    classId INT NOT NULL,
    studentId INT NOT NULL,
    approved INT NOT NULL,
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

LOCK TABLES `class_students` WRITE;
INSERT INTO `class_students` VALUES (1, 1, 1),
									(2, 1, 2),
                                    (3, 1, 1),
                                    (1, 2, 2),
                                    (2, 3, 0),
                                    (1, 4, 2);
UNLOCK TABLES;

-- create student_tasks table and populate it?
-- student can update the task to be finished
-- finished: 0 == False, 1 == True
-- can be viewed by teachers
CREATE TABLE IF NOT EXISTS student_tasks(
    studentId INT NOT NULL,
    taskId INT NOT NULL,
    finished INT NOT NULL,
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

LOCK TABLES `student_tasks` WRITE;
INSERT INTO `student_tasks` VALUES (1, 1, 1),
                                   (1, 2, 0),
                                   (1, 3, 0);
UNLOCK TABLES;

