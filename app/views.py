"""
Flask Documentation:     http://flask.pocoo.org/docs/
Jinja2 Documentation:    http://jinja.pocoo.org/2/documentation/
Werkzeug Documentation:  http://werkzeug.pocoo.org/documentation/
This file creates your application.
"""

import os
import uuid
import datetime 
import MySQLdb.cursors
import re
import mysql.connector
from mysql.connector import errorcode,connection
from app import app, login_manager
from flask import render_template, request, redirect, url_for, flash,session
from flask_login import login_user, logout_user, current_user, login_required
from app.forms import LoginForm,RegisterForm,UpdateForm, ImageForm, PostForm
from werkzeug.utils import secure_filename 
from flask_mysqldb import MySQL


# from app.models import UserProfile
# from flask_bootstrap import Bootstrap
###
# Routing for your application.
###
mysql = MySQL(app)


@app.route('/home')
def home():
    if 'loggedin' in session:
        return render_template('home.html',username=session['username'])
    return redirect(url_for('login'))


#reminder for neisha
#add the stuff you forgot..
@app.route("/", methods=["GET", "POST"])
def login():
    msg=''
    form = LoginForm()
    if request.method == "POST" and form.validate_on_submit():
        #Recreate the error lemme see. I think I want to try to connect the database 
        #the one i highlighted
        
        # if request.form['username'] != app.config['username'] or request.form['password'] != app.config['passowrd']:
        #     error = "Incorrect username or password!"
        # else: 
        #     session['logged_in'] = True
        username = form.username.data
        password = form.password.data
        #flash("Login Successful", "Successful")
        # Check if account exists using MySQL
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('CALL loginUser(%s, %s)', (username, password,))
        rv = cursor.fetchall()
        
        if rv == ({'Login successful': 'Login successful'},):
            cursor.execute('CALL getUserID(%s, %s)', (username, username,))
            rv = cursor.fetchall()
            cursor.close()
            session['loggedin'] = True 
            session['id'] = int(rv[0]['user_id'])
            session['username'] = username
            return redirect(url_for('home'))
        #else:
        #    msg='Incorrect username or password'
            #pass
        elif rv == ({'Password incorrect': 'Password incorrect'},):
            pass
        elif rv == ({'User does not exist': 'User does not exist'},):
            pass
            #return "fatal error"
        else:
            msg ='Incorrect Username/Password'
    return render_template("index.html", form=form,msg=msg)


@app.route('/logout')
def logout():
    # Remove session data, this will log the user out
   session.pop('loggedin', None)
   session.pop('id', None)
   session.pop('username', None)
   # Redirect to login page
   return redirect(url_for('login'))

@app.route('/profile')
def profile():
    
    if 'loggedin' in session:
        #print(session['id'])
        #print(session['username'])
        
        #print(details)
        username = None
        email_address = None
        datejoined = None
        firstname = None
        lastname = None
        profile_img = None
        friends = None
        biography = None
        gender = None

        year = None
        month = None
        day = None

        try:
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute('CALL userDetails(%s)', (int(session['id']),))
            details = cursor.fetchone()
            cursor.close()

            username = details['username']
            email_address = details['email_address']
            datejoined = details['datejoined']
            firstname = details['firstname']
            lastname = details['lastname']
            profile_img = details['profile_img']
            friends = details['friends']
            biography = details['biography']
            gender = details['gender']

            year = datejoined.year
            month = datejoined.strftime("%B")
            day = datejoined.day
        
        except: 
            print("Something went wrong connecting with the database")

        #print("*******************")
        print(username, "**", email_address, "**", datejoined, "**", firstname, "**",lastname, "**", profile_img, "**",friends, "**",biography, "**", gender, "**", year, "**", month, "**", day)
        #print(datejoined.year)
        return render_template('profile.html', username=username, email_address=email_address, year=year, month=month, day=day, firstname=firstname, lastname=lastname, profile_img=profile_img, friends=friends, biography=biography, gender=gender)
        #return render_template('profile.html')
    return redirect(url_for('login'))



@app.route("/register", methods=["GET","POST"])
def register():
    form = RegisterForm()
    if request.method == "POST" and form.validate_on_submit():
        username = form.username.data
        email = form.email.data   
        firstname = form.firstname.data 
        lastname = form.lastname.data 
        gender = form.gender.data 
        email = form.email.data   
        password = form.password.data   
        confirmpassword = form.confirmpassword.data 
        profile_photo = form.profile_photo.data  
        

        if password != confirmpassword:
            flash('Passwords do not match')
            return render_template('register.html', form=form)

        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        #query/procedure to check db for username if account exist
        cursor.execute('SELECT user_id FROM user WHERE username = %s OR email_address = %s', (username, username,))
        user = cursor.fetchone()
        #if account exist show error and validate checks
        if user == None:      
            filename = str(uuid.uuid4())
            old_filename = profile_photo.filename
            ext = old_filename.split(".")
            ext = ext[1]
            new_filename = filename + "." + ext
            new_filename = new_filename.replace('-', '_')
            profile_photo.save(os.path.join(app.config["PROFILEPHOTO_FOLDER"], new_filename))
            cursor.execute('CALL signUp(%s, %s, %s, %s, %s, %s, %s)', (username, email, password, firstname, lastname, new_filename, gender,))
            mysql.connection.commit()
            cursor.close()
            
        else:
            print("The account already exits")
    return render_template('register.html', form=form)



# @app.route('/updateprofile'/'<userid>')
@app.route('/updateprofile')
# @login_required (was sure if this was overkill or not)
def updateprofile():
    form = UpdateForm()

    if request.method and form.validate_on_submit():

        firstname = form.firstname.data  
        lastname = form.lastname.data
        username = form.username.data
        email = form.email.data
        profile_photo = form.profile_photo.data
        password = form.password.data 
        confirmpassword = form.confirmpassword.data 

        filename = secure_filename(profile_photo)
        profile_photo.save(os.path.join(app.config['PROFILEPHOTO_FOLDER', filename]))

        #checking if the user is actually the user and checking the 
        #password hash
        #check the logic for this please, somebody
        if (user == user):
            check_password_hash(user.password, password)
            flash("Profile Updated!")
            redirect(url_for('profile'))
        else:
            flash("Profile Not Updated. Please Try Again!")
    
    return render_template('updateprofile.html', form=form)


#should render the page for 
#the images
@app.route("/images", methods=['POST', 'GET'])
def images():
    imagesform = ImageForm()

    if request.method == "POST" and images.validate_on_submit():
        image = imagesform.images.data 

        filename= secure_filename(image.filename)
        image.save(os.path.join(app.config['IMAGE_UPLOAD_FOLDER', filename]))

        flash("Your images as been successfully posted!", 'success')
        return redirect(url_for('profile'))

    photos = get_images()
    if photos ==[]:
        flash ('No Images')
        return redirect(url_for('home'))

    return render_template('images.html', form=imagesform,images=photos)

def get_images():
    plst=[]
    rootdir = os.getcwd()
    for subdir, dirs, files in os.walk (rootdir + '/app/static/images'):
        for file in files:
            plst = plst+[os.path.join(file)]
    return plst

# def get_uploaded_images():
#     rootdir = os.getcwd()
#     pictures = []
#     print (rootdir)

#     for subdir, dirs, files in os.walk(rootdir + './app/static/userprofileimages'):
#         print(dirs)

#         for file in pictures:
#             print (os.path.join(subdir, files))
#             files.append("userprofileimages/" + file)

#             return files

#     return render_template("profile.html"  )


@app.route("/groups", methods=['GET', 'POST'])
def groups():
    return render_template('groups.html')

@app.route('/usergroup', methods=["GET", "POST"])
def usergroup():

    form = PostForm()
    if request.method and form.validate_on_submit():
        content = form.content.data
        postphoto = form.postphoto.data 

        #connect to db 
    
    return render_template('usergroup.html',form=form)

# user_loader callback. This callback is used to reload the user object from
# the user ID stored in the session
@login_manager.user_loader
def load_user(id):
    # return UserProfile.query.get(int(id))
    pass

###
# The functions below should be applicable to all Flask apps.
###

@app.route("/secure_page")
@login_required
def secure_page():
    """Render a secure page on our website that only logged in users can access."""
    return render_template('secure_page.html')
    



@app.route('/<file_name>.txt')
def send_text_file(file_name):
    """Send your static text file."""
    file_dot_text = file_name + '.txt'
    return app.send_static_file(file_dot_text)


@app.after_request
def add_header(response):
    """
    Add headers to both force latest IE rendering engine or Chrome Frame,
    and also to cache the rendered page for 10 minutes.
    """
    response.headers['X-UA-Compatible'] = 'IE=Edge,chrome=1'
    response.headers['Cache-Control'] = 'public, max-age=0'
    return response


@app.errorhandler(404)
def page_not_found(error):
    """Custom 404 page."""
    return render_template('404.html'), 404


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port="8080")
