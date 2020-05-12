from flask_wtf import FlaskForm 
from wtforms import StringField, PasswordField,FileField,SelectField,TextAreaField
from flask_wtf.file import FileField, FileRequired, FileAllowed
from wtforms.validators import InputRequired,DataRequired,Email
from wtforms.fields.html5 import DateField


class LoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired()])
    password = PasswordField('Password', validators=[InputRequired()])

class AdminLoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired()])
    password = PasswordField('Password', validators=[InputRequired()])

class RegisterForm(FlaskForm):
    firstname=StringField('First Name',validators=[InputRequired(message='First Name is required')])
    lastname=StringField('Last Name',validators=[InputRequired(message='Last Name is required')])
    gender=SelectField('Gender', choices=[('MALE','Male'),('FEMALE','Female'),('NON-BINARY','Non-Binary'), ('OTHER','Other')])
    username=StringField('User Name',validators=[InputRequired(message='User Name is required')])
    email = StringField('Email', validators=[InputRequired(message='Email is required'), Email(message="Only Emails")])  
    profile_photo = FileField('Profile Picture', validators=[FileRequired(), FileAllowed(['jpg', 'png', 'jpeg', 'IMAGES ONLY!']) ]) 
    password=PasswordField('Password',validators=[InputRequired(message='Password is required')])
    confirmpassword=PasswordField('Confirm Password',validators=[InputRequired(message='Retype password')])
    

class UpdateForm(FlaskForm):
    firstname=StringField('First Name',validators=[InputRequired(message='First Name is required')])
    lastname=StringField('Last Name',validators=[InputRequired(message='Last Name is required')])
    username=StringField('User Name',validators=[InputRequired(message='Username is required')])
    email = StringField('Email', validators=[InputRequired(message='Email is required'), Email(message="Only Emails")])
    profile_photo = FileField('Profile Picture', validators=[FileRequired(), FileAllowed(['jpg', 'png', 'IMAGES ONLY!']) ])
    password=PasswordField('Password',validators=[InputRequired(message='Password is required')])
    confirmpassword=PasswordField('Confirm Password',validators=[InputRequired(message='Retype password')])
      
    
class PostForm(FlaskForm):
    content = TextAreaField('Content',validators=[InputRequired(message='Need content to post')])
    postphoto = FileField('Post photo',validators=[FileAllowed(['jpg','jpeg','png'],'Images Only')])

class UserPost_CommentForm(FlaskForm):
    content = TextAreaField('Content',validators=[InputRequired(message='Need content to post')])


class ImageForm(FlaskForm):
    images = FileField('images', validators=[
        FileRequired(),
        FileAllowed(['jpg', 'png', 'jpeg', 'Images only!'])
    ])
    
class GroupForm(FlaskForm):
    
     groupname=StringField('Group Name',validators=[InputRequired(message='A Group Name is required')])
     description = TextAreaField('Description',validators=[InputRequired(message='Need a description of Group')])