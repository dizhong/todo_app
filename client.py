#!/usr/bin/env python3
# -*- coding: utf-8 -*-


# %% Simple selector (MySQL database)
# import pymysql for a simple interface to a MySQL DB

import pymysql
import getpass, os

def input_one_of(message, options):
    print("Please enter %s (one of %s)" % (message, options))
    answer = input()
    while (answer not in options):
        print("wrong input")
        print("Please enter %s (one of %s)" % (message, options))
        answer = input()
    return answer


def input_varchar_45(message):
    print("Please enter %s (between 1 and 45 characters)" % message)
    answer = input()
    while (len(answer) > 45 or len(answer) < 1):
        print("wrong input")
        print("Please enter %s (between 1 and 45 characters)" % message)
        answer = input()
    return answer


def login_credentials():
    login_type = input_one_of("login type", ['teacher', 'student', 'register_student'])
    
    username_input = input_varchar_45("username")
    password_input = input_varchar_45("password")

    return login_type, username_input, password_input


def call_proc(proc_name, cnx, args=[]):
    cursor = cnx.cursor()
    cursor.callproc(proc_name, args)
    res = cursor.fetchall()
    cursor.close()
    return res

def call_proc_and_print(proc_name, cnx, args=[]):
    r = call_proc(proc_name, cnx, args)
    for row in r:
        print(row)

def main():
    try:
        print("Please enter database username: ")
        username_input = input()
        #print("Please enter database password: ")
        #password_input = input()
        password_input = getpass.getpass("Please enter database password (hidden): \n", stream = None)

        cnx = pymysql.connect(host='localhost', user=username_input,
                              password=password_input,
                              db="todo_db", charset='utf8mb4',
                              cursorclass=pymysql.cursors.DictCursor)

    except pymysql.err.OperationalError as err:
        print('Error: %d: %s' % (err.args[0], err.args[1]))

    try:
        cursor = cnx.cursor()
        # login / register
        login_type = None
        status = None
        username = None
        logged_in_id = False
        while not logged_in_id:
            login_type, username, password = login_credentials()

            if login_type == 'teacher':
                users = call_proc('all_teacher_usernames', cnx)
                if {'username': username} in users:
                    res = call_proc('teacher_id_and_password', cnx, [username])
                    db_password = res[0]['tea_password']
                    user_id = res[0]['teacherId']
                    if db_password == password:
                        logged_in_id = user_id

            elif login_type == 'student':
                users = call_proc('all_student_usernames', cnx)
                if {'username': username} in users:
                    res = call_proc('student_id_and_password', cnx, [username])
                    db_password = res[0]['std_password']
                    user_id = res[0]['studentId']
                    status = res[0]['registration_approved']
                    if db_password == password:
                        logged_in_id = user_id

            elif login_type == 'register_student':
                first_name = input_varchar_45("First Name")
                last_name = input_varchar_45("Last Name")
                call_proc('register_student', cnx,
                          [username, password, first_name, last_name])
                print("registered")
                
        print("Logged in as %s %s with id %s" % (login_type, username, logged_in_id))

        task = None
        while task != "logout":
            if login_type == 'student' and status != 'approved':
                print("your account status is " + status)
                print("logging you out")
                task = 'logout'
            elif login_type == 'student' and status == 'approved':
                task = input_one_of("an operation",
                  ["view status",
                   "unfinished tasks",
                   "all tasks",
                   "task has finished",
                   "my classes",
                   "register for class",
                   "logout"
                  ])
                if   task == 'view status':
                    call_proc_and_print('view_my_status', cnx, [logged_in_id])
                elif task == 'unfinished tasks':
                    call_proc_and_print('track_unfinished_tasks', cnx, [logged_in_id])
                elif task == 'all tasks':
                    call_proc_and_print('track_all_tasks', cnx, [logged_in_id])
                elif task == 'task has finished':
                    unfinished_tasks = call_proc('track_unfinished_tasks', cnx, [logged_in_id])
                    str_task_list = [str(row['taskId']) for row in unfinished_tasks]
                    chosen_task = int(input_one_of("id of finished task", str_task_list))
                    call_proc("update_task", cnx, [chosen_task, logged_in_id])
                elif task == 'my classes':
                    call_proc_and_print('track_all_classes', cnx, [logged_in_id])
                elif task == 'register for class':
                    print("All available classes:")
                    call_proc_and_print('view_available_classes', cnx, [])
                    classes = call_proc('view_available_classes', cnx, [])
                    str_id_list = [str(row['classId']) for row in classes]
                    chosen_id = int(input_one_of("class id", str_id_list))
                    student_classes = call_proc('track_all_classes', cnx, [logged_in_id])
                    registered_class_ids = [row['classId'] for row in student_classes]
                    if chosen_id in registered_class_ids:
                        print("already registered")
                    else:
                        call_proc('register_class', cnx, [logged_in_id, chosen_id])
                        print("successfully registered")
                    

            elif login_type == 'teacher':
                task = input_one_of("an operation",
                  ["create a task",
                   "delete a task",
                   "view tasks",
                   "update student registration",
                   "delete rejected students",
                   "logout"
                  ])
                if   task == 'create a task':
                    classes = call_proc('view_available_classes', cnx, [])
                    str_id_list = [str(row['classId']) for row in classes]
                    chosen_id = int(input_one_of("class id", str_id_list))
                    descript = input_varchar_45("task description")
                    call_proc('create_task', cnx, [chosen_id, descript])
                    print("task created")
                elif task == 'delete a task':
                    tasks = call_proc("view_tasks", cnx, [])
                    str_task_list = [str(row['taskId']) for row in tasks]
                    chosen_task = int(input_one_of("task id", str_task_list))
                    call_proc("delete_task", cnx, [chosen_task])
                    print("task " + chosen_task + "deleted")
                elif task == 'view tasks':
                    call_proc_and_print('view_tasks', cnx, [])
                elif task == 'update student registration':
                    call_proc_and_print("all_students", cnx, [])
                    students = call_proc("all_students", cnx, [])
                    str_id_list = [str(row['studentId']) for row in students]
                    chosen_student = int(input_one_of("student id", str_id_list))
                    approval = input_one_of("approval decision", ["approved", "pending", "rejected"])
                    call_proc("update_student_registration", cnx, [chosen_student, approval])
                elif task == 'delete rejected students':
                    call_proc("delete_rejected_students", cnx, [])


    except pymysql.Error as err:
        print('Error: %d: %s' % (err.args[0], err.args[1]))
    finally:
        cnx.commit()
        cnx.close()




if __name__ == "__main__":
    main()
