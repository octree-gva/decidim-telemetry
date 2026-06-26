import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Decidim Telemetry',
  tagline: 'Prometheus metrics and health probes for Decidim',
  favicon: 'img/logo.svg',

  url: 'https://octree.ch',
  baseUrl: '/decidim-telemetry/',
  trailingSlash: false,

  organizationName: 'octree-gva',
  projectName: 'decidim-telemetry',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'Decidim Telemetry',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          href: 'https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry',
          label: 'GitLab',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {label: 'Overview', to: '/'},
            {label: 'Install', to: '/install'},
            {label: 'Prometheus', to: '/prometheus'},
            {label: 'Contribute', to: '/contributing'},
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitLab',
              href: 'https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry',
            },
          ],
        },
      ],
      copyright: 'Built with Docusaurus. Powered by <a href="https://voca.city">Voca</a>.',
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
