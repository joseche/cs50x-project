from flask import Flask, render_template
import logging
from apod import utility


LOG = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)


app = Flask(__name__, template_folder="templates")


@app.route("/")
def main():
    # timestamp = 1330215987
    # date_time = datetime.fromtimestamp(timestamp)
    # utility.parse_apod(dt=date_time, use_default_today_date=False)
    utility.initialize()
    return render_template("main.html.j2")
