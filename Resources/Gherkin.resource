*** Settings ***
Documentation       This resource file contains keywords and variables for BDD/Gherkin syntax

Library             Collections
Library             RequestsLibrary
Library             ../Library/http_utilities.py


*** Variables ***
${endpoint}         info
&{xml_header}       Accept=application/xml    Content-Type=application/xml


*** Keywords ***
Endpoint is Reachable
    [Documentation]    Calls ``URL is Reachable`` to determine if URL can be
    ...    routed to.
    ${reachable}    URL is Reachable    ${base_url}/${endpoint}
    Should Be True    ${reachable}

GET Response is Set
    [Documentation]    Verify that response is returned from GET request
    [Arguments]    ${header_val}=${None}
    Set Suite Variable
    ...    &{json_accept_content}
    ...    Accept=application/json
    ...    Content-Type=application/json
    IF    ${header_val}
        ${response}    GET    ${base_url}/${endpoint}    headers=${header_val}
    ELSE
        ${response}    GET    ${base_url}/${endpoint}    headers=&{json_accept_content}
    END
    Set Test Variable    ${resp}    ${response}

Status Code Should be OK/Good
    [Documentation]    Evalutes return code - should be OK/200
    Status Should Be    200

Return is Valid JSON
    [Documentation]    Validates that returned body is valid JSON
    Should Be Equal As Strings    application/json    ${resp.headers}[Content-Type]
    ${is_valid_json}    Validate Json    ${resp.json()}
    Should Be True    ${is_valid_json}

GET Response is Set, Expecting XML
    [Documentation]    Perform GET call, expecting XML to be returned
    &{xml_header}    Create Dictionary    Accept    application/xml    Content-Type    application/xml
    ${response}    GET    ${base_url}/${endpoint}    headers=&{xml_header}
    Set Test Variable    ${resp}    ${response}

Content-type Header Should be XML
    [Documentation]    Response header should have a *Content-Type* of
    ...    ``application/xml``
    Should Be Equal As Strings    ${resp.headers}[Content-Type]    application/xml

Dexcom API Has Correct Fields & Values
    [Documentation]    Response should have:
    ...
    ...    - A *[Product Name]* of _Dexcom API_
    ...    - A *[UDI / Device Identifier]* of _00386270000668_
    ...    - A *[UDI / Production Identifier][Version]* of _3.1.1.0_ (revised from originally-stated _3.1.0.0_)
    ...    - A *[UDI / Production Identifier][Part Number (PN)]* of _350-0019_
    Set Test Variable    ${contains_dexcom_api}    ${False}
    FOR    ${dictionary}    IN    @{resp.json()}
        IF    '${dictionary}[Product Name]' == 'Dexcom API'
            Set Test Variable    ${contains_dexcom_api}    ${True}
            Should Be Equal As Strings    ${dictionary}[UDI / Device Identifier]    00386270000668
            Should Be Equal As Strings    ${dictionary}[UDI / Production Identifier][Version]    3.1.1.0
            Should Be Equal As Strings    ${dictionary}[UDI / Production Identifier][Part Number (PN)]    350-0019
        END
    END
    Should Be True    ${contains_dexcom_api} == ${True}    msg=Product Name of Dexcom API not found!

Dexcom API Sub-Components Contain 'api-gateway' & 'insulin-service' Items
    [Documentation]    Verifies that the Dexcom API sub-components contain
    ...    'api-gateway' & 'insulin-service' items
    ...
    ...    *Note*: The item _insulin-service_ is not being returned - hence this
    ...    check will fail.
    ...
    ...    For a substitute test, see the keyword
    ...    `Verify Sub-components Contains 'standard-offering'`
    Set Test Variable    ${contains_dexcom_api}    ${False}
    Set Test Variable    ${contains_api_gateway}    ${False}
    Set Test Variable    ${contains_insulin_service}    ${False}
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

Verify Sub-components Contains 'standard-offering'
    [Documentation]    As per the keyword
    ...    `Dexcom API Sub-Components Contain 'api-gateway' & 'insulin-service' Items`
    ...    this will verify that _standard-offering_ is found within the
    ...    sub-components.
    IF    "sandbox" in "${base_url}"    Set Tags    robot:skip-on-failure
    Set Test Variable    ${contains_dexcom_api}    ${False}
    Set Test Variable    ${contains_standard_offering}    ${False}
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
