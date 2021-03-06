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
5. Developer can add query string `$filter` parameter to the embed url that if changed in the html file could help in simulating load on the backend cores of your dedicated PBIE capacity. E.g., adding explicit year value will look like this:

```html
$filter=babynames/Year eq 1900
````

Important to note that the initial report load query result will be cached and subsequent report renders will not be hitting the backend if the DAX query from the UI layer remains unchanged. More information on query string filters can be found [here](https://powerbi.microsoft.com/en-us/blog/power-bi-report-url-filter-improvements/).

Developer can add report filter to the configuration object or use set report [filters](https://github.com/Microsoft/PowerBI-JavaScript/wiki/Filters) or slicers javascript functions if there is a need to focus on the backend load by programmatically updating UI generated DAX queries. Here is an example of changes that could be applied to the one pager to leverage report filter to generate different DAX query for each new render:
```javascript
...
//seeding initial filter value  
var startYear=1900;

function EmbedReport() {
...    
    //configuring report level filter to simulate load on the backend core
    var filter = {
              $schema: "http://powerbi.com/product/schema#basic",
                target: {
                table: "babynames",
                column: "Year"
                },
                    operator: "In",
                    values: [startYear]
        };

    //incrementing filter value; restarting when hit numeric filter max
    startYear = startYear < 2019 ? ++startYear : 1900;
    ...
    var config = {
           ...
           filters: [filter],
           ...
    };
```
NOTE: If you are using imported data model these queries can be traced in the SQL Profiler using XMLA endpoint. See "Power BI XMLA endpoint public preview" announcement [blog post](https://powerbi.microsoft.com/en-us/blog/power-bi-open-platform-connectivity-with-xmla-endpoints-public-preview/) for details.

### Background

The majority of friction points when starting new Power BI Embedded project typically revolve around authentication and authorization. Another challenging situation arises when developer starts thinking about load testing and needs to simulate Power BI or custom app use by multiple users.  This can be done with a web server web app, but in many cases, it would be more convenient, faster and easier to have just a simple JavaScript app presented here.  

### Other notes

Download [Power BI client side JavaScript library](https://github.com/Microsoft/PowerBI-JavaScript/tree/master/dist) if you don’t want to use GitHub content delivery version URL. You only need one library file to include with your page. Use powerbi.js if you expect to do a lot of client side debugging or powerbi.min.js for simple apps. 

I’ve put this sample together from the bits and pieces that I found in various documents, code samples and in comments on stackoverflow.com.

**UPDATE [6/1/19]:** added PowerShellAutomation folder that contains PS and template html file to go with it that simplifies configuration process. PS file contains details and "how to" instructions.

**UPDATE [6/15/19]:**  project derived from my base code and ideas in this repo has been shared at 2019 Microsoft Business Applications Summit in Atlanta in several sessions as part of guidance for proper dedicated capacity sizing. 
* MBAS 2019 session: "[Microsoft Power BI: Premium capacity - why use it, how to plan for it, evaluate your needs and adapt your PBI content to it](https://community.powerbi.com/t5/MBAS-Gallery/Microsoft-Power-BI-Premium-capacity-why-use-it-how-to-plan-for/m-p/712532)" has the best coverage. Tool demo starts at around 31 minute mark.
* GitHub repo for [burst mode PowerShell script](https://github.com/samanthgunreddy/PBI_Report_LoadTesting) derived from this project. It is aimed at less technical audience.

**UPDATE [2/7/20]:** There seems to be a problem with either the latest Chromium engine update or powerbi.js or both.  The issue has been escalated the PBIE team that owns powerbi.js library.

There is a workaround:
1)	Get October 15 2019 or earlier version of powerbi.js or powerbi.min.js library from [PBIE Javascript GitHub repo](https://github.com/microsoft/PowerBI-JavaScript/tree/master/dist) and copy it in the same folder as the page HTML file.
2)	In the HTML file switch library reference from its cdn version to local:
````javascript
<!-- <script src="https://cdn.rawgit.com/Microsoft/PowerBI-JavaScript/master/dist/powerbi.min.js" type="text/javascript"></script> -->
<script src="powerbi.min.js" type="text/javascript"></script>
````

Page will start loading and numeric filters will start iterating generating backend queries and traffic.
