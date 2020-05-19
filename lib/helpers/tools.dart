import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intl/intl.dart';
import 'package:pasal1/app_payment_methods.dart';
import 'package:pasal1/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:pasal1/labelconfig.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:pasal1/models/billing_details.dart';
import 'package:pasal1/models/cart.dart';
import 'package:pasal1/models/cart_line_item.dart';
import 'package:pasal1/models/checkout_session.dart';
import 'package:pasal1/models/payment_type.dart';
import 'package:html/parser.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:pasal1/widgets/pasal_widgets.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:status_alert/status_alert.dart';
import '../models/products.dart';
import '../models/tax_rate.dart';
import '../pasal_connector.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;

appPasalConnector(Function(PasalConnector) api) async {
  PasalConnector pasalConnector = await PasalConnector.getInstance();
  return await api(pasalConnector);
}

appWordpress() async {
  
  // wp.WordPress wordPress;

    // adminName and adminKey is needed only for admin level APIs
    wp.WordPress wordPress = wp.WordPress(
      baseUrl: app_base_url,
      authenticator: wp.WordPressAuthenticator.JWT,
      adminName: 'mobile',
      adminKey: "123456",
    );
    return  wordPress;
}

List<PaymentType> getPaymentTypes() {
  return arrPaymentMethods.where((v) => v != null).toList();
}

PaymentType addPayment(PaymentType paymentType) {
  return app_payment_methods.contains(paymentType.name) ? paymentType : null;
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

showStatusAlert(context,
    {@required String title, String subtitle, IconData icon, int duration}) {
  StatusAlert.show(
    context,
    duration: Duration(seconds: duration ?? 2),
    title: title,
    subtitle: subtitle,
    configuration: IconConfiguration(icon: icon ?? Icons.done, size: 50),
  );
}

class EdgeAlertStyle {
  static final int SUCCESS = 1;
  static final int WARNING = 2;
  static final int INFO = 3;
  static final int DANGER = 4;
}

void showEdgeAlertWith(context,
    {title = "", desc = "", int gravity = 1, int style = 1, IconData icon}) {
  switch (style) {
    case 1: // SUCCESS
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.green,
          icon: icon ?? Icons.check,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    case 2: // WARNING
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.orange,
          icon: icon ?? Icons.error_outline,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    case 3: // INFO
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.teal,
          icon: icon ?? Icons.info,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    case 4: // DANGER
      EdgeAlert.show(context,
          title: title,
          description: desc,
          gravity: gravity,
          backgroundColor: Colors.redAccent,
          icon: icon ?? Icons.warning,
          duration: EdgeAlert.LENGTH_LONG);
      break;
    default:
      break;
  }
}

String parseHtmlString(String htmlString) {
  var document = parse(htmlString);
  String parsedString = parse(document.body.text).documentElement.text;
  return parsedString;
}

String formatDoubleCurrency({double total}) {
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
    amount: total,
    settings: MoneyFormatterSettings(
      symbol: app_currency_symbol,
    ),
  );
  return fmf.output.symbolOnLeft;
}

String formatStringCurrency({@required String total}) {
  double tmpVal;
  if (total == null || total == "") {
    tmpVal = 0;
  } else {
    tmpVal = parseWcPrice(total);
  }
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
    amount: tmpVal,
    settings: MoneyFormatterSettings(
      symbol: app_currency_symbol,
    ),
  );
  return fmf.output.symbolOnLeft;
}

openBrowserTab({@required String url}) async {
  await FlutterWebBrowser.openWebPage(
      url: url, androidToolbarColor: Colors.white70);
}

EdgeInsets safeAreaDefault() {
  return EdgeInsets.only(left: 16, right: 16, bottom: 8);
}

String trans(BuildContext context, String key) {
  return AppLocalizations.of(context).trans(key);
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

checkout(
    TaxRate taxRate,
    Function(String total, BillingDetails billingDetails, Cart cart)
        completeCheckout) async {
  String cartTotal = await CheckoutSession.getInstance
      .total(withFormat: false, taxRate: taxRate);
  BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails;
  Cart cart = Cart.getInstance;
  return await completeCheckout(cartTotal, billingDetails, cart);
}

double strCal({@required String sum}) {
  if (sum == null || sum == "") {
    return 0;
  }
  Parser p = Parser();
  Expression exp = p.parse(sum);
  ContextModel cm = ContextModel();
  return exp.evaluate(EvaluationType.REAL, cm);
}

Future<double> workoutShippingCostWC({@required String sum}) async {
  if (sum == null || sum == "") {
    return 0;
  }
  List<CartLineItem> cartLineItem = await Cart.getInstance.getCart();
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem
        .map((f) => f.quantity)
        .toList()
        .reduce((i, d) => i + d)
        .toString();
  });

  String orderTotal = await Cart.getInstance.getSubtotal();

  sum = sum.replaceAllMapped(defaultRegex(r'\[fee(.*)]'), (replace) {
    if (replace.groupCount < 1) {
      return "()";
    }
    String newSum = replace.group(1);

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent != null && replacePercent.groupCount >= 1) {
        String strPercentage = "( (" +
            orderTotal.toString() +
            " * " +
            replacePercent.group(1).toString() +
            ") / 100 )";
        double calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage < doubleMinFee) {
            return "(" + doubleMinFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage > doubleMaxFee) {
            return "(" + doubleMaxFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "(" + calPercentage.toString() + ")";
      }
      return "";
    });

    percentVal = percentVal
        .replaceAll(
            defaultRegex(r'(min_fee=\"([0-9\.]+)\"|max_fee=\"([0-9\.]+)\")'),
            "")
        .trim();
    return percentVal;
  });

  return strCal(sum: sum);
}

Future<double> workoutShippingClassCostWC(
    {@required String sum, List<CartLineItem> cartLineItem}) async {
  if (sum == null || sum == "") {
    return 0;
  }
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem
        .map((f) => f.quantity)
        .toList()
        .reduce((i, d) => i + d)
        .toString();
  });

  String orderTotal = await Cart.getInstance.getSubtotal();

  sum = sum.replaceAllMapped(defaultRegex(r'\[fee(.*)]'), (replace) {
    if (replace.groupCount < 1) {
      return "()";
    }
    String newSum = replace.group(1);

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent != null && replacePercent.groupCount >= 1) {
        String strPercentage = "( (" +
            orderTotal.toString() +
            " * " +
            replacePercent.group(1).toString() +
            ") / 100 )";
        double calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage < doubleMinFee) {
            return "(" + doubleMinFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum).group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage > doubleMaxFee) {
            return "(" + doubleMaxFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "(" + calPercentage.toString() + ")";
      }
      return "";
    });

    percentVal = percentVal
        .replaceAll(
            defaultRegex(r'(min_fee=\"([0-9\.]+)\"|max_fee=\"([0-9\.]+)\")'),
            "")
        .trim();
    return percentVal;
  });

  return strCal(sum: sum);
}

RegExp defaultRegex(
  String pattern, {
  bool strict,
}) {
  return new RegExp(
    pattern,
    caseSensitive: strict ?? false,
    multiLine: false,
  );
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(p);
  return regExp.hasMatch(em);
}

// 6 LENGTH, 1 DIGIT
bool validPassword(String pw) {
  String p = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
  RegExp regExp = new RegExp(p);
  return regExp.hasMatch(pw);
}

navigatorPush(BuildContext context,
    {@required String routeName,
    Object arguments,
    bool forgetAll = false,
    int forgetLast}) {
  if (forgetAll) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arguments ?? null);
  }
  if (forgetLast != null) {
    int count = 0;
    Navigator.of(context).popUntil((route) {
      return count++ == forgetLast;
    });
  }
  Navigator.of(context).pushNamed(routeName, arguments: arguments ?? null);
}

PlatformDialogAction dialogAction(BuildContext context,
    {@required title, ActionType actionType, Function() action}) {
  return PlatformDialogAction(
    actionType: actionType ?? ActionType.Default,
    child: Text(title ?? ""),
    onPressed: action ??
        () {
          Navigator.of(context).pop();
        },
  );
}

showPlatformAlertDialog(BuildContext context,
    {String title,
    String subtitle,
    List<PlatformDialogAction> actions,
    bool showDoneAction = true}) {
  if (showDoneAction) {
    actions
        .add(dialogAction(context, title: trans(context, "Done"), action: () {
      Navigator.of(context).pop();
    }));
  }
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return PlatformAlertDialog(
        title: Text(title ?? ""),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(subtitle ?? ""),
            ],
          ),
        ),
        actions: actions,
      );
    },
  );
}

DateTime parseDateTime(String strDate) {
  return DateTime.parse(strDate);
}

DateFormat formatDateTime(String format) {
  return DateFormat(format);
}

String dateFormatted({@required String date, @required String formatType}) {
  return formatDateTime(formatType).format(parseDateTime(date));
}

enum FormatType {
  DateTime,

  Date,

  Time,
}

String formatForDateTime(FormatType formatType) {
  switch (formatType) {
    case FormatType.Date:
      {
        return "yyyy-MM-dd";
      }
    case FormatType.DateTime:
      {
        return "dd-MM-yyyy hh:mm a";
      }
    case FormatType.Time:
      {
        return "hh:mm a";
      }
    default:
      {
        return "";
      }
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

double parseWcPrice(String price) => (double.tryParse(price) ?? 0);

Widget swiperProducts(context,
    {@required List<Product> products, @required onTap, key}) {
  List backgroundColor = [Colors.blue, Colors.orange, Colors.green, Colors.red];
  return Container(
    color: Colors.grey[200],
    height: 200,
    child: products.length == 0
        ? Container()
        : Swiper(
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      color: backgroundColor[index],
                      height: 150.0,
                      width: 150.0,
                      child: Column(
                        children: [
                          Text(
                            products[index].name,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Text(
                            app_currency_symbol + products[index].price,
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Positioned(
                  //   bottom:20,
                  //   child: Text(_products[index].name),
                  // ),
                  CachedNetworkImage(
                    imageUrl: products[index].images[0].src,
                    placeholder: (context, url) =>
                        Container(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
            itemCount: products == null ? 0 : products.length,
            pagination: new SwiperPagination(),
            itemWidth: MediaQuery.of(context).size.width,
            viewportFraction: 0.85,
            scale: 0.9,
            layout: SwiperLayout.STACK,
            autoplay: true,
            onTap: (index) => onTap(index),
          ),
  );
}

Widget pwproductList(context,
    {@required List<Product> products, @required onTap, key}) {
  return Container(
      // height: 185.0,
      child: (products.length != null && products.length > 0
          ? GridView.count(
            physics: NeverScrollableScrollPhysics(),
            primary: false,
              crossAxisCount: 2,
              children: List.generate(
                products.length,
                (index) {
                  return wsCardProductItem(context,
                      index: index, product: products[index], onTap: onTap);
                },
              ))
          : wsNoResults(context)));
}

Widget refreshableScroll(context,
    {@required refreshController,
    @required VoidCallback onRefresh,
    @required VoidCallback onLoading,
    @required List<Product> products,
    @required onTap,
    key}) {
  return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(trans(context, "pull up load"));
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(trans(context, "Load Failed! Click retry!"));
          } else if (mode == LoadStatus.canLoading) {
            body = Text(trans(context, "release to load more"));
          } else {
            body = Text(trans(context, "No more products"));
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: refreshController,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: (products.length != null && products.length > 0
          ? GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                products.length,
                (index) {
                  return wsCardProductItem(context,
                      index: index, product: products[index], onTap: onTap);
                },
              ))
          : wsNoResults(context)));
}

class UserAuth {
  UserAuth._privateConstructor();
  static final UserAuth instance = UserAuth._privateConstructor();

  String redirect = "/home";
}
