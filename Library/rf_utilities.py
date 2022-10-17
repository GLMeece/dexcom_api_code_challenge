import json
from robot.api import logger as logging


def validate_json(jsonData: str) -> bool:
    """Validates whether ``jsonData`` is actually valid JSON

    Since Python passes the serialized data as if it were a Python dictionary,
    the single quotes (``'``) need to be converted to double quotes (``"``).

    Returns *True* if ``jsonData`` is valid JSON; elsewise returns *False*
    """
    try:
        cleaned_json = jsonData.replace("\'", "\"")
        json.loads(cleaned_json)  # Fails if invalid JSON at this point
    except ValueError as err:
        logging.info(f"JSON Parsing Error: {err}")
        return False
    return True
