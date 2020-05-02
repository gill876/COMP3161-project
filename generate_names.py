import mysql.connector
import names, csv
import random

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

####mysqlimport -h 'localhost' -u root -p --fields-terminated-by=, --ignore-lines=1 <db_name> /var/lib/mysql-files/mycsv.csv
def lst_to_csv(lst, column, filename='mycsv', prefix=[], suffix=[]):
    """converts list into csv file by accepting the list, the column names for the csv, the filename without an extension,
    prefix with items in a list that could be added to each list item and suffix items in a list to add to each list item
    
    :::::::::::Example:::::::::::

    amount = 3
    prefix = [[1, 'testP_1'], [2, 'testP_2'], [3, 'testP_3']] #used for more than one prefix
    suffix = [['testS_1', 'testSS_1'], ['testS_2', 'testSS_2'], ['testS_3', 'testSS_3']]
    gender ='male'
    column_name = ['id', 'test_pref', 'fname', 'lname', 'gender', 'test_suff1', 'test_suff2']
    filename = 'test'
    names_list = [['Alejandro', 'Allard', 'MALE'], ['David', 'Moore', 'MALE'], ['George', 'Rodgers', 'MALE']]

    lst_to_csv(names_list, (column_name), filename, prefix, suffix)
    
    :::::::::CSV FILE::::::::::
    id,test_pref,fname,lname,gender,test_suff1,test_suff2
    1,testP_1,Alejandro,Allard,MALE,testS_1,testSS_1
    2,testP_2,David,Moore,MALE,testS_2,testSS_2
    3,testP_3,George,Rodgers,MALE,testS_3,testSS_3
    """
    filename+='.csv'
    with open(filename, 'w', newline='') as f:
        csv_writer = csv.writer(f)

        csv_writer.writerow(column)

        for count, item in enumerate(lst):
            ##################DATABASE SPECIFIC. ADD USERNAME AND EMAIL ADDRESS##################
            username = item[0] + item[1]
            username = username.lower()
            username = username[:4] + username[6:9] + str(count)
            spec_char = ['`','~','!','@','#','$','%','^','&','*','(',')','_','-','+','=','{','[','}','}','|',':',';','<','>','.','?','/']
            password = username + spec_char[random.randint(0,27)]
            email_addresses = ['@coach.net', '@quarantine.com', '@stayin.com', '@tiktok.com']
            email_addr = username + email_addresses[random.randint(0,3)]
            prefix = [(username), (email_addr), password]
            #####################################################################################
            if prefix != []:
                #item = prefix[count]+item #for different prefixes
                #all prefixes are the same so:
                item = prefix+item
            if suffix != []:
                item += suffix[count]
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

def get_FandL_name_from_fullname(fullnames):
    """accepts lists of fullnames and splits first and last names into 2 separate lists and stores each list in a dictionary to be returned"""
    fullnames_dict = {}
    fnames = []
    lnames = []

    for names in fullnames:
        
        fnames+= [names[0]]
        lnames+= [names[1]]

    fullnames_dict['fname'] = fnames
    fullnames_dict['lname'] = lnames

    return fullnames_dict
        
def multiply_names(fnames, lnames, gender=''):
    """multiply names by assigning all first names to each lastnames; adding a gender that applies to all names:
    input = (['all', 'first', 'names'], ['all', 'last', 'names'], 'gender')
    output = ([['all', 'all', 'gender'], ['all', 'last', 'gender'], ['all', 'names', 'gender'], ['first', 'all', 'gender'], ....])
    """
    m_fullnames = []

    for lname in lnames:
        for fname in fnames:
            if gender != '':
                m_fullnames+= [[fname, lname, gender]]
            else:
                m_fullnames+= [[fname, lname]]
    return m_fullnames

def main(column_names, filename, amount):
    """accepts list of column names for csv, filename for csv, amount of unique male and female names to be generated"""
    print("started...")
    grand_lst =[]
    print("generating ", amount, " unique male fullnames...")
    male_fullnames = generate_gender_fullnames(amount, 'male')
    print("generating ", amount, " unique female fullnames...")
    female_fullnames = generate_gender_fullnames(amount, 'female')

    print("splitting male fullnames...")
    male_names = get_FandL_name_from_fullname(male_fullnames)
    print("splitting female fullnames...")
    female_names = get_FandL_name_from_fullname(female_fullnames)
    
    print("multiplying male fullnames...")
    grand_lst += multiply_names(male_names['fname'], male_names['lname'], 'MALE')
    print("multiplying female fullnames...")
    grand_lst += multiply_names(female_names['fname'], female_names['lname'], 'FEMALE')

    print(len(grand_lst), "records generated")

    print("adding names to csv file named: ", filename,"...")
    lst_to_csv(grand_lst, column_names, filename)
    print("done")

    

main(['username', 'email', 'password','fname', 'lname', 'gender'], 'csv_users', 520)

#################TEST GROUNDS#####################
#print(generate_gender_fullnames(3, 'female', 'dict'))
#lst_to_csv(generate_gender_fullnames(3, 'female', [1, 2, 3]), (['id', 'fname', 'lname', 'gender']))
#lst_to_csv(generate_gender_fullnames(3, 'female'), (['fname', 'lname', 'gender']))

##################################################
#amount = 3
#prefix = list(range(amount)) #prefix for id num
#prefix = [[1, 'testP_1'], [2, 'testP_2'], [3, 'testP_3']] #used for more than one prefix
#suffix = [['testS_1', 'testSS_1'], ['testS_2', 'testSS_2'], ['testS_3', 'testSS_3']]
#gender ='male'
#column_name = ['id', 'test_pref', 'fname', 'lname', 'gender', 'test_suff1', 'test_suff2']
#filename = 'test'
#names_list = generate_gender_fullnames(amount, gender)

#lst_to_csv(names_list, (column_name), filename, prefix, suffix)
##################################################

#lst_to_csv(generate_gender_fullnames(100000, 'male'),['fname', 'lname', 'gender'])

#################################3
#output = get_FandL_name_from_fullname(generate_gender_fullnames(4, 'male'))
#print(output)
#print(multiply_names(output['fname'], output['lname'], 'MALE'))