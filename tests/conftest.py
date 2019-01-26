import pytest
import app as hello_app

@pytest.fixture
def app():
    app = hello_app.create()
    app.debug = True
    return app