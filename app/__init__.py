from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
from flask_script import Manager
from flask_bootstrap import Bootstrap


app = Flask(__name__)
app.config['SECRET_KEY'] = "change this to be a more random key"
# app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://pro:mantis101@localhost/lab5"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True # added just to suppress a warning
bootstrap = Bootstrap(app)
manager = Manager(app)
db = SQLAlchemy(app)

# Flask-Login login manager
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

app.config.from_object(__name__)
from app import views
