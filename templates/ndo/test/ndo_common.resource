*** Settings ***
Library   pabot.PabotLib
Library   RequestsLibrary
Library   JSONLibrary
Library   Collections
Library   OperatingSystem
Library   DateTime
Library   ./lib/Ndo.py   ndo

*** Variables ***
${login_json}   {"userName" : "%{MSO_USERNAME}", "userPasswd" : "%{MSO_PASSWORD}", "domain" : "%{MSO_DOMAIN=DefaultAuth}"}
${state_path}   tests/state/

*** Keywords ***
Check NDO Token Timestamp
    ${current_time}=   Get Current Date   result_format=epoch
    ${token_timestamp}=   Get Parallel Value For Key   ndo_token_timestamp
    ${expires}=   Evaluate   (${token_timestamp} - ${current_time}) <= 120
    RETURN   ${expires}

Verify NDO Token
    ${token_expires}=   Check NDO Token Timestamp
    IF   ${token_expires}
        Acquire Lock   ndo_token_refresh
        TRY
            ${token_expires}=   Check NDO Token Timestamp
            IF   ${token_expires}
                Get NDO Token
            END
        EXCEPT
            Fatal Error   NDO Token Refresh Failed
        FINALLY
            Release Lock   ndo_token_refresh
        END
    END

Get NDO Token
    Create Session   login   %{MSO_URL}   headers={"Content-Type": "application/json"}
    ${log_level}=   Set Log Level   NONE
    ${response}=   Wait Until Keyword Succeeds   6x   10s   POST On Session   login   /login   data=${login_json}
    Set Log Level   ${log_level}
    ${r_token}=   Get Value From Json   ${response.json()}   $..jwttoken
    Set Parallel Value For Key   ndo_token   ${r_token[0]}
    ${token_creation_time}=   Get Current Date   result_format=epoch
    ${token_refresh_timeout}=   Evaluate   int([value for value in $response.headers['Set-Cookie'].split(';') if 'Max-Age=' in value.strip()][0].split('=')[1])
    ${token_timestamp}=   Evaluate   ${token_creation_time} + ${token_refresh_timeout}
    Set Parallel Value For Key   ndo_token_timestamp   ${token_timestamp}

Login NDO
    Run Only Once   Get NDO Token
    Verify NDO Token
    ${ndo_token}=   Get Parallel Value For Key   ndo_token
    Create Session   ndo   %{MSO_URL}   headers={"Content-Type": "application/json", "Authorization": "Bearer ${ndo_token}"}
    Set Global Variable   ${STATE_PATH}   ${state_path}

Should Be Equal Value Json String
    [Arguments]    ${json}    ${json_path}   ${value}=${EMPTY}   ${value2}=${EMPTY}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    Run Keyword If   "${value}" != "${EMPTY}" and "${value2}" == "${EMPTY}"   Should Be Equal As Strings   ${r_value}[0]   ${value}
    Run Keyword If   "${value}" != "${EMPTY}" and "${value2}" != "${EMPTY}"   Should Be True   "${r_value}[0]" == "${value}" or "${r_value}[0]" == "${value2}"

Should Be Equal Value Json Boolean
    [Arguments]    ${json}    ${json_path}   ${value}=${EMPTY}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    ${b_r_value}=   Convert To Boolean   ${r_value}[0]
    ${b_value}=   Convert To Boolean   ${value}
    Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal   ${b_r_value}   ${b_value}

Should Be Equal Value Json Integer
    [Arguments]    ${json}    ${json_path}   ${value}=${EMPTY}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal As Integers   ${r_value}[0]   ${value}

Should Be Equal Value Json Number
    [Arguments]    ${json}    ${json_path}   ${value}=${EMPTY}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal As Numbers   ${r_value}[0]   ${value}

Should Be Equal Value Json List
    [Arguments]    ${json}    ${json_path}   ${value}=${None}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    Run Keyword If   ${value} != "${None}"   Lists Should Be Equal   ${r_value}[0]   ${value}   ignore_order=True
