# This script was created by Sergei Gundorov to address requests to simplify Power BI dedicated capacity load assessment
# Version 1 created on 6/1/2019
#
# HOW TO USE:
# 1.You should have an identity with Power BI service access.
# 2.This script walks the user through PBIE API based automated load test setup using numeric filter to
#   simulate front end and backend cores activity. Choose a workspace and then a report in that workspace that
#   has numeric filter. You will need table name, column name, starting value of the filter and maximum value of the
#   selected filter that would trigger restart of the loop. All string values are case sensitive. Script assumes that 
#   chosen filter value can be incremented by 1 on each iteration. If this pattern doesn't apply to your filter 
#   selection, you will have to adjust the increment logic in the body of the script. 
# 3."sessionRestart" parameter triggers browser session reload.  It is hardcoded to 100, but can be 
#   adjusted higher or lower. The value of 100 seems to work well for all assessed sample reports this script
#   was tested with during development. Note that if the range of numeric filter is greater than sessionRestart value,
#   new loop will be triggered on 100th cycle.
# 4.Upon completion of the final configuration step script will generate report and token config files in the same folder
#   as the executing script.  It will launch a web page. Script assumes user has chrome browser installed. 
#   Change Start-Process target if you want to use different browser.
# 5.Standard lifetime for an Aad token is 60 min.  If you want your test page to run for more than 60 min, answer 'Y'
#   to attempt to run for longer.  This branch of code will attempt to update Aad token every 30 min (1800 sec)
#   which was an adequate interval for the reports tested with this script. If you answer 'N', script execution will 
#   terminate, however, the launched browser session will continue to run until the token expires. At token expiration 
#   time report rendering will terminate and return an error. Count of renders will be retained in the browser session. 
# 6.The folder where you are executing this script must contain supplied with the script html file named:
#   PBIESinglePageUOD_noADAL_event_filter_loop.html. Once configuration is completed and first browser session
#   is launched, you can open this file in other browser sessions to generate more traffic.     


#Helper function to update Aad token
function GetToken($configFilePath)
{
    #writing out Aad token value to config file
    $aadToken=Get-PowerBIAccessToken -AsString | % {$_.replace("Bearer ","").Trim()}

    $configTokenString="accessToken=`'{`"PBIToken`":`"$($aadToken)`"}`';"

    #Write-host $configTokenString

    $tokenConfigFilePath = $configFilePath + "\PBIToken.json"

    #Wrting token value to config file
    Set-Content -Path $tokenConfigFilePath -Value $configTokenString
}

Login-PowerBI

$wkSpaceList=Get-PowerBIWorkspace

$i=1

foreach ($w in $wkSpaceList)
{
    Write-Host "[$($i)]" -ForegroundColor Yellow -NoNewline
    Write-Host " - $($w.Id) - $($w.Name)" -ForegroundColor Green
    
    ++$i
}


Write-host "Your report for this load test configuration must have numeric filter to generate DAX activity" -ForegroundColor Red
$wpChoice = Read-Host "Choose workspace index"

#Write-Host "You picked: $($wpChoice)"

$wpPick= Get-PowerBIWorkspace -First 1 -Skip ($wpChoice - 1)

Write-Host "Enumerating reports in " $($wpPick[0].Id)

$rptList=Get-PowerBIReport -WorkspaceId $wpPick[0].Id

$i=1

foreach ($r in $rptList)
{
    Write-Host "[$($i)]" -ForegroundColor Yellow -NoNewline
    Write-Host " - $($r.Id) - $($r.Name)" -ForegroundColor Green
    ++$i
}

$rptChoice = Read-Host "Choose report index"
#Write-Host "You picked: $($rptChoice)"
$rptPick=Get-PowerBIReport -WorkspaceId $wpPick[0].Id -First 1 -Skip ($rptChoice - 1)

##TODO: add to final config file output
#Write-host $rptPick[0].EmbedUrl

#Numeric filter construction area

Write-host "ALL FILTER CONFIGURATION ENTRIES ARE CASE SENSITIVE!" -ForegroundColor Red

$filterTableName = Read-Host "Filter table name"
$filterColumnName = Read-Host "Filter column name"
$filterStartValue = Read-Host "Filter start value"
$filterMaxValue = Read-Host "Filter max value"

$configOutputString= "reportParameters=`'{`"reportUrl`":`"$($rptPick[0].EmbedUrl)`",`"filterStart`":$($filterStartValue),`"filterMax`":$($filterMaxValue),`"sessionRestart`":100,`"filterTable`":`"$($filterTableName)`",`"filterColumn`":`"$($filterColumnName)`"}`';"

Write-Host $configOutputString 

$rptConfigFilePath = (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition) + "\PBIReport.json"

Write-host "Report config file location: $($rptConfigFilePath)"

#Wrting report definition to config file
Set-Content -Path $rptConfigFilePath -Value $configOutputString

#Getting Aad token for initial run
GetToken (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)

#Launching browser session
$testFilePath= (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition) + "\PBIESinglePageUOD_noADAL_event_filter_loop.html"

Start-process chrome.exe -ArgumentList $testFilePath

#requesting updated token every 30 min
Write-host '*********************************************'
$endlessRun = Read-Host "Attempt to run for more than 60 min? (Y/N)"

if( $endlessRun.ToUpper() -eq 'N')
{
    Logout-PowerBI
}
else
{
    Write-host "Working..."
    #requesting new token at lifetime mid-point that should be adequate in most cases
    while ($true)
    {
        Start-Sleep -Seconds 1800
        #Start-Sleep -Seconds 60
        GetToken (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)
        Write-host "Requested token update at $((Get-Date).ToString('HH:mm:ss'))"
    }
}