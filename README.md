# README for API Coding Challenge

Put stuff here!

## Original Challenge Statement

**Goals:**

1. To demonstrate familiarity writing quality and robust test cases for Restful APIs.

2. To demonstrate familiarity with a real programing language (python preferred).

3. To demonstrate familiarity with software and test writing “best practices” and organization.

4. To demonstrate the ability to write “robust” test cases with good and clear error logging results.

**Code challenge:**

The Dexcom API’s “Info Endpoint” needs test automation! Create an automated test suite that tests the following:

1. Verify that the endpoint responds with a 200 HTTP response status.

2. Verify that the Content-Type header is returned as a valid json media type.

3. From the list of items returned, find the item with the "Product Name" of "Dexcom API" and verify it has the following fields and values:
   1. "UDI / Device Identifier" is "00386270000668"
   2. ”Version" is "3.1.0.0"
   3. "Part Number (PN)" is "350-0019"
   4. Verify that the “Dexcom API” Sub-Components array includes an item with the a “name” of "api-gateway".
   5. Verify that the “Dexcom API” Sub-Components array includes an item with the a “name” of "insulin-service".

4. Verify that the Content-Type header is returned as a valid xml media type.
    Hint: Some test cases might fail**

5. Run the test cases against https://api.dexcom.com

6. Run the test cases against https://sandbox-api.dexcom.com/

7. Commit your code to github and share the link with us.

8. Be ready to walk through your code challenge with the team!

**Base URL:** [**https://api.dexcom.com**](https://api.dexcom.com)

**Endpoint: /info**

**Bonus:**

1. Use the RobotFramework as a test runner and write and import a custom RobotFramework keyword in python and use it in you test!
   Or…
   Use PyTest as the test runner and create a custom python module to use inside of your test cases.

2. Parameterize the test case variables or setup.

---

## Project Setup

This project utilizes Python and (Python-based) Robot Framework. As such, at minimum you will need:

- [Python](https://www.python.org/downloads/) - version 3.9 or later. **Note**: you may wish to use a Python version management system such as [PyEnv](https://github.com/pyenv/pyenv#simple-python-version-management-pyenv) if your OS supports it (it can address downloading/installing any version of Python you wish).
- The ability to create virtual environments ([here's a good primer](https://realpython.com/python-virtual-environments-a-primer/), or if you use PyEnv [see this section](https://realpython.com/intro-to-pyenv/#virtual-environments-and-pyenv)).
- [Git](https://git-scm.com/downloads) - to clone _this_ repository.
- A terminal such as [Terminal](https://support.apple.com/guide/terminal/welcome/mac) (or [iTerm2](https://iterm2.com/)) on macOS or [PowerShell](https://learn.microsoft.com/en-us/powershell/) on Windows. Examples will assume the macOS Terminal.

### Cloning

In a terminal, execute the following:

```bash
git clone https://github.com/GLMeece/dexcom_api_code_challenge.git
```

## Executing

With a terminal (as indicated above):

1. `cd` into the root of this repository.
2. Execute: `robot -V Environment/prod.yaml -L TRACE -d Results -W -120 -T Tests`

**Note**: Change the YAML filename to `sandbox.yaml` to execute against the Sandbox URL.

## Notes

- From all I could tell, the API does not return a media type of XML, regardless of the request header indicating `Accept: application/xml` and `Content-Type: application/xml`. The return header always indicates `Content-Type: application/json`. Thus, the test case expecting a valid XML media type returned will always fail.
- I considered using the [RESTinstance library](https://pypi.org/project/RESTinstance/) instead of the more typically used [RequestsLibrary](https://github.com/MarketSquare/robotframework-requests#readme). However, some of the paradigms are a bit different than I'm used to, so I decided to defer learning this library to another time.
