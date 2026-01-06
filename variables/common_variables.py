"""
Common variables for Robot Framework tests
"""

# Browser settings
BROWSER_CHROME = "chrome"
BROWSER_FIREFOX = "firefox"
BROWSER_EDGE = "edge"

# URLs
BASE_URL = "https://example.com"
GOOGLE_URL = "https://www.google.com"

# Test data
TEST_USERNAME = "testuser"
TEST_PASSWORD = "testpassword"
TEST_EMAIL = "test@example.com"

# Timeouts (in seconds)
SHORT_TIMEOUT = 5
MEDIUM_TIMEOUT = 10
LONG_TIMEOUT = 30

# Common test data
SEARCH_TERMS = [
    "Robot Framework",
    "Selenium WebDriver", 
    "Test Automation"
]

USER_DATA = {
    "username": "john_doe",
    "password": "secure123",
    "email": "john.doe@example.com",
    "first_name": "John",
    "last_name": "Doe"
}