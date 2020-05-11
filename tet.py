import mysql.connector

db = mysql.connector.connect(
    host = "localhost",
    user = "root",
    password= "mantis101"
    
)

mycursor =db.cursor()

mycursor.execute("CREATE DATABASE wetland")
