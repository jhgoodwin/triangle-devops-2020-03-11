from flask import Flask

def create():
    app = Flask(__name__)

    @app.route('/')
    def hello():
        return "Hello World!"

    return app

if __name__ == '__main__':
    app = create()
    app.run(host="0.0.0.0")