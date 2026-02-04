---
layout: home

hero:
  name: "Test Lib"
  text: "Apex Test Module"
  tagline: A fluent, type-safe library for creating test data in Salesforce Apex tests using Builder and Mocker patterns.
  actions:
    - theme: brand
      text: Get Started
      link: /introduction
    - theme: alt
      text: Builder
      link: /builder/build
    - theme: alt
      text: Mocker
      link: /mocker/build

features:
  - title: Builder Pattern
    details: Create real SObject records with fluent API. Build single records or bulk insert multiple records with one call.

  - title: Mocker Pattern
    details: Create in-memory SObjects without DML operations. Perfect for unit testing triggers, services, and complex logic.

  - title: Templates
    details: Define reusable record templates for common scenarios like "enterprise account" or "closedWon opportunity".

  - title: Randomizers
    details: Generate unique field values automatically. Create 100 accounts with unique names and industries effortlessly.

  - title: Parent-Child Relations
    details: Mock complex object relationships including parent lookups and child record collections.

  - title: Production Ready
    details: Battle-tested in production. Part of Beyond The Cloud suite of enterprise-grade Salesforce libraries.
---

<BTCFooter context="test-lib" />
