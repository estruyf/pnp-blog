# Init API permissions for your SPFx projects without deploying them

When developing your SPFx components, you usually first run them locally
before deploying them (really?).
And then comes the time to work with API such as Microsoft Graph.
If you never use those permissions before in your SPFx projects (and the
tenant with which you\'re working), you realize that you have to:

-   Add required API permissions in your `package-solution.json` file
-   Bundle / Ship your project
-   Publish it
-   Go to the SharePoint Admin Center Web API Permissions page
-   Approve those permissions
All of this, just to play with the API as you didn\'t plan to release
your package in a production environment.
So what if you could bypass all these steps for both Graph and owned
API?

**Warning**

This trick is just for development purposes. In Production environment,
you should update your `package-solution.json` file to add required
permissions and allow them (or ask for validation) in the *API
access* page.
## Prerequisites 
1.  An Office 365 (Dev) Tenant or a Partner Demo Tenant
2.  The following Azure AD role at least
    -   Application Administrator
## With Graph API 
First, we\'re going to play with Graph API through the [Microsoft Graph
Toolkit](https://docs.microsoft.com/fr-fr/graph/toolkit/overview).
### Prepare your sample 

Init a SPFx project (WebPart one with React, let\'s call it *HelloApi*),
then add the Microsoft Graph Toolkit by
executing `npm i @microsoft/mgt @microsoft/mgt-react` from the
project\'s root path.
Once done, open your main component file (let\'s say
here **HelloApi.tsx**) and add the `PeoplePicker` component like this:
``` {.lia-code-sample .language-javascript}
import * as React from 'react';
import styles from './HelloApi.module.scss';
import { IHelloApiProps } from './IHelloApiProps';
import { escape } from '@microsoft/sp-lodash-subset';
import { PeoplePicker } from '@microsoft/mgt-react';

export default class HelloApi extends React.Component<IHelloApiProps, {}> {
  public render(): React.ReactElement<IHelloApiProps> {
    return (
      <div className={ styles.HelloApi }>
        <div className={ styles.container }>
          <div className={ styles.row }>
            <div className={ styles.column }>
              <span className={ styles.title }>Welcome to SharePoint!</span>
              <p className={ styles.subTitle }>Customize SharePoint experiences using Web Parts.</p>
              <p className={ styles.description }>{escape(this.props.description)}</p>
              <a href="https://aka.ms/spfx" className={ styles.button }>
                <span className={ styles.label }>Learn more</span>
              </a>
            </div>
          </div>
        </div>
        <PeoplePicker />
      </div>
    );
  }
}
```
### Run it in remote workbench 

Now run your sample with `gulp serve` and display your webpart in your
remote workbench
(<https://contoso.sharepoint.com/_layouts/15/workbench.aspx>). Try to
use the `PeoplePicker` component: you\'ll see that just by clicking on
the search box, you\'ll get *We didn\'t find any matches*.
![peoplepicker-ui-fail.png](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/261327i7C491A73DF1A9A84/image-size/large?v=v2&px=999 "peoplepicker-ui-fail.png")
 

Display your developer toolbox (F12) and go to the browser console, you
should see the following error:
![peoplepicker-console-fail.png](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/261328i877C183AB94DAEC5/image-size/large?v=v2&px=999 "peoplepicker-console-fail.png")
As you can see, it\'s a 403 error, which is well-known when using Graph
API endpoints that have not been allowed on the first place.
 

### Add Graph API through UI 

From the Azure portal, display the *Azure Active Directory* (AAD), then
select the **App Registration** menu and select **All Applications**,
then click on **SharePoint Online Client Extensibility Web Application
Principal**. It\'s the AAD Application that holds the connection to the
API (Microsoft and others) from SharePoint (SPFx or every other
development) using the *Implicit Flow*.
Once here, click on **Add a permission**, then select **Microsoft
Graph** and add the \[*People.Read*\] Graph API [delegated
permission]{.underline} (you can type the name of the permission in the
available search box to get it easily).
![aad-app-spo-api-graph.png](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/261329i49E61D0AD724669F/image-size/large?v=v2&px=999 "aad-app-spo-api-graph.png")
Once added, grant it by clicking on **Grant admin consent for contoso**.
If you go in the *API access* page
(<https://contoso-admin.sharepoint.com/_layouts/15/online/AdminHome.aspx#/webApiPermissionManagement>),
you should see something like this:
![(other Graph API permissions displayed here won\'t be necessary for
the
sample)](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/261330i6A95D15054FE0812/image-size/large?v=v2&px=999 "api-access-approved.png")
**Warning**

It can take a couple of minutes before consented permissions is
effective, so don\'t be surprised if it\'s not working right away after
approval.

### Add Graph API through CLI for Microsoft 365

``` {.lia-code-sample .language-bash}
m365 login # Don't execute that command if you're already connected
m365 spo serviceprincipal grant add --resource 'Microsoft Graph' --scope 'People.Read'
```
**Info**

Don\'t be surprised if by that way, the permission appears in the
\"Other permissions granted for \[your tenant\]\": it won\'t prevent
your SPFx solution to work.

### Try again 

Now try to use the `PeoplePicker` component again: you\'ll see that with
the addition of the Graph API permission, you should be able to use that
component!
![peoplepicker-ui-success.png](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/261331i81A858A6A4D017BA/image-size/large?v=v2&px=999 "peoplepicker-ui-success.png")

## With custom API 

When using a custom API, it\'s a little bit more tricky but easy to
handle anyway.
You can follow [this Microsoft
article](https://docs.microsoft.com/fr-fr/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi) until
the \"[Deploy the
solution](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/use-aadhttpclient-enterpriseapi#deploy-the-solution-to-the-sharepoint-app-catalog)\"
part.
Instead of bundling and shipping, we\'ll add the AAD App
(called *contoso-api-dp20200915* if we follow the mentioned article)
created from the Azure Function Authentication part in the SharePoint
Service Principal.

### Add your AAD Application to the SharePoint Service Principal 

Display again the AAD page, then select the **App Registration** menu,
select **All Applications** and click on **SharePoint Online Client
Extensibility Web Application Principal**. Once here, click on **Add a
permission**, then select the **My APIs** tab and select the fresh added
AAD App created before. Select the **user_impersonation** permission,
then confirm.
![aad-app-spo-api-custom.png](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/261332i7206CD2A49DCAEFB/image-size/large?v=v2&px=999 "aad-app-spo-api-custom.png")

Finally, grant this permission by clicking on **Grant admin consent for
contoso**.
If you go again in the *API access* page, you should see something like
this:
![api-access-custom-approved.png](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/261337i4486CDC42E9CFA65/image-size/large?v=v2&px=999 "api-access-custom-approved.png")

### Add custom API through CLI for Microsoft 365

``` {.lia-code-sample .language-javascript}
m365 login # Don't execute that command if you're already connected
m365 spo serviceprincipal grant add --resource 'contoso-api-dp20200915' --scope 'user_impersonation'
```
**Info**

Don\'t be surprised if by that way, the permission appears in the
\"Other permissions granted for \[your tenant\]\": it won\'t prevent
your SPFx solution to work.
**Warning**

If you use an Azure Function as an API and enable **Managed
Identity** for any reason, you better have to rename the linked AAD
Application to give it a different name than both your Function and
its **Managed Identity**. Otherwise, the command will try to find a
scope on it instead of the AAD App and fail.
### Updated sample

To run your custom API from your SPFx component, you can update your
sample like below:
*IHelloApiProps.ts*
``` {.lia-code-sample .language-javascript}
import { AadHttpClientFactory } from '@microsoft/sp-http';

export interface IHelloApiProps {
  aadFactory: AadHttpClientFactory;
  description: string;
}
```
 

*HelloApiWebPart.ts*
``` {.lia-code-sample .language-javascript}
// ...
export default class HelloApiWebPart extends BaseClientSideWebPart<IHelloApiWebPartProps> {

    // ...

    public render(): void {
        const element: React.ReactElement<IHelloApiProps> = React.createElement(
        HelloGraph,
        {
            description: this.properties.description,
            aadFactory: this.context.aadHttpClientFactory,
        }
        );

        ReactDom.render(element, this.domElement);
    }

  // ...
}
```
 

*HelloApi.tsx*
``` {.lia-code-sample .language-javascript}
import * as React from 'react';
import styles from './HelloApi.module.scss';
import { IHelloApiProps } from './IHelloApiProps';
import { AadHttpClient, HttpClientResponse } from '@microsoft/sp-http';

interface IHelloApiState {
  ordersToDisplay: any;
}

export default class HelloApi extends React.Component<IHelloApiProps, IHelloApiState> {

 public constructor(props) {
    super(props);

    this.state = {
    ordersToDisplay: null
    };
 }

 public componentDidMount() {
    this.props.aadFactory
      .getClient('https://contoso-api-dp20191109.azurewebsites.net')
      .then((client: AadHttpClient): void => {
        client
          .get('https://contoso-api-dp20191109.azurewebsites.net/api/Orders', AadHttpClient.configurations.v1)
          .then((response: HttpClientResponse): Promise<any> => {
            return response.json();
          })
          .then((orders: any): void => {
            this.setState({
              ordersToDisplay: orders
            })
          });
      }).catch((err) => {
        console.log(err);
      });
  }

  public render(): React.ReactElement<IHelloApiProps> {
    return (
      <div className={ styles.HelloApi }>
        <div className={ styles.container }>
          <div className={ styles.row }>
            <div className={ styles.column }>
              <span className={ styles.title }>Welcome to SharePoint!</span>
              <p className={ styles.subTitle }>Customize SharePoint experiences using Web Parts.</p>
              <p className={ styles.description }>
               <ul>
                    {this.state.ordersToDisplay &&
                        this.state.ordersToDisplay.map(o => {
                            return <li>{o.rep}: {o.total}</li>
                        })
                    }
                </ul>
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
```
 

Now you can run your sample locally and try it in your hosted workbench,
playing with it and updating your WebPart as you want!
\... And don\'t forget to update your `package-solution.json` file to
include the required APIs before
shipping!

Happy coding!
*This article was cross-posted on [my
blog](https://michaelmaillot.github.io/tips/20210302-spfx-api-permissions/).*