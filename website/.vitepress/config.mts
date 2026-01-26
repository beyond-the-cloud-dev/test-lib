import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Salesforce Template",
  description:
    "Professional Salesforce development template with CI/CD, testing, and best practices",
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
  base: "/template/",
  outDir: "../dist/docs",
  sitemap: {
    hostname: "https://beyond-the-cloud-dev.github.io/template/",
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Home", link: "/" },
      { text: "Documentation", link: "/introduction" },
    ],

    sidebar: [
      {
        text: "Getting Started",
        items: [
          { text: "Introduction", link: "/introduction" },
          { text: "Quick Start", link: "/guide/getting-started" },
        ],
      },
      {
        text: "Guide",
        collapsed: false,
        items: [
          { text: "Development", link: "/guide/development" },
          { text: "Testing", link: "/guide/testing" },
          { text: "Deployment", link: "/guide/deployment" },
        ],
      },
      {
        text: "API Reference",
        collapsed: true,
        items: [
          { text: "LWC Components", link: "/api/lwc" },
          { text: "Apex Classes", link: "/api/apex" },
        ],
      },
      {
        text: "Examples",
        collapsed: true,
        items: [
          { text: "LWC Examples", link: "/examples/lwc-examples" },
          { text: "Apex Examples", link: "/examples/apex-examples" },
          { text: "Best Practices", link: "/examples/best-practices" },
        ],
      },
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2025-present Beyond The Cloud Sp. z o.o.",
    },
    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/beyond-the-cloud-dev/template",
      },
      {
        icon: "linkedin",
        link: "https://www.linkedin.com/company/beyondtheclouddev",
      },
    ],
  },
});
