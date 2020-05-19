import 'dart:ui';

const app_name = "Daraz";
const app_key = "123456";
const app_logo_url =
    "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zd…02Ljg5IDIuNjYtMi42NiA0LjQxLTYuNDYgNS4xLTExLjY1bC0yMi40OS4wMXoiLz48L3N2Zz4=";

const app_terms_url = "https://google.com";
const app_privacy_url = "https://google.com";

/*<! ------ APP SETTINGS ------!>*/
const app_currency_symbol = "\£";
const app_currency_iso = "gbp";
const app_locales_supported = [
  Locale('en'),
];
// If you want to localize the app, add the locale above
// then create a new lang json file using keys from en.json
// e.g. lang/es.json

/*<! ------ PAYMENT GATEWAYS ------!>*/
// Available: "Stripe", "CashOnDelivery",
// Add the method to the array below e.g. ["Stripe", "CashOnDelivery"]

const app_payment_methods = ["Stripe"];
const app_stripe_account = "Your Stripe Key";
const app_stripe_live_mode = false;

/*<! ------ WP LOGIN (OPTIONAL) ------!>*/
const use_wp_login = true;
const app_base_url = "http://localhost/globdig/wp"; // change to your url
const consumerKey = "ck_fa207a8d2ec371e89009cbd862e88dee6e8f91c7";
const consumerSecret = "cs_d13ed572a276175edfc898f78c30368efac12edb";

const admintoken="mEw7 7PVg YhWA 4q3n GHYr ydz4";
// const app_base_url = "https://wooexp.mediaserver.no"; // change to your url
// const consumerKey = "ck_09222d63b2d48b90bf0429ca41af9897989b39dd";
// const consumerSecret = "cs_aa77136a3d4e5bb7f1f580961b942a443cf9041a";


// const app_base_url = "http://epasal.herokuapp.com"; // change to your url
// const consumerKey = "ck_ef7bedc8ec9bb2b0ced5564efffd03b5065bec0f";
// const consumerSecret = "cs_8569b0bbc9dd047fe8b8952629ab06b7d4275e4b";


const app_forgot_password_url =
    "https://mysite.com/my-account/lost-password"; // change to your forgot password url
const app_wp_api_path = "/wp-json";

/*<! ------ DEBUGGER ENABLED ------!>*/

const app_debug = true;
