import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://nexus-sdlc.nxlabs.cc',
  integrations: [
    starlight({
      title: 'Nexus SDLC',
      description: 'Human-in-the-Middle orchestration framework for autonomous software development',
      customCss: ['./src/styles/orbital.css'],
      social: {
        github: 'https://github.com/loskylp/Nexus-SDLC',
      },
      sidebar: [
        { label: 'Overview', slug: 'overview' },
        { label: 'Rationale', slug: 'rationale' },
        { label: 'References', slug: 'references' },
        {
          label: 'Test Projects',
          autogenerate: { directory: 'tests' },
        },
        {
          label: 'Process Decisions',
          autogenerate: { directory: 'process' },
        },
      ],
      head: [
        {
          tag: 'link',
          attrs: {
            rel: 'stylesheet',
            href: 'https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap',
          },
        },
      ],
    }),
  ],
});
