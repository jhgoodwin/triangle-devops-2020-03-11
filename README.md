---
theme : "default"
class : "invert"
transition: "fade"
highlightTheme: "darkula"
showNotes: false
---

# Example App

This application was written to demo different docker packaging strategies for Azure Dev Ops builds.

---

## Setup Environment

Any working python environment should work, but I'm too lazy to test every combination, so this is what I did:

---

* Windows 10 w/ WSL (Windows Subsystem for Linux)

    ```bash
    # current folder should be the project folder
    # install python 3.6
    sudo add-apt-repository ppa:jonathonf/python-3.6
    sudo apt-get update
    sudo apt-get install python3.6
    # configure pip
    wget https://bootstrap.pypa.io/get-pip.py
    sudo python3.6 get-pip.py && rm get-pip.py
    # fix bad permissions for .cache in my user folder
    chown -R $USER:$USER ~/.cache
    # install virtualenv as user module
    python3.6 -m pip install virtualenv --user
    # create virtual environment in project folder  
    python3.6 -m virtualenv -p python3.6 .venv
    # activate virtual environment
    source .venv/bin/activate
    ```

---

Note PyCharm in Windows can't use the WSL `.venv` folder unless you use the Pro version and use remote interpreter.
To work around, I just let PyCharm have its own `venv` folder next to the other one in WSL.

* PyCharm
  * Install PyCharm
  * Install Python 3.6 (if not option during PyCharm install)
  * File : Settings > Project > Project Interpreter -> (Gear Icon) -> Add
    * New Environment -> Select Python 3.6 exe location -> OK -> OK

---

* Creating the slides (assuming you have npm)

  ```bash
  npm install -g @marp-team/marp-cli
  ```

  ```bash
  marp slides.md -o slides-export/index.html
  marp README.md -o slides-export/readme.html
  ```
