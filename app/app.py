from flask import Flask, render_template, Response
import pandas as pd
import matplotlib.pyplot as plt
import mysql.connector
import io
import base64
import os
from prometheus_client import Summary, Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random

# Define Prometheus metrics
REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')
FUNCTION_CALLS = Counter('function_calls_total', 'Total number of function calls')
REQUEST_LATENCY = Histogram('request_latency_seconds', 'Histogram for the duration in seconds')
REQUEST_COUNT = Counter('http_req_total', 'HTTP Requests Total')
HTTP_ERROR_COUNT = Counter('http_error_count', 'Total HTTP error responses', ['status_code'])
EXCEPTION_COUNT = Counter('exception_count', 'Total exceptions encountered')
DATABASE_ERROR_COUNT = Counter('db_error_count', 'Total database errors')

# Define static folder for css files
STATIC_DIR = os.path.abspath('./static')

# app = Flask(__name__) # to make the app run without any
app = Flask(__name__, static_folder=STATIC_DIR)

img = io.BytesIO()

# Define the stock names
stock_names = ['AMZN', 'MSFT']  # Replace with your desired stock symbols

# Load database credentials from environment variables
def get_db_connection():
    # Increment the function calls counter
    return mysql.connector.connect(
        user='xxxxxxxx',
        password='xxxxxxxxxx',
        host='xxxxxxxxxxx',
        database='xxxxxxxxxxx',
    )

def fetch_data(stock_name):
    try:
        # Fetch data from MySQL database
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = f"""
            SELECT Date, Open, High, Low, Close, AdjClose, Volume
            FROM stock_data
            WHERE StockName = %s
            ORDER BY Date DESC
            LIMIT 100
        """
        cursor.execute(query, (stock_name,))
        rows = cursor.fetchall()

        # Convert to DataFrame
        data = pd.DataFrame(rows, columns=['Date', 'Open', 'High', 'Low', 'Close', 'AdjClose', 'Volume'])
        data.set_index('Date', inplace=True)

        cursor.close()
        conn.close()
        return data
    except mysql.connector.Error as err:
        DATABASE_ERROR_COUNT.inc()
        print(f"Database error: {err}")
        return None

def analyze_data(data,stock_name):
    # Perform stock market analysis on the data
    # Calculate 50-day moving average
    data['MA50'] = data['Close'].rolling(window=50).mean()

    # Calculate 200-day moving average
    data['MA200'] = data['Close'].rolling(window=200).mean()

    # Calculate RSI
    delta = data['Close'].diff(1)
    gain = delta.where(delta > 0, 0)
    loss = -delta.where(delta < 0, 0)
    avg_gain = gain.rolling(window=14).mean()
    avg_loss = loss.rolling(window=14).mean()
    rs = avg_gain / avg_loss
    data['RSI'] = 100 - (100 / (1 + rs))

    # Calculate MACD
    data['26ema'] = data['Close'].ewm(span=26).mean()
    data['12ema'] = data['Close'].ewm(span=12).mean()
    data['MACD'] = data['12ema'] - data['26ema']

    # Calculate Bollinger Bands
    data['20ma'] = data['Close'].rolling(window=20).mean()
    data['20sd'] = data['Close'].rolling(window=20).std()
    data['UpperBB'] = data['20ma'] + (data['20sd']*2)
    data['LowerBB'] = data['20ma'] - (data['20sd']*2)

    # Visualize the data and indicators
    plt.figure(figsize=(12,6))
    plt.plot(data['Close'], label='Close Price')
    plt.plot(data['MA50'], label='50-day MA')
    plt.plot(data['MA200'], label='200-day MA')
    plt.title('Stock Analysis for ' + stock_name)
    plt.legend()
    plt.savefig(img, format='png')
    img.seek(0)
    plot_url = base64.b64encode(img.getvalue()).decode()
    plt.close()

    # Store the data and plot URL
    stock_data = {
        'data': data[['RSI', 'MACD']].tail().to_html(),
        'plot_url': 'data:image/png;base64,{}'.format(plot_url)
    }
    return stock_data

@app.route('/')
def index():
    REQUEST_COUNT.inc()
    FUNCTION_CALLS.inc()
    start_time = time.time()
    stock_data = {}
    for stock_name in stock_names:
        data = fetch_data(stock_name)
        stock_data[stock_name] = analyze_data(data, stock_name)
    duration = time.time() - start_time
    REQUEST_LATENCY.observe(duration)
    return render_template('stock_analysis.html', stock_data=stock_data)

# Metrics endpoint
@app.route('/metrics')
def metrics():
    REQUEST_COUNT.inc()  # Increment the request count each time this endpoint is accessed
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
# Error Handling
@app.errorhandler(404)
def not_found_error(error):
    HTTP_ERROR_COUNT.labels(status_code=404).inc()
    return "404 Not Found", 404

@app.errorhandler(500)
def internal_error(error):
    HTTP_ERROR_COUNT.labels(status_code=500).inc()
    return "500 Internal Server Error", 500

@app.errorhandler(Exception)
def handle_exception(e):
    EXCEPTION_COUNT.inc()
    return "An unexpected error occurred.", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=false)
