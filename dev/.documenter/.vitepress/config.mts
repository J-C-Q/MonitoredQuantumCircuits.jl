import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/j-c-q.github.io/MonitoredQuantumCircuits.jl/',// TODO: replace this in makedocs!
  title: 'MonitoredQuantumCircuits.jl',
  description: 'Documentation for MonitoredQuantumCircuits.jl',
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../final_site', // This is required for MarkdownVitepress to work correctly...
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  ignoreDeadLinks: true,

  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3),
      md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  themeConfig: {
    outline: 'deep',
    logo: { src: '/logo.png', width: 24, height: 24},
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav: [
{ text: 'Home', link: '/index' },
{ text: 'Tutorial', link: '/tutorial' },
{ text: 'API Reference', link: '/api' }
]
,
    sidebar: [
{ text: 'Home', link: '/index' },
{ text: 'Tutorial', link: '/tutorial' },
{ text: 'API Reference', link: '/api' }
]
,
    editLink: { pattern: "https://https://github.com/j-c-q/MonitoredQuantumCircuits.jl/edit/main/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/j-c-q/MonitoredQuantumCircuits.jl' }
    ],
    footer: {
      message: 'Made with <a href="https://luxdl.github.io/DocumenterVitepress.jl/dev/" target="_blank"><strong>DocumenterVitepress.jl</strong></a><br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()}.`
    }
  }
})
