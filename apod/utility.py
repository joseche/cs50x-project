import contextlib
from bs4 import BeautifulSoup
import datetime
import requests
import logging
import json
import re
import urllib3

LOG = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)

# location of backing APOD service
BASE = "https://apod.nasa.gov/apod/"

# Create urllib3 Pool Manager
http = urllib3.PoolManager()


# function that returns only last URL if there are multiple
# URLs stacked together
def _get_last_url(data):
    regex = re.compile("(?:.(?!http[s]?://))+$")
    return regex.findall(data)[0]


def _get_apod_chars(dt):
    media_type = "image"
    if dt:
        date_str = dt.strftime("%y%m%d")
        apod_url = f"{BASE}ap{date_str}.html"
    else:
        apod_url = "{BASE}astropix.html"
    LOG.debug(f"OPENING URL:{apod_url}")
    res = requests.get(apod_url)

    if res.status_code == 404:
        return None

    soup = BeautifulSoup(res.text, "html.parser")
    LOG.debug("getting the data url")
    hd_data = None
    if soup.img:
        # it is an image, so get both the low- and high-resolution data
        data = BASE + soup.img["src"]
        hd_data = data

        LOG.debug("getting the link for hd_data")
        for link in soup.find_all("a", href=True):
            if link["href"] and link["href"].startswith("image"):
                hd_data = BASE + link["href"]
                break
    elif soup.iframe:
        # its a video
        media_type = "video"
        data = soup.iframe["src"]
    else:
        # it is neither image nor video, output empty urls
        media_type = "other"
        data = ""

    props = {"explanation": _explanation(soup), "title": _title(soup)}
    if copyright_text := _copyright(soup):
        props["copyright"] = copyright_text
    props["media_type"] = media_type
    if data:
        props["url"] = _get_last_url(data)
    props["date"] = dt.strftime("%Y-%m-%d") if dt else _date(soup)
    if hd_data:
        props["hdurl"] = _get_last_url(hd_data)

    return props


def _title(
    soup,
):  # sourcery skip: hoist-similar-statement-from-if, hoist-statement-from-if
    """
    Accepts a BeautifulSoup object for the APOD HTML page and returns the
    APOD image title.  Highly idiosyncratic with adaptations for different
    HTML structures that appear over time.
    """
    LOG.debug("getting the title")
    try:
        # Handler for later APOD entries
        number_of_center_elements = len(soup.find_all("center"))
        if number_of_center_elements == 2:
            center_selection = soup.find_all("center")[0]
            bold_selection = center_selection.find_all("b")[0]
            title = bold_selection.text.strip(" ")
            try:
                title = title.encode("latin1").decode("cp1252")
            except Exception as ex:
                LOG.error(str(ex))
        else:
            center_selection = soup.find_all("center")[1]
            bold_selection = center_selection.find_all("b")[0]
            title = bold_selection.text.strip(" ")
            try:
                title = title.encode("latin1").decode("cp1252")
            except Exception as ex:
                LOG.error(str(ex))

        return title
    except Exception:
        # Handler for early APOD entries
        text = soup.title.text.split(" - ")[-1]
        title = text.strip()
        try:
            title = title.encode("latin1").decode("cp1252")
        except Exception as ex:
            LOG.error(str(ex))

        return title


def _copyright(soup):
    """
    Accepts a BeautifulSoup object for the APOD HTML page and returns the
    APOD image copyright.  Highly idiosyncratic with adaptations for different
    HTML structures that appear over time.
    """
    LOG.debug("getting the copyright")
    try:
        # Handler for later APOD entries
        # There's no uniform handling of copyright (sigh). Well, we just have to
        # try every stinking text block we find...

        copyright_text = None
        use_next = False
        for element in soup.findAll("a", text=True):
            if use_next:
                copyright_text = element.text.strip(" ")
                break
            if "Copyright" in element.text:
                LOG.debug(f"Found Copyright text:{str(element.text)}")
                use_next = True
        if not copyright_text:
            for element in soup.findAll(["b", "a"], text=True):
                # search text for explicit match
                if "Copyright" in element.text:
                    LOG.debug(f"Found Copyright text:{str(element.text)}")
                    # pull the copyright from the link text which follows
                    sibling = element.next_sibling
                    stuff = ""
                    while sibling:
                        with contextlib.suppress(Exception):
                            stuff = stuff + sibling.text
                        sibling = sibling.next_sibling
                    if stuff:
                        copyright_text = stuff.strip(" ")
        try:
            if copyright_text:
                copyright_text = copyright_text.encode("latin1").decode(
                    "cp1252"
                )
        except Exception as ex:
            LOG.error(str(ex))
        return copyright_text

    except Exception as ex:
        LOG.error(str(ex))
        raise ValueError("Unsupported schema for given date.") from ex


def _explanation(soup):
    """
    Accepts a BeautifulSoup object for the APOD HTML page and returns the
    APOD image explanation.  Highly idiosyncratic.
    """
    # Handler for later APOD entries
    LOG.debug("getting the explanation")
    s = soup.find_all("p")[2].text
    s = s.replace("\n", " ")
    s = s.replace("  ", " ")
    s = s.strip(" ").strip("Explanation: ")
    s = s.split(" Tomorrow's picture")[0]
    s = s.strip(" ")
    if s == "":
        # Handler for earlier APOD entries
        texts = [x.strip() for x in soup.text.split("\n")]
        try:
            begin_idx = texts.index("Explanation:") + 1
        except ValueError as e:
            # Rare case where "Explanation:" is not on its own line
            explanation_line = [x for x in texts if "Explanation:" in x]
            if len(explanation_line) != 1:
                raise e

            begin_idx = texts.index(explanation_line[0])
            texts[begin_idx] = texts[begin_idx][12:].strip()
        idx = texts[begin_idx:].index("")
        s = " ".join(texts[begin_idx : begin_idx + idx])

    try:
        s = s.encode("latin1").decode("cp1252")
    except Exception as ex:
        LOG.error(str(ex))

    return s


def _date(soup):
    """
    Accepts a BeautifulSoup object for the APOD HTML page and returns the
    date of the APOD image.
    """
    LOG.debug("getting the date from soup data.")
    _today = datetime.date.today()
    for line in soup.text.split("\n"):
        today_year = str(_today.year)
        yesterday_year = str((_today - datetime.timedelta(days=1)).year)
        # Looks for the first line that starts with the current year.
        # This also checks yesterday's year so it doesn't break on January 1st at 00:00 UTC
        # before apod.nasa.gov uploads a new image.
        if line.startswith(today_year) or line.startswith(yesterday_year):
            LOG.debug(f"found possible date match: {line}")
            # takes apart the date string and turns it into a datetime
            try:
                year, month, day = line.split()
                year = int(year)
                month = [
                    "january",
                    "february",
                    "march",
                    "april",
                    "may",
                    "june",
                    "july",
                    "august",
                    "september",
                    "october",
                    "november",
                    "december",
                ].index(month.lower()) + 1
                day = int(day)
                return datetime.date(year=year, month=month, day=day).strftime(
                    "%Y-%m-%d"
                )
            except Exception:
                LOG.debug(f"unable to retrieve date from line: {line}")
    # sourcery skip: raise-specific-error
    raise Exception("Date not found in soup data.")


def parse_apod(dt, use_default_today_date=False):
    """
    Accepts a date in '%Y-%m-%d' format. Returns the URL of the APOD image
    of that day, noting that
    """

    LOG.debug(f"apod chars called date:{str(dt)}")

    try:
        return _get_apod_chars(dt)

    except Exception as ex:

        # handle edge case where the service local time
        # miss-matches with 'todays date' of the underlying APOD
        # service (can happen because they are deployed in different
        # timezones). Use the fallback of prior day's date

        if use_default_today_date and dt:
            # try to get the day before
            dt = dt - datetime.timedelta(days=1)
            return _get_apod_chars(dt)
        else:
            # pass exception up the call stack
            LOG.error(str(ex))
            # sourcery skip: raise-specific-error
            raise Exception(ex) from ex


def initialize():
    pass  # TODO: load db, if db empty, fill with data,
    # from current month backwards
