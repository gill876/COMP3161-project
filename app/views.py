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
import datetime
import mysql.connector
from mysql.connector import errorcode,connection
from app import app, login_manager
from flask import render_template, request, redirect, url_for, flash,session
from flask_login import login_user, logout_user, current_user, login_required
from app.forms import LoginForm, RegisterForm, UpdateForm, ImageForm, PostForm,GroupForm, UserPost_CommentForm, FriendForm
from app.admin_forms import AdminLoginForm,  AdminSearchForm
from werkzeug.utils import secure_filename 
from flask_mysqldb import MySQL
from flaskext.mysql import MySQL
from . import mysql


# from flask_bootstrap import Bootstrap
###
# Routing for your application.


@app.route('/home')
def home():
    form = UserPost_CommentForm()
    if 'loggedin' in session:
        userProfileDetails = getProfileDetails(session['id'])
        friends = getUserFriends(session['id'])
        postDetails = getUserProfilePostDetails(session['id'])
        postDetails2 = getUserProfilePostDetails(3)
        groups = getUserGroupDetails(session['id'])
        print("***", postDetails)

        return render_template('home.html', userProfileDetails=userProfileDetails, friends=friends, posts=postDetails, groups=groups, form=form, postDetails2=postDetails2)
        
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

def getUserFriends(userId):
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL adminGetUserFriends(%s)', int(userId))
    allFriends = cursor.fetchall()

    cursor.close()
    conn.close()

    relatives = []
    schoolFriends = []
    workFriends = []

    print(allFriends)

    for fr in allFriends:
        if fr[2] == "RELATIVE":
            relatives.append(fr)
        elif fr[2] == "WORK":
            workFriends.append(fr)
        else:
            schoolFriends.append(fr)

    return (relatives, schoolFriends, workFriends)

def getProfileDetails(userId):
    conn= mysql.connect()
    cursor =conn.cursor()

    cursor.execute('CALL userDetails(%s)', int(userId))
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

    finalDets = (username, email_address, datejoined.strftime("%m/%d/%Y"), firstname, lastname, profile_img, friends, biography, gender)

    return finalDets

def getProfileTotals(userId):
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL getUserTotalPosts(%s)', int(userId))
    totalProfilePosts = cursor.fetchone()[0]

    cursor.execute('CALL adminGetUserPostImageDetails(%s)', int(userId))
    photos = cursor.fetchall()
    totalPhotos = len(photos)

    return {
        "posts": totalProfilePosts,
        "photos": totalPhotos
    }

def getUserGroupDetails(userId):
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL adminUserGroups(%s)', int(userId))
    userGroups = cursor.fetchall()

    cursor.close()
    conn.close()

    return userGroups

def getUserProfilePostDetails(userId):
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL adminGetUserPostDetails(%s)', int(userId))
    userPostsT = cursor.fetchall()
    print('userPosts', userPostsT)

    cursor.execute('CALL adminGetAllCommentDetails()')
    allComments = cursor.fetchall()
    print('usercomments', allComments)

    cursor.execute('CALL adminGetUserPostImageDetails(%s)', int(userId))
    userPostImages = cursor.fetchall()
    print('userpOST IMG', userPostImages)

    userPosts= []
    for item in userPostsT:
        comments = getCommentsObject(item[2], allComments)
        print(comments)
        imgIndex = findImageIndex(item[2], userPostImages)
        if imgIndex != -1:
            userPosts.append(
                {
                    "profile_img": item[0],
                    "id": str(item[2]),
                    "poster": item[1],
                    "location": item[3],
                    "timestamp": item[4].strftime("%m/%d/%Y, %H:%M:%S"),
                    "content": item[5],
                    "image": userPostImages[imgIndex][1],
                    "comments": comments
                }
            )
        else:
            userPosts.append(
                {
                    "profile_img": item[0],
                    "id": str(item[2]),
                    "poster": item[1],
                    "location": item[3],
                    "timestamp": item[4].strftime("%m/%d/%Y, %H:%M:%S"),
                    "content": item[5],
                    "image": "",
                    "comments": comments
                }
            )     

    cursor.close()
    conn.close()

    return userPosts


@app.route('/profile')
def profile():

    form = PostForm()
    
    if 'loggedin' in session:
        #print(session['id'])
        #print(session['username'])


        userProfileDetails = getProfileDetails(session['id'])
        friends = getUserFriends(session['id'])
        profileTotals = getProfileTotals(session['id'])
        profileTotals.update({"friends": len(friends)})
        postDetails = getUserProfilePostDetails(session['id'])
        form = UserPost_CommentForm()

        return render_template('profile.html', userProfileDetails = userProfileDetails, friends = friends, totals = profileTotals, posts = postDetails, form=form)

    return redirect(url_for('login'))  #MODIFY FLASH APPROPRIATE MESSAGES

@app.route('/profile/<friend_uname>')
def friend_profile(friend_uname):
    
    if 'loggedin' in session:
        form = UserPost_CommentForm()

        conn = mysql.connect()
        cursor = conn.cursor()

        cursor.execute('SELECT user_id FROM user WHERE username = (%s)', friend_uname)
        userId = cursor.fetchone()[0]

        cursor.close()
        conn.close()

        userProfileDetails = getProfileDetails(userId)
        friends = getUserFriends(userId)
        profileTotals = getProfileTotals(userId)
        profileTotals.update({"friends": len(friends)})
        postDetails = getUserProfilePostDetails(userId)

        return render_template('friend_profile.html', userProfileDetails = userProfileDetails, friends = friends, totals = profileTotals, posts = postDetails, form=form) 

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
            return redirect(url_for('login')) #MODIFY ADD REDIRECTION WITH FLASH MESSAGE
        else:
            print("The account already exits")#MODIFY ADD APPROPRIATE RESPONSE
    return render_template('register.html', form=form)

@app.route('/create/group',methods=["GET","POST"])
def create_group():
    form = GroupForm()

    print("Entered create group")
    if request.method == "POST":
        print("***method is post***")
        form.groupname.data = request.form['groupname']
        form.description.data = request.form['description']
        if request.form['description'] != "" and request.form['groupname'] !="":
            print("Form is received")
            groupname = form.groupname.data
            description = form.description.data
            
            conn = mysql.connect()
            cursor =conn.cursor()
            #cursor.execute('CALL userDetails(%s)', (int(session['id']),))
            # cursor.execute('SELECT user_id FROM user WHERE username = %s OR email_address = %s', (username, username,))
            # data = cursor.fetchone()

            # if data == None:
            cursor.execute('CALL createGroup(%s,%s,%s)',(int(session['id']),groupname,description,))
            conn.commit()
            cursor.close()
            conn.close()
            return redirect(url_for('home'))


    return render_template('create_group.html',form=form)      


# @app.route('/updateprofile'/'<userid>')
@app.route('/updateprofile')
# @login_required (was sure if this was overkill or not)
def updateprofile():
    form = UpdateForm()

    if request.method =="POST" and form.validate_on_submit():

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


@app.route('/gen_post', methods=["GET","POST"])
def gen_post():
    print(session['loggedin'])
    if 'loggedin' in session:
        form = PostForm()
        if request.method == 'POST' and form.validate_on_submit():
            content = form.content.data
            location = form.location.data
            postphoto = form.postphoto.data
            photonam= ""

            if not (postphoto == None):
                print('saving file')
                filename = str(uuid.uuid4())
                old_filename = postphoto.filename
                ext = old_filename.split(".")
                ext = ext[1]
                new_filename = filename + "." + ext
                new_filename = new_filename.replace('-', '_')
                postphoto.save(os.path.join(app.config["POSTSPHOTO_FOLDER"], new_filename))
                photonam = new_filename

            conn = mysql.connect()
            cursor = conn.cursor()

            if not (postphoto == None):
                print('post photo')
                cursor.execute('CALL createImagePost(%s, %s, %s, %s)', (session['id'], content, location, photonam))
            else:
                print('no photo')
                cursor.execute('INSERT INTO post(content, time_stamp, post_location) VALUES (%s,%s,%s)', (content, datetime.datetime.now(), location))

                cursor.execute('SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1')
                postId = cursor.fetchone()[0]
                print(postId)

                cursor.execute('INSERT INTO create_post VALUES(%s, %s)', (session['id'], postId))

            conn.commit()
            cursor.close()
            conn.close()

            return redirect(url_for('home'))

        return render_template ('gen_post.html', form=form)
    return redirect (url_for('login'))



@app.route('/gen_group_post', methods=["GET","POST"])
def gen_group_post():
    print(session['loggedin'])
    if 'loggedin' in session:
        form = PostForm()
        if request.method == 'POST' and form.validate_on_submit():
            content = form.content.data
            location = form.location.data
            postphoto = form.postphoto.data
            photonam= ""

            if not (postphoto == None):
                print('saving file')
                filename = str(uuid.uuid4())
                old_filename = postphoto.filename
                ext = old_filename.split(".")
                ext = ext[1]
                new_filename = filename + "." + ext
                new_filename = new_filename.replace('-', '_')
                postphoto.save(os.path.join(app.config["POSTSPHOTO_FOLDER"], new_filename))
                photonam = new_filename

            conn = mysql.connect()
            cursor = conn.cursor()

            if not (postphoto == None):
                print('post photo')
                cursor.execute('CALL createImagePost(%s, %s, %s, %s)', (session['id'], content, location, photonam))
            else:
                print('no photo')
                cursor.execute('INSERT INTO post(content, time_stamp, post_location) VALUES (%s,%s,%s)', (content, datetime.datetime.now(), location))

                cursor.execute('SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1')
                postId = cursor.fetchone()[0]
                print(postId)

                cursor.execute('INSERT INTO create_post VALUES(%s, %s)', (session['id'], postId))

            conn.commit()
            cursor.close()
            conn.close()

            return redirect(url_for('home'))

        return render_template ('gen_post.html', form=form)
    return redirect (url_for('login'))



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

@app.route('/usergroup/<name>', methods=["GET", "POST"])
def usergroup(name):
    form = PostForm()

    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL getGroupId(%s)', name)
    id = cursor.fetchone()[0]

    cursor.execute('CALL getGroupPosts(%s)', int(id))
    posts = cursor.fetchall()
    print(posts)

    cursor.close()
    conn.close()
    
    return render_template('usergroup.html',form=form, posts=posts)


def isFriend(friends, userid):
    for i in friends:
        if i[0] == userid:
            return True
    return False

@app.route('/find/friends', methods=["GET", "POST"])
def find_friends():
    if 'loggedin' in session:
        form = FriendForm()
        
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute('CALL adminUserBio')
        bioData = cursor.fetchall()
        results = bioData

        cursor.close()
        conn.close()
        print(bioData)
        
        return render_template('friends.html', results=results, form=form )
    return redirect (url_for('login'))

@app.route('/add/friend/<id>', methods=["GET", "POST"])
def add_friend(id):
    if 'loggedin' in session:
        form = FriendForm()
        
        conn = mysql.connect()
        cursor = conn.cursor()

        if request.method == "POST":
            print(form.ftype.data)
            print(form)
            ftype = form.ftype.data
            cursor.execute('CALL adminGetUserBioByUname(%s)', id)
            newId = cursor.fetchone()[0]

            print('newId', newId)
            cursor.execute('call addFriend(%s, %s, %s)', (int(session['id']), newId, ftype))
            conn.commit()

        cursor.close()
        conn.close()
        
        return redirect(url_for('home'))
    return redirect (url_for('login'))


@app.route('/userpost_comment/<post_id>', methods=["GET", "POST"])
def userpost_comment(post_id):
    print("###############")
    if 'loggedin' in session:
        form = UserPost_CommentForm()
        form.content.data = request.form['content']
        print("$$$", request.form['content'])
       
        print("@@@", form.validate_on_submit())
        print("***************")
        if request.method == "POST" and form.content.data != "" :
            content_posted = form.content.data
            location = "Kingston"

            conn = mysql.connect()
            cursor = conn.cursor()
            print("comments section ****")
            cursor.execute('CALL createComment(%s,%s, %s, %s)', (int(session['id']), int(post_id), content_posted, location))
            conn.commit() 
            cursor.close()
            conn.close()

            return redirect( url_for('home'))

        return redirect(url_for('home'))
    return redirect (url_for('login'))



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
                flash('Username or password incorrect. Please try again.', 'error')          

            
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
    if session['adminLoggedIn'] == True:
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

    return redirect(url_for('admin'))


''' Admin View Groups Page '''
@app.route("/admin/groups")
def admin_groups():
    if session['adminLoggedIn'] == True:
        conn = mysql.connect()
        cursor = conn.cursor()

        cursor.execute('CALL adminGroupName')
        groupNames = cursor.fetchall()
        print(groupNames)

        cursor.execute('CALL adminGroupCreatorByUserId')
        creators = cursor.fetchall()
        print('c', creators)


        cursor.execute('CALL getGrpTotalMembers')
        grpTotals = cursor.fetchall()
        print('g', grpTotals)
        grpTotas = [0 for i in groupNames] if grpTotals == () else grpTotals

        cursor.execute('SELECT COUNT(group_id) FROM user_group')
        grpTotal = cursor.fetchone()
        print(grpTotal)

        cursor.close()
        conn.close()

        groups = zip(groupNames, creators)
        print(groups)

        stats = [
            {
                "value": grpTotal[0],
                "label": "Total Groups"
            },
            {
                "value": 1,
                "label": "Total Group Posts"
            },
        ]
        print('groups', list(groups))
        return render_template("admin/admin_group_report.html", stats=stats, groups=groups)

    return redirect(url_for('admin'))


''' Admin Groups Search Page '''
@app.route('/admin/groups/search', methods=["GET", "POST"])
def admin_search_groups():
    form = AdminSearchForm()
    if session['adminLoggedIn'] == True: 
    
        if request.method == "POST" and form.validate_on_submit():
            search_value = form.searchTerm.data

            conn = mysql.connect()
            cursor = conn.cursor()

            cursor.execute('CALL adminSearchGroup(%s)', (search_value.strip()))
            groupList = cursor.fetchall()
            #print(groupList)

            results = []
            for group in groupList:
                groupId = group[0]

                cursor.execute('CALL groupTotalPosts(%s)', int(groupId))
                groupPosts = cursor.fetchone()[0]
                print(groupPosts)

                cursor.execute('CALL groupTotalMembers(%s)', int(groupId))
                print(groupId)
                groupMembers = cursor.fetchone()[0]

                cursor.execute('CALL groupCreator(%s)', int(groupId))
                creator = cursor.fetchone()[0]
            
                results.append((group[1], creator, group[2], groupPosts, groupMembers))
                #print(results)
        
            cursor.close()
            conn.close()

            return render_template("admin/admin_search_groups.html", form=form, results=results) 

        return render_template("admin/admin_search_groups.html", form=form)
    
    return redirect(url_for('admin'))


''' Admin Search Users Page '''
@app.route("/admin/user/search", methods=["GET", "POST"])
def admin_search_users():
    form = AdminSearchForm()
    if session['adminLoggedIn'] == True:    
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

    return redirect(url_for('admin'))


def findImageIndex(postId, imageList):
    for i in range(len(imageList)):
        if (imageList[i][0] == postId):
            return i
    return - 1


def getCommentsObject(postId, commentList):
    indices = findCommentIndices(postId, commentList)

    if indices == []:
        return ""
    else:
        comments = []
        for i in indices:
            comments.append(
                {
                    "commenter": commentList[i][1],
                    "location": commentList[i][4],
                    "timestamp": commentList[i][3],
                    "text": commentList[i][2],
                }
            )
        return comments

def findCommentIndices(postId, commentList):
    indices = []
    for i in range(len(commentList)):
        if (commentList[i][0] == postId):
            indices.append(i)
    return []

''' Get User Profile Details '''
def getUserProfileDetails(username):

    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('CALL adminGetUserBioByUname(%s)', username)
    userBio = cursor.fetchall()

    cursor.execute('CALL getUserTotalPosts(%s)', int(userBio[0][0]))
    userPostCount = cursor.fetchone()[0]

    cursor.execute('CALL getUserTotalComments(%s)', int(userBio[0][0]))
    userCommentCount = cursor.fetchone()[0]

    cursor.execute('CALL numFriends(%s)', int(userBio[0][0]))
    userFriendCount = cursor.fetchone()[0]

    cursor.execute('CALL getUserTotalGroups(%s)', int(userBio[0][0]))
    userGroupCount = cursor.fetchone()[0]

    cursor.execute('CALL getUserTotalGroupPosts(%s)', int(userBio[0][0]))
    userGroupPostCount = cursor.fetchone()[0]

    userDetails = (userBio[0][1],
               (userBio[0][2] + ' ' + userBio[0][3]),
               userBio[0][4],
               userPostCount,
               userCommentCount,
               userFriendCount,
               userGroupCount,
               userGroupPostCount)

    cursor.execute('CALL adminGetUserFriends(%s)', int(userBio[0][0]))
    userFriends = cursor.fetchall()
    #print('userFriends', userFriends)

    cursor.execute('CALL adminUserGroups(%s)', int(userBio[0][0]))
    userGroups = cursor.fetchall()
    #print('userGroups', userGroups)

    cursor.execute('CALL adminGetUserPostDetails(%s)', int(userBio[0][0]))
    userPostsT = cursor.fetchall()
    #print('userPosts', userPostsT)

    cursor.execute('CALL adminGetUserGroupPostDetails(%s)', int(userBio[0][0]))
    userGroupPostsT = cursor.fetchall()
    #print('usergRP pOST', userGroupPostsT)

    cursor.execute('CALL adminGetUserPostImageDetails(%s)', int(userBio[0][0]))
    userPostImages = cursor.fetchall()
    #print('userpOST IMG', userPostImages)

    userPosts= []
    for item in userPostsT:
        imgIndex = findImageIndex(item[2], userPostImages)
        if imgIndex != -1:
            userPosts.append(
                {
                    "profile_img": item[0],
                    "poster": item[1],
                    "location": item[3],
                    "timestamp": item[4].strftime("%m/%d/%Y, %H:%M:%S"),
                    "content": item[5],
                    "image": userPostImages[imgIndex][0]
                }
            )
        else:
            userPosts.append(
                {
                    "profile_img": item[0],
                    "poster": item[1],
                    "location": item[3],
                    "timestamp": item[4].strftime("%m/%d/%Y, %H:%M:%S"),
                    "content": item[5],
                    "image": ""
                }
            )

    userGroupPosts= []
    for item in userGroupPostsT:
        imgIndex = findImageIndex(item[2], userPostImages)
        if imgIndex != -1:
            userGroupPosts.append(
                {
                    "profile_img": item[0],
                    "poster": item[1],
                    "location": item[3],
                    "timestamp": item[4].strftime("%m/%d/%Y, %H:%M:%S"),
                    "content": item[5],
                    "image": userPostImages[imgIndex][0]
                }
            )
        else:
            userGroupPosts.append(
                {
                    "profile_img": item[0],
                    "poster": item[1],
                    "location": item[3],
                    "timestamp": item[4].strftime("%m/%d/%Y, %H:%M:%S"),
                    "content": item[5],
                    "image": ""
                }
            )

    #print(userPosts)
    #print('next')
    #print(userGroupPosts)         

    profileItems = (userFriends, userGroups, userPosts, userGroupPosts)

    cursor.close()
    conn.close()

    return (userDetails, profileItems)
    

''' Admin User Profile View 1 '''
@app.route("/admin/users/profile/<username>")
def admin_user_profile(username):
    if session['adminLoggedIn'] == True: 
        details = getUserProfileDetails(username)
        userDetails = details[0]
        profileItems = (details[1][0], details[1][1])
        return render_template('admin/admin_user_profile.html', user=userDetails, profileItems=profileItems)
    return redirect(url_for('admin'))

''' Admin User Profile View 2 '''
@app.route("/admin/users/profile/2/<username>")
def admin_user_profile2(username):
    if session['adminLoggedIn'] == True: 
        details = getUserProfileDetails(username)
        userDetails = details[0]
        profileItems = (details[1][2], details[1][3])
        return render_template('admin/admin_user_profile2.html', user=userDetails, profileItems=profileItems)
    return redirect(url_for('admin'))

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
