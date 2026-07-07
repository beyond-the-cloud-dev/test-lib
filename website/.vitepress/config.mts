import { defineConfig } from "vitepress";

export default defineConfig({
  cleanUrls: true,
  title: "Test Lib",
  description:
    "Apex test data builder library with Builder and Mocker patterns for creating test records in Salesforce",
  base: "/",
  head: [
    ["link", { rel: "icon", href: "/favicon.ico" }],
    // TODO: Configure Google Tag Manager
    // [
    //   'script',
    //   { async: '', src: 'https://www.googletagmanager.com/gtag/js?id=YOUR-GTM-ID' }
    // ],
    // [
    //   'script',
    //   {},
    //   `window.dataLayer = window.dataLayer || [];
    //   function gtag(){dataLayer.push(arguments);}
    //   gtag('js', new Date());
    //   gtag('config', 'YOUR-GTM-ID');`
    // ]
  ],
  themeConfig: {
    logo: "/logo.png",

    nav: [
      { text: "Home", link: "/" },
      { text: "Documentation", link: "/introduction" },
    ],

    sidebar: [
      {
        text: "Docs",
        items: [
          { text: "Introduction", link: "/introduction" },
          { text: "Installation", link: "/installation" },
        ],
      },
      {
        text: "Builder",
        collapsed: false,
        items: [
          { text: "Build", link: "/builder/build" },
          { text: "Templates", link: "/builder/templates" },
          { text: "Randomizers", link: "/builder/randomizers" },
        ],
      },
      {
        text: "Mocker",
        collapsed: true,
        items: [
          { text: "Build", link: "/mocker/build" },
          { text: "Randomizers", link: "/mocker/randomizers" },
        ],
      },
      {
        text: "Utilities",
        collapsed: true,
        items: [{ text: "IdGenerator", link: "/utilities/id-generator" }],
      },
    ],

    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/beyond-the-cloud-dev/test-lib",
      },
    ],

    footer: false,

    search: {
      provider: "local",
    },
  },
});
