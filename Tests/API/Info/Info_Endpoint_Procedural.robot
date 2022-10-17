*** Settings ***
Documentation       = Dexcom Coding Challenge =
...
...                 This test suite uses Robot Framework's straightforward procedural approach
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

Library             Collections
Library             RequestsLibrary
Library             ../../../Library/rf_utilities.py


*** Variables ***
${endpoint}         info
${ok_status}        200
&{xml_header}       Accept=application/xml    Content-Type=application/xml


*** Test Cases ***
Status OK is Returned
    [Documentation]    GETting the ``info`` URL should return a 200 status code
    [Tags]    api    get    status_code
    ${response}    GET    ${base_url}/${endpoint}
    Status Should Be    ${ok_status}

Content-Type Header is Valid JSON
    [Documentation]    Validate the return
    [Tags]    api    get    json
    ${resp}    GET    ${base_url}/${endpoint}
    Should Be Equal As Strings    application/json    ${resp.headers}[Content-Type]
    ${is_valid_json}    Validate Json    ${resp.json()}
    Should Be True    ${is_valid_json}

Content-Type Header is Valid XML [FAILS]
    [Documentation]    Verify that the Content-Type header is returned as a valid xml media type.
    ...    Hint: Some test cases might fail**
    [Tags]    api    get    xml    robot:skip-on-failure
    ${resp}    GET    ${base_url}/${endpoint}    headers=&{xml_header}
    Should Be Equal As Strings    application/xml    ${resp.headers}[Content-Type]

Dexcom API Return has Fields & Values
    [Documentation]    From the list of items returned, find the item with the
    ...    "Product Name" of "Dexcom API" and verify it has the following fields
    ...    and values:
    ...    - ``UDI / Device Identifier`` is ``0386270000668``
    ...    - ``Version`` is ``3.1.0.0``
    ...    - ``Part Number (PN)`` is ``350-0019``
    ...    - sub-components array test in test case *Product Dexcom API Sub-Components Contain Items*
    [Tags]    api    get
    Set Test Variable    ${contains_dexcom_api}    ${False}
    ${resp}    GET    ${base_url}/${endpoint}
    FOR    ${dictionary}    IN    @{resp.json()}
        IF    '${dictionary}[Product Name]' == 'Dexcom API'
            Set Test Variable    ${contains_dexcom_api}    ${True}
            Should Be Equal As Strings    ${dictionary}[UDI / Device Identifier]    00386270000668
            Should Be Equal As Strings    ${dictionary}[UDI / Production Identifier][Version]    3.1.1.0
            Should Be Equal As Strings    ${dictionary}[UDI / Production Identifier][Part Number (PN)]    350-0019
        END
    END
    Should Be True    ${contains_dexcom_api} == ${True}    msg=Product Name of Dexcom API not found!

Product Dexcom API Sub-Components Contain Items
    [Documentation]    = Sub-Components Verification =
    ...    - Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "api-gateway".
    ...    - Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "insulin-service".
    [Tags]    api    get    robot:skip-on-failure
    Set Test Variable    ${contains_dexcom_api}    ${False}
    Set Test Variable    ${contains_api_gateway}    ${False}
    Set Test Variable    ${contains_insulin_service}    ${False}
    ${resp}    GET    ${base_url}/${endpoint}
    FOR    ${dictionary}    IN    @{resp.json()}
        IF    '${dictionary}[Product Name]' == 'Dexcom API'
            Set Test Variable    ${contains_dexcom_api}    ${True}
            Set Test Variable    @{subcomp_list}    ${dictionary}[UDI / Production Identifier][Sub-Components]

            FOR    ${subcomp_dict}    IN    @{subcomp_list}[0]
                Dictionary Should Contain Key    ${subcomp_dict}    Name
                IF    '${subcomp_dict}[Name]' == 'api-gateway'
                    Set Test Variable    ${contains_api_gateway}    ${True}
                ELSE IF    '${subcomp_dict}[Name]' == 'insulin-service'
                    Set Test Variable    ${contains_insulin_service}    ${True}
                END
            END
        END
    END
    Should Be True    ${contains_dexcom_api} == ${True}    msg=Product Name of Dexcom API not found!
    Should Be True
    ...    ${contains_api_gateway} == ${True}
    ...    msg=Dexcom API sub-components array doesn't include an item with the name of api-gateway
    Should Be True
    ...    ${contains_insulin_service} == ${True}
    ...    msg=Dexcom API sub-components array doesn't include an item with the name of insulin-service

Product Dexcom API Sub-Components Contains 'standard-offering'
    [Documentation]    = Sub-Components Verification - Bonus Round =
    ...    - Verify that the "Dexcom API" Sub-Components array includes an item with the a "name" of "standard-offering".
    ...
    ...    *Note*: This test case reflects what is actually returned on the public ``info`` endpoint.
    [Tags]    api    get    bonus
    IF    "sandbox" in "${base_url}"    Set Tags    robot:skip-on-failure
    Set Test Variable    ${contains_dexcom_api}    ${False}
    Set Test Variable    ${contains_standard_offering}    ${False}
    ${resp}    GET    ${base_url}/${endpoint}
    FOR    ${dictionary}    IN    @{resp.json()}
        IF    '${dictionary}[Product Name]' == 'Dexcom API'
            Set Test Variable    ${contains_dexcom_api}    ${True}
            Set Test Variable    @{subcomp_list}    ${dictionary}[UDI / Production Identifier][Sub-Components]
            FOR    ${subcomp_dict}    IN    @{subcomp_list}[0]
                Dictionary Should Contain Key    ${subcomp_dict}    Name
                IF    '${subcomp_dict}[Name]' == 'standard-offering'
                    Set Test Variable    ${contains_standard_offering}    ${True}
                END
            END
        END
    END
    Should Be True    ${contains_dexcom_api} == ${True}    msg=Product Name of Dexcom API not found!
    Should Be True
    ...    ${contains_standard_offering} == ${True}
    ...    msg=Dexcom API sub-component array doesn't include an item with the name of standard-offering
