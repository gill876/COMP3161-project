from flask_wtf import FlaskForm 
from wtforms import StringField, PasswordField,FileField,SelectField
from wtforms.validators import InputRequired,DataRequired,Email
from wtforms.fields.html5 import DateField


class LoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired()])
    password = PasswordField('Password', validators=[InputRequired()])

class RegisterForm(FlaskForm):
    fname=StringField('First Name',validators=[InputRequired(message='First Name is required')])
    lname=StringField('Last Name',validators=[InputRequired(message='Last Name is required')])
    gender=SelectField('Gender', choices=[('Male','Male'),('Female','Female')])
    dob=DateField('Date of Birth',format='%m/%d/%Y')
    email = StringField('Email', validators=[InputRequired(message='Email is required'), Email(message="Only Emails")])   
    password=PasswordField('Password',validators=[InputRequired(message='Password is required')])
    confirmpassword=PasswordField('Confirm Password',validators=[InputRequired(message='Retype password')])
    username=StringField('User Name',validators=[InputRequired(message='User Name is required')])
    # profile_photo = FileField('Image', validators=[FileAllowed(['jpg', 'jpeg','png'], 'Images only!')])

