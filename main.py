from flask import Flask, request, render_template
from diskcache import Cache
import requests
import time

# Flask app setup
app = Flask(__name__)

# Diskcache setup
CACHE = Cache(".cache")
CACHE_EXPIRATION = 300  # 5 minutes

# Fetch temperature function
def fetch_temperature(city):
    city = city.strip().lower()
    current_time = time.time()

    # Check cache
    if city in CACHE:
        temp, timestamp = CACHE[city]
        if current_time - timestamp < CACHE_EXPIRATION:
            return temp, True

    # Fetch from API
    url = f"https://wttr.in/{city}?format=%t"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            temp = response.text.strip()
            CACHE[city] = (temp, current_time)  # Update cache
            return temp, False
        else:
            return "Error fetching weather data", False
    except Exception as e:
        return f"Error: {e}", False

# Routes
@app.route("/", methods=["GET", "POST"])
def index():
    temperature = None
    cached = False
    if request.method == "POST":
        city = request.form.get("city")
        if city:
            temperature, cached = fetch_temperature(city)

    return render_template("index.html", temperature=temperature, cached=cached)

# Run the Flask app
if __name__ == "__main__":
    app.run()
