# js-onepager-PBIE
## Single page JavaScript application sample for Power BI Embedded exploration

This code sample demonstrates how to create single page HTML+JavaScript only Power BI Embedded web application. It can be used to address some common questions coming from PBIE Developer community:

* How to easily obtain AAD Power BI REST API access token using [Power BI PowerShell modules](https://docs.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps) for lowest possible friction hands on JavaScript API exploration?
* How to conduct load testing with 100% client-side web page that doesn't require running web server instance? (NOTE: developer has to leverage AAD token obtained in previous step).

### Details

1. This sample doesn’t use ADAL.js to obtain the PBIE token. As a result, it can be run on any client PC, but only until the supplied token expires (60 min or less based on default token lifetime value at the time of this writing).
2. The use of Power BI PowerShell module commandlet to obtain the PBIE token removes the need to register AAD app.
3. This sample has a loop to simulate report reload activity by the user. Developer should adjust time span to allow desired report to fully render. This value will vary depending on particular report setup.
4. It leverages Power BI client side javascript error handling to provide better insights into what may have gone wrong during the run.
5. This sample can be easily extended. E.g., developer can add query string `$filter` parameter that if changed on each report render (NOTE: not included in this sample; requires adding more javascript code) could help in simulating load on the backend cores of your dedciated PBIE capacity. E.g., adding explicit year value will look like this: 
```html
$filter=babynames/Year eq 1900
````
git logThis extra step may be important because initial report load query result will be cached and subsequent report renders will not be hitting the backend if the DAX query from the UI layer remains unchanged. More information on query string filters can be found [here](https://powerbi.microsoft.com/en-us/blog/power-bi-report-url-filter-improvements/).

### Background

The majority of friction points when starting new Power BI Embedded project typically revolve around authentication and authorization. Another challenging situation arises when developer starts thinking about load testing and needs to simulate Power BI or custom app use by multiple users.  This can be done with a web server web app, but in many cases, it would be more convenient, faster and easier to have just a simple JavaScript app presented here.  

### Other notes

Download [Power BI client side JavaScript library](https://github.com/Microsoft/PowerBI-JavaScript/tree/master/dist) if you don’t want to use GitHub content delivery version URL. You only need one library file to include with your page. Use powerbi.js if you expect to do a lot of client side debugging or powerbi.min.js for simple apps. 

I’ve put this sample together from the bits and pieces that I found in various documents, code samples and in comments on stackoverflow.com.

