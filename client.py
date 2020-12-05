#!/usr/bin/env python
# -*- coding: utf-8 -*-


# %% Simple selector (MySQL database)
# import pymysql for a simple interface to a MySQL DB

import pymysql


def login_credentials():
    print("Please enter username: ")
    username_input = input()
    print("Please enter password: ")
    password_input = input()
    return username_input, password_input


def main():
    try:
        cnx = pymysql.connect(host='localhost', user="root",
                              password="4mnt8r3x",
                              db="todo_db", charset='utf8mb4',
                              cursorclass=pymysql.cursors.DictCursor)

    except pymysql.err.OperationalError as err:
        print('Error: %d: %s' % (err.args[0], err.args[1]))

    # login / register

    # operations??


if __name__ == "__main__":
    main()