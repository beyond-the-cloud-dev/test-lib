import { defineConfig } from "vitepress";

export default defineConfig({
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
      { text: "Guide", link: "/getting-started" },
      { text: "API", link: "/api" },
    ],

    sidebar: [
      {
        text: "Introduction",
        items: [
          { text: "Getting Started", link: "/getting-started" },
          { text: "Installation", link: "/installation" },
        ],
      },
      {
        text: "Core Concepts",
        items: [
          { text: "Builder Pattern", link: "/builder" },
          { text: "Mocker Pattern", link: "/mocker" },
          { text: "Templates", link: "/templates" },
          { text: "Randomizers", link: "/randomizers" },
        ],
      },
      {
        text: "Usage",
        items: [
          { text: "API Reference", link: "/api" },
          { text: "Examples", link: "/examples" },
          { text: "Best Practices", link: "/best-practices" },
        ],
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
