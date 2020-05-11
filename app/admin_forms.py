from flask_wtf import FlaskForm 
from wtforms import StringField, PasswordField, FileField, SelectField, SubmitField
from flask_wtf.file import FileField, FileRequired, FileAllowed
from wtforms.validators import InputRequired,DataRequired,Email
from wtforms.fields.html5 import DateField
from wtforms.csrf.session import SessionCSRF


class LoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired()])
    password = PasswordField('Password', validators=[InputRequired()])

class AdminSearchForm(FlaskForm):
    searchTerm = StringField('Enter search term', validators=[InputRequired()])
    submitBtn = SubmitField('Search')
    csrf = True
    csrf_class = SessionCSRF
    csrf_secret = "5C2TJCKILM4I2Q5YZPZ2"
