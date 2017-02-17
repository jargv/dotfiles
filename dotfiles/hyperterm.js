module.exports = {
  config: {
    copyOnSelect: true,
    fontSize: 14,
    modifierKeys: {
      altIsMeta: true,
    },
    fontFamily: '"DejaVu Sans Mono", "Lucida Console", monospace',
    borderColor: '#f33',
    bell: false,
    css: '', // custom css to embed in the main window
    termCSS: '', // custom css to embed in the terminal window
    padding: '0 0', // custom padding (css format, i.e.: `top right bottom left`)
    showHamburgerMenu: true,
    showWindowControls: true,
  },
  plugins: ['hyperterm-oceanic-next'],
  localPlugins: [] //plugins in development
};
