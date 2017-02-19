exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        "js/app.js": [/^(web\/static\/js\/app\.js)/, /^(node_modules)/, /^(web\/static\/vendor)|(deps)/],
        "js/public.js": /^(node_modules\/jquery)/,
        "js/editor.js": [/^(web\/static\/js\/editor\.js)/, /^(node_modules)/, /^(web\/static\/vendor)/],
      },

      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/stable/docs/config.md#files
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      order: {
        before: [
          "web/static/vendor/js/medium-editor.js"
        ]
      }
    },
    stylesheets: {
      joinTo: {
        "css/app.css": ["web/static/css/app.scss", "web/static/vendor/css/*"],
        "css/public.css": "web/static/css/public.scss",
        "css/editor.css": ["web/static/vendor/css/*", "web/static/vendor/css/themes/beagle.css", "web/static/css/editor.scss"]
      }
    },
    templates: {
      joinTo: ["js/app.js", "js.editor.js"]
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    sass: {
      mode: "native",
      includePaths: ["npm_modules/picnic"]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"],
      "js/editor.js": ["web/static/js/editor"]
    }
  },

  npm: {
    enabled: true,
    // Whitelist the npm deps to be pulled in as front-end assets.
    // All other deps in package.json will be excluded from the bundle.
    whitelist: ["phoenix", "phoenix_html", "jquery-ui", "jquery", "jquery-sortable", "blueimp-file-upload", "jquery.iframe-transport"],
    styles: {
    },
    globals: {
      $: 'jquery',
      jQuery: 'jquery'
    }
  }
};
