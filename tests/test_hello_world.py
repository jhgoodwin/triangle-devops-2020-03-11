from flask import url_for

def test_hello_world(client):
    result = client.get(url_for('hello'))
    assert b'Hello World!' == result.data
    assert 200 == result.status_code
