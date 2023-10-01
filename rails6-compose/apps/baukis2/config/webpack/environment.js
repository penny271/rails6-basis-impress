// const { environment } = require('@rails/webpacker')

// module.exports = environment

const { environment } = require('@rails/webpacker');

// ¥ 2.ch.12.2.3 タグ付け / Tag-it のインストール
const webpack = require('webpack');
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    // $: 'jquery/src/jquery',
    $: 'jquery',
    // jQuery: 'jquery/src/jquery',
    jQuery: 'jquery',
  })
);

// ¥ 2.ch.12.2.3 タグ付け / Tag-it のインストール
// prettier-ignore
const aliasConfig = {
  'jquery': 'jquery-ui-dist/external/jquery/jquery.js',
  'jquery-ui': 'jquery-ui-dist/jquery-ui.js',
};

environment.config.set('resolve.alias', aliasConfig);

module.exports = environment;
