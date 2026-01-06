# Enterprise Payments Testing Framework

A comprehensive enterprise-level test automation framework built with Robot Framework, Selenium WebDriver, and Python specifically designed for payment system testing. Supports credit card processing, digital wallets, bank transfers, payment gateways, and compliance validation.

## 🚀 Project Structure

```
SeleniumPythonRobotFramework/
├── README.md                   # Project documentation
├── requirements.txt            # Python dependencies
├── Makefile                    # Automation commands
├── test.py                     # Original test file
├── .vscode/                    # VS Code configuration
│   └── settings.json
├── config/                     # Configuration files
│   ├── robot.conf             # Robot Framework config
│   ├── test_config.ini        # Test environment config
│   └── setup.cfg              # Python tools config
├── tests/                      # Test suites
│   ├── sample_web_tests.robot # Web UI test examples
│   └── api_tests.robot        # API test examples
├── resources/                  # Shared resources
│   └── common.robot           # Common keywords and setup
├── keywords/                   # Custom keyword libraries
│   └── common_keywords.robot  # Reusable keywords
├── variables/                  # Variable definitions
│   └── common_variables.py    # Common test variables
├── libraries/                  # Custom Python libraries
│   └── CustomLibrary.py       # Utility functions
└── results/                    # Test execution results
```

## 🛠 Setup Instructions

### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)

### Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd SeleniumPythonRobotFramework
   ```

2. **Set up virtual environment and install dependencies:**
   ```bash
   make setup
   ```

3. **Activate the virtual environment:**
   ```bash
   source .venv/bin/activate
   ```

4. **Run sample tests:**
   ```bash
   make test-smoke
   ```

### Manual Setup

1. **Create virtual environment:**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## 🧪 Running Tests

### Using Makefile (Recommended)
```bash
# Run all tests
make test

# Run smoke tests only
make test-smoke

# Run API tests only
make test-api

# Run web tests only
make test-web

# Clean test results
make clean
```

### Using Robot Framework directly
```bash
# Run all tests
robot --outputdir results tests/

# Run specific test file
robot --outputdir results tests/sample_web_tests.robot

# Run tests with specific tags
robot --outputdir results --include smoke tests/

# Run tests in parallel
pabot --processes 4 --outputdir results tests/
```

## 📋 Available Test Tags

- `smoke` - Quick smoke tests for basic functionality
- `web` - Web UI tests using Selenium
- `api` - API tests using RequestsLibrary
- `forms` - Form interaction tests

## 🔧 Configuration

### Browser Configuration
Modify browser settings in [variables/common_variables.py](variables/common_variables.py):
```python
BROWSER_CHROME = "chrome"
BROWSER_FIREFOX = "firefox"
BROWSER_EDGE = "edge"
```

### Environment Configuration
Update test environments in [config/test_config.ini](config/test_config.ini) for different environments (dev, staging, production).

### Robot Framework Settings
Global Robot Framework settings can be configured in [config/robot.conf](config/robot.conf).

## 📦 Key Dependencies

- **robotframework** - Core test automation framework
- **robotframework-seleniumlibrary** - Web UI testing library
- **robotframework-requests** - API testing library
- **selenium** - WebDriver for browser automation
- **robotframework-pabot** - Parallel test execution

## 🎯 Sample Test Examples

### Web UI Test
```robot
*** Test Cases ***
Sample Web Test - Google Search
    [Tags]    smoke    web
    Navigate To Google
    Search For Text    Robot Framework
    Verify Search Results
```

### API Test
```robot
*** Test Cases ***
GET Request Test
    [Tags]    api
    Create Session    jsonplaceholder    ${API_BASE_URL}
    ${response}=    GET On Session    jsonplaceholder    /users/1
    Should Be Equal As Strings    ${response.status_code}    200
```

## 🛡️ Best Practices

1. **Page Object Pattern**: Use resource files for page-specific keywords
2. **Data-Driven Testing**: Store test data in variables files
3. **Reusable Keywords**: Create common keywords in the keywords/ directory
4. **Environment Management**: Use configuration files for different environments
5. **Parallel Execution**: Use pabot for faster test execution
6. **Reporting**: Generate detailed HTML reports with screenshots

## 📊 Test Reporting

Test results are generated in the `results/` directory:
- `log.html` - Detailed test execution log
- `report.html` - High-level test report
- `output.xml` - Raw test results in XML format

## 🔍 Troubleshooting

### Common Issues

1. **WebDriver Issues**: Ensure correct browser drivers are installed
2. **Import Errors**: Check Python path settings in VS Code
3. **Test Failures**: Check screenshot captures in results directory

### Useful Commands
```bash
# Check Robot Framework version
robot --version

# Validate test syntax
robot --dryrun tests/sample_web_tests.robot

# Generate keyword documentation
python -m robot.libdoc SeleniumLibrary docs/SeleniumLibrary.html
```

## 🤝 Contributing

1. Follow Robot Framework coding conventions
2. Add appropriate test tags
3. Update documentation for new features
4. Run smoke tests before committing

## 📝 License

This project is set up for educational and testing purposes. Modify as needed for your specific use case.
