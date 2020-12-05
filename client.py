#!/usr/bin/env python3
# -*- coding: utf-8 -*-


# %% Simple selector (MySQL database)
# import pymysql for a simple interface to a MySQL DB

import pymysql


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


def main():
    try:
        cnx = pymysql.connect(host='localhost', user="root",
                              password="root",
                              db="todo_db", charset='utf8mb4',
                              cursorclass=pymysql.cursors.DictCursor)

    except pymysql.err.OperationalError as err:
        print('Error: %d: %s' % (err.args[0], err.args[1]))

    try:
        cursor = cnx.cursor()
        # login / register
        login_type = None
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
                    if db_password == password:
                        logged_in_id = user_id

            elif login_type == 'register_student':
                first_name = input_varchar_45("First Name")
                last_name = input_varchar_45("Last Name")
                call_proc('register_student', cnx,
                          [username, password, first_name, last_name])
                print("registered")
                
        print("Logged in as %s %s with id %s" % (login_type, username, logged_in_id))

    except pymysql.Error as err:
        print('Error: %d: %s' % (err.args[0], err.args[1]))
    finally:
        cnx.close()

    

    # operations??


if __name__ == "__main__":
    main()
