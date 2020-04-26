from flask import render_template, request, url_for ,redirect,flash,jsonify, g, session
from flask_login import login_user, logout_user, current_user, login_required
from werkzeug.utils import secure_filename
import os
import datetime
import jwt
from functools import wraps
from flask_mysqldb import MySQL
import yaml



"""  Routes START HERE  """

@app.route('/')
def index():
    """Render website's initial page and let VueJS take over."""
    return render_template('index.html')



""" 
@app.route("/api/users/register",methods=["POST"])
def register():

    return render_template('html')



@app.route("/api/auth/login", methods=["POST"])
def login():
    return 1



@app.route("/api/auth/logout",methods=["GET"])
@requires_auth
def logout():

    return 1 """












@app.after_request
def add_header(response):

    response.headers['X-UA-Compatible'] = 'IE=Edge,chrome=1'
    response.headers['Cache-Control'] = 'public, max-age=0'
    return response


@app.errorhandler(404)
def page_not_found(error):
    """Custom 404 page."""
    return render_template('404.html'), 404


if __name__ == '__main__':
    app.run(debug=True)
