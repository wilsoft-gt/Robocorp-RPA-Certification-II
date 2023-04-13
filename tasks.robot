*** Settings ***
Documentation       Orders robots from RobotSpareBIn Industries Inc.
...                 Saves the order HTML receipt as a PDF file
...                 Saves the screenshot of the ordered robot
...                 Embeds the screenshot of the robot to the PDF receipt
...                 Creates ZIP archive of the receipts and the images

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             OperatingSystem
Library             RPA.JavaAccessBridge


*** Variables ***
${pdf_dir}=     ${OUTPUT_DIR}${/}pdf${/}
${img_dir}=     ${OUTPUT_DIR}${/}img${/}
${zip_dir}=     ${OUTPUT_DIR}${/}PDF_Receipts.zip


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get Orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Wait Until Keyword Succeeds    5x    1s    Fill the form    ${order}
        ${pdf}=    Store the receipt as PDF file    ${order}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create zip with receipts
    [Teardown]    Cleanup pdf files


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-Order

Get Orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}
    ${orders}=    Read table from CSV    orders.csv    header=${True}
    RETURN    ${orders}

Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${order}
    Select From List By Value    name:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    Preview
    Click Button    Order
    Wait Until Element Is Visible    id:receipt

Store the receipt as PDF file
    [Arguments]    ${order_number}
    Set Local Variable    ${receipt_path}    ${pdf_dir}receipt_${order_number}.pdf
    ${receipt}=    Get Element Attribute    id:receipt    outherHTML
    Html To Pdf    ${receipt}    ${receipt_path}
    RETURN    ${receipt_path}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:robot-preview-image
    Set Local Variable    ${screenshot_path}    ${img_dir}$robot_${order_number}.png
    Screenshot    id:robot-preview-image    ${screenshot_path}
    RETURN    ${screenshot_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${files}=    Create List
    ...    ${pdf}
    ...    ${screenshot}:align=center
    Add Files To Pdf    ${files}    ${pdf}

Go to order another robot
    Click Button    id:order-another

Create zip with receipts
    Archive Folder With Zip    ${pdf_dir}    ${zip_dir}

Cleanup pdf files
    Remove Directory    ${pdf_dir}    ${True}
    Remove Directory    ${img_dir}    ${True}
