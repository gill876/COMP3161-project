import mysql.connector
import names

def generate_fullnames(amount):
    """accepts amount of fullnames to be generated and outputs the fullnames in a list: ['Mary Brown', 'John Brown']"""
    group_lst = [names.get_full_name() for i in range(amount)]
    return group_lst

def connect_database(db_user, db_passwd, db_name, host_addr="localhost"):
    """accepts host address, database username, database password and database name then returns the database object"""
    mydb = None

    try:
        mydb = mysql.connector.connect(
            host=host_addr,
            user=db_user,
            passwd=db_passwd,
            database=db_name
        )
    except Exception as e:
        print(e)
    else:
        print("database connected")

    return mydb
    

print("starting")

mydb = connect_database("cargill_db", "password", "facelook")

mycursor = mydb.cursor()

db_lst = []
fname_lst, lname_lst = [], []

print("generating names...")

for full_name in list(map(lambda x: x.split(" ") , generate_fullnames(708))): #splits the fullname into a list of first and last names
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
