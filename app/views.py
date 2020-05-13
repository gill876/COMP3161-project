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
from app.forms import LoginForm, RegisterForm, UpdateForm, ImageForm, PostForm,GroupForm, UserPost_CommentForm
from app.admin_forms import AdminLoginForm,  AdminSearchForm
from werkzeug.utils import secure_filename 
#from flask_mysqldb import MySQL
from flaskext.mysql import MySQL
from . import mysql


# from flask_bootstrap import Bootstrap
###
# Routing for your application.


@app.route('/home')
def home():
    if 'loggedin' in session:
        return render_template('home.html',username=session['username'])
    return redirect(url_for('login'))

@app.route('/search',methods=['GET','POST'])
def friend_search():
    if request.method == "POST":
        friend = request.form['friend']
        conn = mysql.connect()
        cursor =conn.cursor()
        cursor.execute('SELECT * username, FROM user WHERE username =%s',(friend))
        data = cursor.fetchall()

        if len (data) == 0 and friend == 'all':
            cursor.execute('SELECT * username FROM user')
            data = cursor.fetchall()
        return render_template('search.html',data=data)



    return render_template('search.html')

#reminder for neisha
#add the stuff you forgot..
@app.route("/", methods=["GET", "POST"])
def login():
    msg=''
    form = LoginForm()

    #Remove admin session data for regular user entry point
    if 'adminLoggedIn' in session or 'adminLoggedOut' in session:
        session.pop('adminLoggedIn')
        session.pop('adminLoggedOut')

    if request.method == "POST" and form.validate_on_submit():
        username = form.username.data
        password = form.password.data

        conn = mysql.connect()
        cursor =conn.cursor()
        cursor.execute('CALL loginUser(%s, %s)', (username, password,))
        data = cursor.fetchone()
        if data[0] == 'Login successful':
            cursor.execute('CALL getUserID(%s, %s)', (username, username,))
            data = cursor.fetchone()
            print(data)
            session['loggedin'] = True 
            session['id'] = int(data[0])
            session['username'] = username
            cursor.close()
            conn.close()
            return redirect(url_for('home'))
        elif data[0] == 'Password incorrect': #MODIFY
            pass
        elif data[0] == 'User does not exist': #MODIFY
            pass
        else:
            flash('Username or password incorrect. Please try again.') #MODIFY
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

        conn = mysql.connect()
        cursor =conn.cursor()

        cursor.execute('CALL userDetails(%s)', (int(session['id']),))
        data = cursor.fetchone()
  
        username = data[0]
        email_address = data[1]
        datejoined = data[2]
        firstname = data[3]
        lastname = data[4]
        profile_img = data[5]
        friends = data[6]
        biography = data[7]
        gender = data[8]

        year = datejoined.year
        month = datejoined.strftime("%B")
        day = datejoined.day
        cursor.close()
        conn.close()
        # print(username, "**", email_address, "**", datejoined, "**", firstname, "**",lastname, "**", profile_img, "**",friends, "**",biography, "**", gender, "**", year, "**", month, "**", day)
        #return "pass"
        return render_template('profile.html', username=username, email_address=email_address, year=year, month=month, day=day, firstname=firstname, lastname=lastname, profile_img=profile_img, friends=friends, biography=biography, gender=gender)

    return redirect(url_for('login')) #MODIFY FLASH APPROPRIATE MESSAGES



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
            flash('Passwords do not match')#MODIFY
            return render_template('register.html', form=form)

        conn = mysql.connect()
        cursor =conn.cursor()

        cursor.execute('SELECT user_id FROM user WHERE username = %s OR email_address = %s', (username, username,))
        data = cursor.fetchone()
        #print(data)

        if data == None:      
            filename = str(uuid.uuid4())
            old_filename = profile_photo.filename
            ext = old_filename.split(".")
            ext = ext[1]
            new_filename = filename + "." + ext
            new_filename = new_filename.replace('-', '_')
            profile_photo.save(os.path.join(app.config["PROFILEPHOTO_FOLDER"], new_filename))
            cursor.execute('CALL signUp(%s, %s, %s, %s, %s, %s, %s)', (username, email, password, firstname, lastname, new_filename, gender,))
            conn.commit()
            cursor.close()
            conn.close()
            return redirect(url_for('home')) #MODIFY ADD REDIRECTION WITH FLASH MESSAGE
        else:
            print("The account already exits")#MODIFY ADD APPROPRIATE RESPONSE
    return render_template('register.html', form=form)

@app.route('/create/group',methods=["GET","POST"])
def create_group():
    form = GroupForm()
    if request.method == "POST" and form.validate_on_submit():
        groupname = form.groupname.data
        description = form.description.data
        
        conn = mysql.connect()
        cursor =conn.cursor()
        # cursor.execute('CALL userDetails(%s)', (int(session['id']),))
        # cursor.execute('SELECT user_id FROM user WHERE username = %s OR email_address = %s', (username, username,))
        # data = cursor.fetchone()

        # if data == None:
        #     cursor.execute('CALL createGroup(%s,%s,%s)',(int(session['id']),groupname,description,))
        #     conn.commit()
        #     cursor.close()
        #     conn.close()
        return redirect(url_for('home'))


    return render_template('create_group.html',form =form)    



   



# @app.route('/updateprofile'/'<userid>')



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

    #print("images upload: ", imagesform.validate_on_submit())
    if request.method == "POST" and imagesform.validate_on_submit():
        image = imagesform.images.data 

        filename = str(uuid.uuid4())
        old_filename = image.filename
        ext = old_filename.split(".")
        ext = ext[1]
        new_filename = filename + "." + ext
        new_filename = new_filename.replace('-', '_')
        #print("filename: ", new_filename)
        image.save(os.path.join(app.config["PROFILEPHOTO_FOLDER"], new_filename))
        
        conn = mysql.connect()
        cursor =conn.cursor()
        #print(session['id'])
        cursor.execute('CALL updateProfilePicture(%s, %s)', (session['id'], new_filename,))
        conn.commit()

        cursor.close()
        conn.close()
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

@app.route('/post', methods=["GET","POST"])
def new_post():
    form = PostForm()
    if request.method =='POST' and form.validate_on_submit():
         content = form.content.data
         postphoto = form.postphoto.data 

    #conn = mysql.connect()
    #cursor = conn.cursor()

    return render_template('home.html',form=form)


@app.route("/groups", methods=['GET', 'POST'])
def groups():
    print('in groups')

    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('SELECT group_name, group_description FROM user_group')
    allGroups = cursor.fetchall()
    #print(allGroups)
    #session['id'] = 2
    cursor.execute('CALL showUserGroups(%s)', int(session['id']))
    userGroups = cursor.fetchall()
    #print(userGroups)
    groupids = [item[1] for item in userGroups]
    #print(groupids)

    groups = []
    for group in allGroups:
        cursor.execute('CALL getGroupId(%s)', group[0])
        groupId = cursor.fetchone()[0]
        member = True if groupId in groupids else False
        groups.append({
            "name": group[0],
            "description": group[1],
            "member": member
        })
        print(groups)
    
    cursor.close()
    conn.close()

    return render_template('groups.html', groups=groups)


@app.route('/usergroup', methods=["GET", "POST"])
def usergroup():
    form = PostForm()
    if request.method and form.validate_on_submit():
        content = form.content.data
        postphoto = form.postphoto.data 

        #connect to db 
    
    return render_template('usergroup.html',form=form)

@app.route('/userpost_comment', methods=["GET", "POST"])
def userpost_comment():
    form = UserPost_CommentForm()

    if request.method == "POST" and form.validate_on_submit():
        content_posted = form.content.data

        return redirect( url_for('userpost_comment'))

    return render_template('userpost_comment.html', form=form)



# user_loader callback. This callback is used to reload the user object from
# the user ID stored in the session


# user_loader callback. This callback is used to reload the user object from
# the user ID stored in the session
@login_manager.user_loader
def load_user(id):
    # return UserProfile.query.get(int(id))
    pass

###
# The functions below should be applicable to all Flask apps.


#Admin Routes

''' Admin Login '''
@app.route('/admin', methods=["GET", "POST"])
def admin():
    session['adminLoggedOut'] = True
    form = AdminLoginForm()

    if request.method == "POST":
        if form.validate_on_submit():
            uname = form.username.data
            passw = form.password.data

            if (uname == app.config['ADMIN_USERNAME'] and passw == app.config['ADMIN_PASSWORD']):
                session['adminLoggedOut'] = False
                session['adminLoggedIn'] = True
                return redirect(url_for('admin_dashboard'))
            else:
                flash('Username or password incorrect. Please try again.')          

            
    return render_template("admin/admin.html", form=form)


''' Admin Dashboard '''
@app.route("/admin/dashboard")
def admin_dashboard():

    if session['adminLoggedIn'] == True:
        conn = mysql.connect()
        cursor =conn.cursor()

        cursor.execute('SELECT COUNT(user_id) AS user_amt FROM userProfile')
        users = cursor.fetchone()
        print(users)
        cursor.execute('SELECT COUNT(group_id) AS group_amt  FROM create_group')
        groups = cursor.fetchone()
        print(groups)
        cursor.close()
        conn.close()
        stats = {
            "stat_users": {
                "label": "Total Users",
                "value": users[0]
            },
            "stat_groups": {
                "label": "Total Groups",
                "value": groups[0]
            }
        }
        return render_template("admin/admin_dashboard.html", stats=stats)
    
    return redirect(url_for('admin'))


''' Admin View User Page '''
@app.route("/admin/users")
def admin_users():
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL adminUserBio')
    bioData = cursor.fetchall()

    cursor.execute('CALL adminUserPostTotals')
    postTotals = cursor.fetchall()

    cursor.execute('CALL adminUserFriendTotals')
    friendTotals = cursor.fetchall()

    cursor.execute('CALL adminUserGroupTotals')
    groupTotals = cursor.fetchall()

    cursor.execute('CALL adminUserCommentTotals')
    commentTotals = cursor.fetchall()

    cursor.execute('SELECT COUNT(profile_id) FROM profile WHERE gender="FEMALE"')
    females = cursor.fetchone()

    cursor.execute('SELECT COUNT(profile_id) FROM profile WHERE gender="MALE"')
    males = cursor.fetchone()

    cursor.execute('SELECT COUNT(user_id) AS user_amt FROM userProfile')
    totalUsers = cursor.fetchone()

    cursor.close()
    conn.close()
    
    users = zip(bioData, postTotals, friendTotals, groupTotals, commentTotals)

    stats = [
        {
            "value": totalUsers[0],
            "label": "Total Users"
        },
        {
            "value": females[0],
            "label": "Total Female Users"
        },
        {
            "value": males[0],
            "label": "Total Male Users"
        },
    ]
            
    return render_template("admin/admin_user_report.html", stats=stats, users=users)


''' Admin View Groups Page '''
@app.route("/admin/groups")
def admin_groups():
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL adminGroupName')
    groupNames = cursor.fetchall()
    #print(groupNames)

    cursor.execute('CALL adminGroupCreatorByUserId')
    creators = cursor.fetchall()
    #print(creators)

    cursor.execute('CALL getGrpTotalMembers')
    grpTotals = cursor.fetchall()
    #print(grpTotals)

    cursor.execute('SELECT COUNT(group_id) FROM user_group')
    grpTotal = cursor.fetchone()
    #print(grpTotal)

    '''cursor.execute('SELECT COUNT(profile_id) FROM profile WHERE gender="Male"')
    males = cursor.fetchone()'''

    cursor.close()
    conn.close()

    groups = zip(groupNames, creators, grpTotals)

    stats = [
        {
            "value": grpTotal[0],
            "label": "Total Groups"
        },
        {
            "value": 234,
            "label": "Total Group Posts"
        },
    ]
          
    return render_template("admin/admin_group_report.html", stats=stats, groups=groups)

@app.route('/admin/groups/search')
def admin_search_groups():
    return render_template('test.html')

''' Admin Search Users Page '''
@app.route("/admin/user/search", methods=["GET", "POST"])
def admin_search_users():
    form = AdminSearchForm()
    
    if request.method == "POST" and form.validate_on_submit():
        search_value = form.searchTerm.data

        conn = mysql.connect()
        cursor = conn.cursor()

        cursor.execute('CALL adminGetUserBio(%s)', (search_value.strip()))
        userList = cursor.fetchall()

        results = []
        for user in userList:
            userId = user[0]

            cursor.execute('CALL getUserTotalPosts(%s)', int(userId))
            userPosts = cursor.fetchone()[0]

            cursor.execute('CALL getUserTotalComments(%s)', int(userId))
            userComments = cursor.fetchone()[0]

            cursor.execute('CALL getUserTotalFriends(%s)', int(userId))
            userFriends = cursor.fetchone()[0]

            cursor.execute('CALL getUserTotalGroups(%s)', int(userId))
            userGroups = cursor.fetchone()[0]

            results.append((user[1], user[2], user[3], userPosts, userComments, userFriends, userGroups))        

        cursor.close()
        conn.close()

        return render_template("admin/admin_search.html", form=form, results=results) 

    return render_template("admin/admin_search.html", form=form)



@app.route('/admin/logout')
def admin_logout():
    if session['adminLoggedIn']:
        session.pop('adminLoggedIn')
        session['adminLoggedOut'] = True
    return render_template(url_for('admin'))


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
