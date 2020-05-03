# COMP3161-project
Database Management Systems Project


Resources:
https://docs.google.com/document/d/1XY0dCpslwIXsy2bmOJK7sGCPvNYR_ydtBJldjShRtj4/edit
https://docs.google.com/spreadsheets/d/1N94ED5gG5LdYAj41BconbZmaj1tyunoEQmFiIP-QTO0/edit#gid=446044520
https://treyhunner.com/2013/02/random-name-generator/
https://www.youtube.com/watch?v=s1XiCh-mGCA
https://tableplus.com/blog/2018/08/mysql-how-to-import-data-from-a-csv-file.html
https://www.programiz.com/python-programming/methods/built-in/enumerate
https://www.tutorialspoint.com/mysql-trigger-to-insert-row-into-another-table
https://dba.stackexchange.com/questions/80843/returning-true-or-false-in-a-custom-function


#############DEPRECATED MAIN FUNCTION################
"""def main(mydb, lst):
    print("starting")

    mycursor = mydb.cursor()

    db_lst = []
    fname_lst, lname_lst = [], []

    print("generating names...")

    for full_name in list(map(lambda x: x.split(" ") , lst)): #splits the fullname into a list of first and last names
        fname_lst+= [full_name[0]]
        lname_lst+= [full_name[1]]

    print(len(fname_lst), " first and ", len(lname_lst), " last names generated")

    rec_num = 0

    print("inserting names into database...")

    for lname in lname_lst: #assigns each last name with all first names generated
        for fname in fname_lst:
            #db_lst+= [fname + " " + lname]
            fullName = fname + " " + lname
            sql = "INSERT INTO users (fullname) VALUES (%s)"
            val = (fullName)
            mycursor.execute(sql, (val,))
            rec_num+=1
        
    print(rec_num, "fullnames created")

    mycursor.execute("SELECT * FROM `users`")
    mycursor.fetchall()
    print(mycursor.rowcount, "record inserted.")

    mydb.commit()
    mycursor.close()
    mydb.close()
    print("done")

mydb = connect_database("cargill_db", "password", "facelook")
lst = generate_fullnames(708)
main(mydb, lst)"""