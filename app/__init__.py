from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
from flask_mysqldb import MySQL
from flask_script import Manager
# from flask_mysqldb import MySQL
# from flask_bootstrap import Bootstrap


app = Flask(__name__)
app.config['SECRET_KEY'] = "change this to be a more random key"
# app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://pro:mantis101@localhost/lab5"
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True # added just to suppress a warning
# bootstrap = Bootstrap(app)
manager = Manager(app)


app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'mybook'
app.config['MYSQL_PASSWORD'] = 'password'
app.config['MYSQL_DB'] = 'mybook'

mysql = MySQL(app)


#adding images to respective folders

app.config["PROFILEPHOTO_FOLDER"] ='./app/static/profileimages'

# IMAGE_UPLOAD_FOLDER= './app/static/userprofileimages'

UPLOAD_FOLDER= './app/static/images'

# Flask-Login login manager
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

app.config.from_object(__name__)
from app import views
