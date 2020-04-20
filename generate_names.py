import mysql.connector
import names

print("starting")

mydb = None

try:
    mydb = mysql.connector.connect(
        host="localhost",
        user="cargill_db",
        passwd="password",
        database="facelook"
    )
except Exception as e:
    print(e)
else:
    print("database connected")

mycursor = mydb.cursor()

group_lst = [names.get_full_name() for i in range(708)]

db_lst = []
fname_lst, lname_lst = [], []

print("generating names...")

for full_name in list(map(lambda x: x.split(" ") , group_lst)):
    fname_lst+= [full_name[0]]
    lname_lst+= [full_name[1]]

print(len(fname_lst), " first and ", len(lname_lst), " last names generated")

rec_num = 0

print("inserting names into database...")

for lname in lname_lst:
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
