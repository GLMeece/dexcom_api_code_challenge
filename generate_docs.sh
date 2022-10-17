#!/bin/zsh
# Generate Test Suite documentation:
python -m robot.testdoc Tests Docs/Info_Endpoint.html
# Generate Library and Resource documentation:
libdoc Library/http_utilities.py Docs/HTTP_Utilities.html
libdoc Resources/Gherkin.resource Docs/Gherkin_Resources.html
