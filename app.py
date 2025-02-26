try:
    from flask import Flask
except ImportError:
    print("Flask is not installed. Please install it by running 'pip install flask'")
    exit(1)

app = Flask(__name__)

@app.route('/')
def index():
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to prodxcloud</title>
    </head>
    <body>
        <h1>Testing changes</h1>
        <p>Welcome to the simple Python web server 2.0 .</p>
    </body>
    </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)