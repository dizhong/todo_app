#!/usr/bin/env python
# -*- coding: utf-8 -*-


# %% Simple selector (MySQL database)
# import pymysql for a simple interface to a MySQL DB

import pymysql


try:
    print("Please enter username (hint for myself: root): ")
    username_input = input()
    print("Please enter password: ")
    password_input = input()
    print("Please enter database name (hint for myself: lotrfinal_1): ")
    database_input = input()

    cnx = pymysql.connect(host='localhost', user=username_input,
                          password=password_input,
                      db=database_input, charset='utf8mb4',
                          cursorclass=pymysql.cursors.DictCursor)

except pymysql.err.OperationalError as err:
    print('Error: %d: %s' % (err.args[0], err.args[1]))