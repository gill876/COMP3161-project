import mysql.connector
import names, csv

def generate_fullnames(amount):
    """accepts amount of fullnames to be generated and outputs the fullnames in a list: ['Mary Brown', 'John Brown']"""
    group_lst = [names.get_full_name() for i in range(amount)]
    return group_lst

def generate_gender_fullnames(amount, gender='', prefix=[],suffix=[], format='lst'):
    """accepts amount of male or female fullnames to be generated and outputs the fullnames in a list or dictionary: 
    [['Paul', 'Brown', 'MALE'], ['Brian', 'Ledet', 'MALE'], ['James', 'Kim', 'MALE']] or 
    {0: ['Cameron', 'Couch', 'FEMALE'], 1: ['Carrie', 'Key', 'FEMALE'], 2: ['Anna', 'Garcia', 'FEMALE']}"""

    group_lst = {}

    if gender != 'male' and gender != 'female':
        print("Enter gender: male or female")
        return 0

    for i in range(amount):
        full_name = names.get_full_name(gender).split(" ")
        full_name+= (['MALE'] if gender == 'male' else ['FEMALE']) #chooses between male or female depending on input
        """function of prefix was disregarded to speed up application"""
        #if prefix!=[]:
        #    full_name.insert(0, prefix[i])
        #prefix_iter = (full_name[1] if prefix!=[] else full_name)
        #full_name.append(suffix[1]) was not implemented
        if full_name not in group_lst.values(): #change full_name to prefix_iter to incoporate prefix
            group_lst[i]=full_name

    if format=='dict':
        return group_lst
    elif format=='lst':
        return [v for v in group_lst.values()]
    else:
        print("Enter output format: lst or dict")
        return 0

def lst_to_csv(lst, column, filename='mycsv', prefix=[], suffix=[]):
    filename+='.csv'
    with open(filename, 'w', newline='') as f:
        csv_writer = csv.writer(f)

        csv_writer.writerow(column)
        
        for count, item in enumerate(lst):
            item.insert(0, prefix[count])
            csv_writer.writerow(item)


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
    

"""print("starting")

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
print("done")"""

#################TEST GROUNDS#####################
#print(generate_gender_fullnames(3, 'female', 'dict'))
#lst_to_csv(generate_gender_fullnames(3, 'female', [1, 2, 3]), (['id', 'fname', 'lname', 'gender']))
#lst_to_csv(generate_gender_fullnames(3, 'female'), (['fname', 'lname', 'gender']))


amount = 7
prefix = list(range(amount))
gender ='male'
column_name = ['id', 'fname', 'lname', 'gender']
filename = 'test'

lst_to_csv(generate_gender_fullnames(amount, gender), (column_name), filename, prefix)