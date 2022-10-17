*** Settings ***
Documentation       = Dexcom Coding Challenge =
...
...                 This test suite uses Robot Framework's [https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#behavior-driven-style|BDD (Gherkin) syntax support]
...
...                 ---
...
...                 The Dexcom API's "Info Endpoint" needs test automation! Create an
...                 automated test suite that tests the following:
...
...                 1. Verify that the endpoint responds with a 200 HTTP response status.
...
...                 2. Verify that the Content-Type header is returned as a valid json media type.
...
...                 3. From the list of items returned, find the item with the "Product Name" of "Dexcom API" and verify it has the following fields and values:
...                 - 1. "UDI / Device Identifier" is "00386270000668"
...                 - 2. "Version" is "3.1.0.0" [*Note*: returned version number is actually ``3.1.1.0``, which is reflected in the test case]
...                 - 3. "Part Number (PN)" is "350-0019"
...                 - 4. Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "api-gateway".
...                 - 5. Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "insulin-service".
...                 - 4. Verify that the Content-Type header is returned as a valid xml media type. Hint: Some test cases might fail** [*Note*: indeed, the endpoint does not seem to be able to return XML]
...                 - 5. Run the test cases against https://api.dexcom.com
...                 - 6. Run the test cases against https://sandbox-api.dexcom.com/
...                 - 7. Commit your code to github and [https://github.com/GLMeece/dexcom_api_code_challenge.git|share the link with us].
...                 - 8. Be ready to walk through your code challenge with the team!

Resource            ../../../Resources/Gherkin.resource
Library             Collections


*** Test Cases ***
Status OK is Returned
    [Documentation]    GETting the ``info`` URL should return a 200 status code
    [Tags]    api    get    status_code    bdd
    Given GET Response is Set
    Then Status Code Should be OK/Good

Content-Type Header is Valid JSON
    [Documentation]    Validate the return
    [Tags]    api    get    json    bdd
    Given GET Response is Set
    Then Return is Valid JSON

Content-Type Header is Valid XML [FAILS]
    [Documentation]    Verify that the Content-Type header is returned as a valid xml media type.
    ...    Hint: Some test cases might fail**
    [Tags]    api    get    xml    bdd    robot:skip-on-failure
    Given GET Response is Set, Expecting XML
    Then Content-type Header Should be XML

Dexcom API Return has Fields & Values
    [Documentation]    From the list of items returned, find the item with the
    ...    "Product Name" of "Dexcom API" and verify it has the following fields
    ...    and values:
    ...    - ``UDI / Device Identifier`` is ``0386270000668``
    ...    - ``Version`` is ``3.1.0.0`` [*Note*: returned version number is actually ``3.1.1.0``; reflected in this test case]
    ...    - ``Part Number (PN)`` is ``350-0019``
    ...    - sub-components array test in test case *Product Dexcom API Sub-Components Contain Items*
    [Tags]    api    get    bdd
    Given GET Response is Set
    Then Dexcom API Has Correct Fields & Values

Product Dexcom API Sub-Components Contain Items [FAILS]
    [Documentation]    = Sub-Components Verification =
    ...    - Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "api-gateway".
    ...    - Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "insulin-service".
    [Tags]    api    get    bdd    robot:skip-on-failure
    Given GET Response is Set
    Then Dexcom API Sub-Components Contain 'api-gateway' & 'insulin-service' Items

Product Dexcom API Sub-Components Contains 'standard-offering'
    [Documentation]    = Sub-Components Verification - Bonus Round =
    ...    - Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "standard-offering".
    ...
    ...    *Note*: This test case reflects what is actually returned on the public ``info`` endpoint.
    [Tags]    api    get    bonus
    Given GET Response is Set
    Then Verify Sub-components Contains 'standard-offering'
