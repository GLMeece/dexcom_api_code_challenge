"""
Utilities to check:
- Connectivity to endpoint
- Validate JSON object
"""

__version__ = "0.0.2" # Hey, you gotta start somewhere!

import json
from robot.api import logger as logging
from robot.api.deco import keyword

@keyword('Validate JSON')
def validate_json(jsonData: str) -> bool:
    """= Validates whether ``jsonData`` is actually valid JSON =

    Since Python passes the serialized data as if it were a Python dictionary,
    the single quotes (``'``) need to be converted to double quotes (``"``).

    Returns *True* if ``jsonData`` is valid JSON; elsewise returns *False*
    
    == Calling ==
    
    _An example request preceding the validation_:
    | ${resp}             GET    ${base_url}/${endpoint}
    | ${is_valid_json}    Validate JSON    ${resp.json()}
    | Should Be True      ${is_valid_json}  # Asserting that we've passed valid JSON
    """
    try:
        cleaned_json = jsonData.replace("\'", "\"")
        json.loads(cleaned_json)  # Fails if invalid JSON at this point
    except ValueError as err:
        logging.info(f"JSON Parsing Error: {err}")
        return False
    return True

@keyword('URL is Reachable')
def url_is_reachable(url: str, expected_response: Optional[int] - 200) -> bool:
    """= Verifies Specified URL Returns a Given Response Code =
    - Pass in URL and (optionally) an expected response code (if ``200`` is not anticipated)
    - Returns either *True* or *False* depending on whether route is reachable and response code is as anticipated
    
    == Calling ==
    
    | ${reachable}    URL is Reachable    https://www.google.com
    | ${reachable}    URL is Reachable    https://foobar.com/no_auth    expected_response=${401}
    """
    req_return = requests.get(url)
    return True if req_return.status_code == expected_response else False

