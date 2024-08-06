import os
import pytest
from flask import Flask
from flask.testing import FlaskClient
import mysql.connector
import pandas as pd
import io
import base64

# Import your app
from your_app_module import app, fetch_from_mysql  # Adjust import based on your actual module

# Setup a test client
@pytest.fixture
def client() -> FlaskClient:
    app.config['TESTING'] = True
    client = app.test_client()
    yield client

# Mocking the fetch_from_mysql function if needed
def mock_fetch_from_mysql(stock_name):
    # Sample data to return
    sample_data = {
        'Date': ['2024-01-01', '2024-01-02'],
        'Open': [100, 102],
        'High': [105, 106],
        'Low': [95, 100],
        'Close': [102, 104],
        'AdjClose': [102, 104],
        'Volume': [1000, 1500]
    }
    df = pd.DataFrame(sample_data)
    df.set_index('Date', inplace=True)
    return df

def test_index(client: FlaskClient):
    # Replace fetch_from_mysql with the mock version
    global fetch_from_mysql
    fetch_from_mysql = mock_fetch_from_mysql
    
    response = client.get('/')
    assert response.status_code == 200
    assert b'Stock Analysis' in response.data

def test_data_analysis():
    # Testing the mock data analysis
    df = mock_fetch_from_mysql('AMZN')
    assert not df.empty
    assert 'Close' in df.columns
    assert 'MA50' not in df.columns  # Ensure analysis hasn't been applied yet
    # Perform more assertions based on the data and analysis
