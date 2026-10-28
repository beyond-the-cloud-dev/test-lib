import { defineConfig } from "vitepress";
import llmstxt from "vitepress-plugin-llms";

const siteUrl = "https://testlib.beyondthecloud.dev";
const siteTitle = "Test Lib";
const siteDescription =
  "Apex test data builder library with Builder and Mocker patterns for creating test records in Salesforce. Templates, randomizers and Id generation for unit tests. Free, MIT licensed, part of Apex Fluently by Beyond The Cloud.";

export default defineConfig({
  lang: "en-US",
  title: siteTitle,
  description: siteDescription,
  base: "/",
  head: [
    ["link", { rel: "icon", href: "/favicon.ico" }],
    // Bing Webmaster Tools site verification
    ["meta", { name: "msvalidate.01", content: "E86DF40B08FDAC5301E67AD10EFB3E28" }],
    ["meta", { name: "author", content: "Beyond The Cloud" }],
    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:site_name", content: siteTitle }],
    ["meta", { property: "og:image", content: `${siteUrl}/og-image.png` }],
    ["meta", { name: "twitter:card", content: "summary_large_image" }],
    ["meta", { name: "twitter:image", content: `${siteUrl}/og-image.png` }],
    [
      "script",
      { type: "application/ld+json" },
      JSON.stringify({
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        name: siteTitle,
        description: siteDescription,
        url: siteUrl,
        applicationCategory: "DeveloperApplication",
        operatingSystem: "Salesforce",
        license: "https://opensource.org/licenses/MIT",
        codeRepository: "https://github.com/beyond-the-cloud-dev/test-lib",
        isPartOf: {
          "@type": "SoftwareApplication",
          name: "Apex Fluently",
          url: "https://apexfluently.beyondthecloud.dev",
        },
        offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
        author: {
          "@type": "Organization",
          name: "Beyond The Cloud",
          url: "https://beyondthecloud.dev",
          sameAs: [
            "https://github.com/beyond-the-cloud-dev",
            "https://www.linkedin.com/company/beyondtheclouddev",
          ],
        },
      }),
    ],
    // Google Analytics (G-XFE5TN0X87)
    [
      'script',
      { async: '', src: 'https://www.googletagmanager.com/gtag/js?id=G-XFE5TN0X87' }
    ],
    [
      'script',
      {},
      `window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-XFE5TN0X87');`
    ]
  ],
  sitemap: {
    hostname: siteUrl,
  },
  vite: {
    plugins: [llmstxt({ domain: siteUrl })],
  },
  transformPageData(pageData) {
    const canonicalUrl = `${siteUrl}/${pageData.relativePath}`
      .replace(/index\.md$/, "")
      .replace(/\.md$/, ".html");
    pageData.frontmatter.head ??= [];
    pageData.frontmatter.head.push(
      ["link", { rel: "canonical", href: canonicalUrl }],
      ["meta", { property: "og:url", content: canonicalUrl }],
    );
    // Markdown twin built by vitepress-plugin-llms (llms.txt for the home page),
    // served by middleware.js on Accept: text/markdown
    const markdownPath =
      pageData.relativePath === "index.md"
        ? "llms.txt"
        : pageData.relativePath.replace(/\/index\.md$/, ".md");
    pageData.frontmatter.head.push([
      "link",
      {
        rel: "alternate",
        type: "text/markdown",
        href: `${siteUrl}/${markdownPath}`,
      },
    ]);
    const pageTitle = pageData.frontmatter.title || pageData.title;
    pageData.frontmatter.head.push(
      [
        "meta",
        {
          property: "og:title",
          content:
            pageTitle && pageTitle !== siteTitle
              ? `${pageTitle} | ${siteTitle}`
              : siteTitle,
        },
      ],
      [
        "meta",
        {
          property: "og:description",
          content:
            pageData.frontmatter.description ||
            pageData.description ||
            siteDescription,
        },
      ],
    );
  },
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
