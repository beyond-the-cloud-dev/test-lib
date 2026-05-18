# Installation

## Install via Unlocked Package

Install the Test Lib unlocked package with `btcdev` namespace to your Salesforce environment:

<!--
sf package version create --package "Test Lib" --target-dev-hub beyondthecloud-prod --installation-key-bypass --wait 30 --code-coverage

sf package version promote --package "Test Lib@0.1.0-1"  --target-dev-hub beyondthecloud-prod

-->

Install the Test Lib unlocked package with `btcdev` namespace to your Salesforce environment:

`/packaging/installPackage.apexp?p0=04tP600000390yLIAQ`

<a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04tP600000390yLIAQ" target="_blank" style={{display: 'inline-block', backgroundColor: '#1976d2', color: 'white', padding: '10px 20px', textDecoration: 'none', borderRadius: '4px', marginRight: '10px'}}>
    <p style={{margin: '0px'}}>Install on Sandbox</p>
</a>

<a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04tP600000390yLIAQ" target="_blank" style={{display: 'inline-block', backgroundColor: '#d32f2f', color: 'white', padding: '10px 20px', textDecoration: 'none', borderRadius: '4px'}}>
    <p style={{margin: '0px'}}>Install on Production</p>
</a>

## Install via Unmanaged Package

Install the Test Lib unmanaged package without namespace to your Salesforce environment:

**IN PROGRESS**

<!-- `/packaging/installPackage.apexp?p0=04tXXXXXXXXXXXXXXX`

[Install on Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tXXXXXXXXXXXXXXX)

[Install on Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tXXXXXXXXXXXXXXX) -->

## Deploy via Button

Click the button below to deploy Test Lib to your environment.

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com/?owner=beyond-the-cloud-dev&repo=test-lib&ref=main)

## Copy and Deploy

**Apex**

- [`TestModule.cls`](https://github.com/beyond-the-cloud-dev/test-lib/blob/main/force-app/main/default/classes/TestModule.cls)
- [`TestModule_Test.cls`](https://github.com/beyond-the-cloud-dev/test-lib/blob/main/force-app/main/default/classes/TestModule_Test.cls)
