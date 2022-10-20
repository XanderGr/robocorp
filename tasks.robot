# Robocorp Certificate level II: Build a robot https://robocorp.com/docs/courses/build-a-robot#24-take-the-certification-exam
# XanderG
*** Settings ***
Documentation   Orders robots from RobotSpareBin Industries Inc.
...             Saves the order HTML receipt as a PDF file.
...             Saves the screenshot of the ordered robot.
...             Embeds the screenshot of the robot to the PDF receipt.
...             Creates ZIP archive of the receipts and the images.
Library         RPA.Browser.Selenium
Library         RPA.HTTP
Library         RPA.Tables
Library         RPA.PDF
Library         RPA.Archive
Library         RPA.Dialogs
#Library         RPA.Robocloud.Secrets
Library         RPA.Robocorp.Vault 
#not needed this time


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${input_something}=  User To Input Something
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds     5x  2s  Submit the order
        ${pdf}=    Store the receipt as a PDF file  ${row}[Order number]
        ${screenshot}=    Wait Until Keyword Succeeds     5x  2s    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts
	[Teardown]  Close open browser


*** Keywords ***
Open the robot order website
    ${secret}=	Get Secret	vault
    Open Available Browser              ${secret}[url]
# Open the robot order website this was without the requirement of the vault
     #Open Available Browser    https://robotsparebinindustries.com/#/robot-order #this one opens the website
     #Download    https://robotsparebinindustries.com/orders.csv    overwrite=True # this downloads the csv file and overwrites it if there is one already


Get orders
    ${table}=    Read table from CSV    orders.csv 
    [Return]    ${table}
# the above reads and returns the csv file, this is handled different from excel xls/xlsx files
User To Input Something
    Add Heading         Please type something
    Add Text Input      URL   ClickSubmit   
    ${result}=          Run dialog
    [Return]            ${result.URL}
# part of the requirements to get the user to input something on this case
# it does not matter if the user enters some text the submit button is there to proceed


Close the annoying modal
    Wait Until Page Contains Element    //button[normalize-space()='OK']    3
    Click Button                        //button[normalize-space()='OK']
# wait for element to appear in browser wait 3 seconds and click the OK button


Fill the form
    [ARGUMENTS]         ${row} 
    Wait Until Page Contains Element    //select[@id='head']    3
    Select From List By Value           //select[@id='head']    ${row}[Head]
    Select Radio Button                 body    ${row}[Body]
    Input Text                          css:body > div:nth-child(2) > div:nth-child(2) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > form:nth-child(2) > div:nth-child(3) > input:nth-child(3)     ${row}[Legs]
    Input Text                          //input[@id='address']  ${row}[Address]
    Click Button                        //button[normalize-space()='Preview']
# using the selenium and the options to wait for element, select div, click radiobutton, enter text and click a button


Submit the order
    Click button                        //button[normalize-space()='Order']
    Wait Until Page Contains Element    //button[normalize-space()='Order another robot']   1
# using the selenium and the options to wait for element and click a button


Take a screenshot of the robot
    [ARGUMENTS]    ${robot_image}
    Wait Until Element Is Visible       //div[@id='robot-preview-image'] 
    ${screenshot}=      Set Variable    ${OUTPUT_DIR}${/}images${/}${robot_image}.png
    Screenshot     //div[@id='robot-preview-image']     ${screenshot}
    [Return]        ${screenshot}
# take a screenshot to be used


Embed the robot screenshot to the receipt PDF file
    [ARGUMENTS]     ${screenshot}   ${pdf}
    Add Watermark Image To Pdf  ${screenshot}   ${pdf}    ${pdf}


Store the receipt as a PDF file
    [ARGUMENTS]    ${receipt#}
    Wait Until Element Is Visible       //div[@id='receipt']
    ${receipt}=  Get Element Attribute  //div[@id='receipt']    outerHTML 
    ${pdf}=      Set Variable           ${OUTPUT_DIR}${/}receipts${/}${receipt#}.pdf
    Html To Pdf     ${receipt}          ${pdf}
    [Return]        ${pdf}
# once the above has been done, the receipt needs to be saved with the naming convention
Go to order another robot
    Click Button                        //button[normalize-space()='Order another robot']


Create a ZIP file of the receipts
    Archive Folder With Zip      ${OUTPUT_DIR}${/}receipts      ${OUTPUT_DIR}${/}orders.zip      True
# save the zip file as orders.zip


Close open browser
    Close Browser
# part of clean up task so nothing is open


#terminal output example below
# .vscode/extensions/robocorp.robotframework-lsp-1.3.0/src/robotframework_debug_adapter/run_robot__main__.py --port 63321 --debug --listener=robotframework_debug_adapter.events_listener.EventsListenerV2 --listener=robotframework_debug_adapter.events_listener.EventsListenerV3
# [ WARN ] This is a deprecated import that will be removed in favor of RPA.Robocorp.Vault
# ==============================================================================
# Tasks :: Orders robots from RobotSpareBin Industries Inc. Saves the order H...
# ==============================================================================
# Order robots from RobotSpareBin Industries Inc                        ...UserWarning: mergePage is deprecated and will be removed in PyPDF2 2.0.0. Use merge_page instead. [_page.py:442]
# Order robots from RobotSpareBin Industries Inc                        | PASS |
# ------------------------------------------------------------------------------
# Tasks :: Orders robots from RobotSpareBin Industries Inc. Saves th... | PASS |
# 1 task, 1 passed, 0 failed
# ==============================================================================
# Output:  /Users/username/Documents/Robots/folder/output.xml
# Log:     /Users/username/Documents/Robots/folder/log.html
# Report:  /Users/username/Documents/Robots/folder/report.html