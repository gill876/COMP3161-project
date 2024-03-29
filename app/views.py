"""
Flask Documentation:     http://flask.pocoo.org/docs/
Jinja2 Documentation:    http://jinja.pocoo.org/2/documentation/
Werkzeug Documentation:  http://werkzeug.pocoo.org/documentation/
This file creates your application.
"""

import os
import datetime 
import psycopg2
# from flask_mysqldb import MySQL
from app import app, login_manager
from flask import render_template, request, redirect, url_for, flash
from flask_login import login_user, logout_user, current_user, login_required
from app.forms import LoginForm,RegisterForm,UpdateForm
from werkzeug.utils import secure_filename 
# from app.models import UserProfile
# from flask_bootstrap import Bootstrap
###
# Routing for your application.
###


# mysql = MySQL(app)

# @app.route('/')
# def index():
#     cur = mysql.connection.cursor()

#     cur.execute('''CREATE TABLE example (id INTEGER,name VARCHAR(20))''')
#     return 'Done'

# def connect_db():
#     return psycopg2.connect(host="localhost",database="userz",user="conrodsmith",password="mantis101")
# @app.route('/', methods=['POST', 'GET'])
# def add_user():
#     if request.method == "POST":
#         db = connect_db()
#         cur = db.cursor()
#         cur.execute('insert into userz (name, email) values (%s, %s)')
#         db.commit() 
#         flash('New user was successfully added') 
        
#     return render_template('home.html')


@app.route('/')
def home():
    """Render website's home page."""
    return render_template('home.html')

# @app.route('/profile/<username>')
# def profile(username):
#     return render_template('profile.html',name=username)

@app.route('/profile')
# @login_required
def profile():
    return render_template('profile.html')




@app.route("/register", methods=["GET","POST"])
def register():
    form = RegisterForm()
    if request.method == "POST" and form.validate_on_submit():

        username = form.username.data
        firstname = form.firstname.data 
        lastname = form.lastname.data 
        gender = form.gender.data 
        dob = form.dob.data   
        email = form.email.data   
        password = form.password.data   
        confirmpassword = form.confirmpassword.data 
        profile_photo = form.profile_photo.data  

        #saviing profile images tothe profilephoto_folder

        filename = secure_filename(profile_photo)
        profile_photo.save(os.path.join(app.config['PROFILEPHOTO_FOLDER', filename]))

        #code for db goes here



        flash('Your Profile Has Been Created')

        return redirect(url_for("profile"))
    else: 
        flash("Profile Not Created! Please Try again!")

    return render_template('register.html', form=form)


@app.route("/login", methods=["GET", "POST"])
def login():
    form = LoginForm()
    if request.method == "POST" and form.validate_on_submit():
        # change this to actually validate the entire form submission
        # and not just one field
    
            username = form.username.data
            password = form.password.data
            # Get the username and password values from the form.
            
            # user = UserProfile.query.filter_by(username=username).first()

            if user is not None and check_password_hash(user.password, password ):
                login_user(user)
                flash("Login Successful", "Successful")
                return redirect(url_for("profile"))  # they should be redirected to a secure-page route instead
            else:
                flash("Unsuccessful Login", "Unsuccesful")
    return render_template("login.html", form=form)


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

# @app.route("/register")
# def register():
#     return render_template ('register.html')


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
    
@app.route("/logout")
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'danger')
    return redirect(url_for('home'))


@app.route('/<file_name>.txt')
def send_text_file(file_name):
    """Send your static text file."""
    file_dot_text = file_name + '.txt'
    return app.send_static_file(file_dot_text)

@app.route("/lateefah")
def lateefah():
    props = {}
    return render_template("test.html", details = props)

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
