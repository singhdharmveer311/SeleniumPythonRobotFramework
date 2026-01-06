"""
Custom Python library for Robot Framework
Contains utility functions and custom keywords
"""

class CustomLibrary:
    """Custom library with utility functions for Robot Framework tests."""
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    def __init__(self):
        """Initialize the custom library."""
        pass
    
    def generate_random_email(self):
        """Generate a random email address for testing purposes."""
        import random
        import string
        
        random_string = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
        return f"test_{random_string}@example.com"
    
    def generate_random_string(self, length=10):
        """Generate a random string of specified length."""
        import random
        import string
        
        return ''.join(random.choices(string.ascii_letters + string.digits, k=int(length)))
    
    def validate_email_format(self, email):
        """Validate email format using regex."""
        import re
        
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    def format_date(self, date_string, input_format='%Y-%m-%d', output_format='%d/%m/%Y'):
        """Format date from one format to another."""
        from datetime import datetime
        
        date_obj = datetime.strptime(date_string, input_format)
        return date_obj.strftime(output_format)
    
    def calculate_age(self, birth_date, date_format='%Y-%m-%d'):
        """Calculate age based on birth date."""
        from datetime import datetime
        
        birth_date_obj = datetime.strptime(birth_date, date_format)
        today = datetime.today()
        age = today.year - birth_date_obj.year
        
        if today.month < birth_date_obj.month or (today.month == birth_date_obj.month and today.day < birth_date_obj.day):
            age -= 1
            
        return age