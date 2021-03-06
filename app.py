from flask import Flask, jsonify, request, make_response, request, current_app
from functools import update_wrapper
from datetime import timedelta

from enum import Enum
from neuralstyle import main
from multiprocessing import Pool

class Filter(Enum):
    VAN_GOGH = 0
    HACKILLINOIS = 1
    COLORFUL = 2

pool = None

app = Flask(__name__)

def crossdomain(origin=None, methods=None, headers=None,
                max_age=21600, attach_to_all=True,
                automatic_options=True):
    if methods is not None:
        methods = ', '.join(sorted(x.upper() for x in methods))
    if headers is not None and not isinstance(headers, basestring):
        headers = ', '.join(x.upper() for x in headers)
    if not isinstance(origin, basestring):
        origin = ', '.join(origin)
    if isinstance(max_age, timedelta):
        max_age = max_age.total_seconds()

    def get_methods():
        if methods is not None:
            return methods

        options_resp = current_app.make_default_options_response()
        return options_resp.headers['allow']

    def decorator(f):
        def wrapped_function(*args, **kwargs):
            if automatic_options and request.method == 'OPTIONS':
                resp = current_app.make_default_options_response()
            else:
                resp = make_response(f(*args, **kwargs))
            if not attach_to_all and request.method != 'OPTIONS':
                return resp

            h = resp.headers

            h['Access-Control-Allow-Origin'] = origin
            h['Access-Control-Allow-Methods'] = get_methods()
            h['Access-Control-Max-Age'] = str(max_age)
            if headers is not None:
                h['Access-Control-Allow-Headers'] = headers
            return resp

        f.provide_automatic_options = False
        f.required_methods = ['OPTIONS']
        return update_wrapper(wrapped_function, f)
    return decorator

@app.route('/start', methods=['POST'])
@crossdomain(origin='*')
def start():
    base64_image = request.form['image']
    style = request.form['style']
    email = request.form['email']


    fh = open("image.jpg", "wb")
    fh.write(base64_image.decode('base64'))
    fh.close()

    message = {'hi tommy': ''}
    path = ""

    if style == Filter.VAN_GOGH:
        path = "van.jpg"
        message = {'hi tommy': 'we good'}
    elif style == Filter.HACKILLINOIS:
        path = "hi.jpg"
        message = {'hi tommy': 'we good'}
    elif style == Filter.COLORFUL:
        path = "c.jpg"
        message = {'hi tommy': 'we good'}
    else:
        message = {'hi tommy': 'we died'}

    pool.apply_async(neuralstyle,[path], mail, [email])

    return jsonify(message=message)

if __name__ == '__main__':
    global pool
    pool = Pool(processes=1)
    app.run(host='0.0.0.0')
