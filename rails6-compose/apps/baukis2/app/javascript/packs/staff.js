require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");

import "../staff/customer_form.js";
import "../staff/entries_form.js";
import "../staff/messages.js"; // ¥ 2.ch.10.2.4 問い合わせ到着の通知 ajax
import "../staff/tags.js"; // ¥ 2.ch.12.2.3 タグ付け - Tag-it yarn不可だったため CDNで代替した
