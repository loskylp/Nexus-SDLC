import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://nexus-sdlc.nxlabs.cc',
  vite: {
    plugins: [tailwindcss()],
  },
  integrations: [
    starlight({
      title: 'Nexus SDLC',
      description: 'Human-in-the-Middle orchestration framework for autonomous software development',
      customCss: ['./src/styles/orbital.css'],
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/loskylp/Nexus-SDLC' },
      ],
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
        {
          tag: 'script',
          attrs: { type: 'module' },
          content: `
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
mermaid.initialize({ startOnLoad: false, theme: 'dark' });

async function renderMermaidBlocks() {
  const blocks = document.querySelectorAll('pre[data-language="mermaid"]');
  let idx = 0;
  for (const pre of blocks) {
    const lines = pre.querySelectorAll('.ec-line');
    const source = lines.length
      ? Array.from(lines).map(l => l.textContent).join('\\n')
      : pre.querySelector('code')?.textContent;
    if (!source) continue;
    const figure = pre.closest('figure') || pre;
    const wrapper = document.createElement('div');
    wrapper.style.cssText = 'background:#13121c;border-radius:8px;padding:1.5rem;overflow:auto;margin:1rem 0;text-align:center;';
    try {
      const { svg } = await mermaid.render('mermaid-' + idx++, source);
      wrapper.innerHTML = svg;
    } catch (e) {
      wrapper.textContent = 'Mermaid render error: ' + e.message;
    }
    figure.replaceWith(wrapper);
  }
}

// DOMContentLoaded may already have fired by the time the CDN import resolves
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', renderMermaidBlocks);
} else {
  renderMermaidBlocks();
}
          `,
        },
      ],
    }),
  ],
});
