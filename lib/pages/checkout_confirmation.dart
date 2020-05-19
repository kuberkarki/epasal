

import 'package:flutter/material.dart';
import 'package:pasal1/app_payment_methods.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/models/checkout_session.dart';
import 'package:pasal1/models/customer_address.dart';
import 'package:pasal1/widgets/app_loader.dart';
import 'package:pasal1/widgets/buttons.dart';
import 'package:pasal1/widgets/pasal_widgets.dart';
import '../models/tax_rate.dart';
import 'package:pasal1/app_country_options.dart';

class CheckoutConfirmationPage extends StatefulWidget {
  CheckoutConfirmationPage({Key key}) : super(key: key);

  @override
  CheckoutConfirmationPageState createState() =>
      CheckoutConfirmationPageState();
}

class CheckoutConfirmationPageState extends State<CheckoutConfirmationPage> {
  CheckoutConfirmationPageState();

  bool _showFullLoader;

  List<TaxRate> _taxRates;
  TaxRate _taxRate;
  bool _isProcessingPayment;

  @override
  void initState() {
    super.initState();

    _showFullLoader = true;
    _isProcessingPayment = false;
    if (CheckoutSession.getInstance.paymentType == null) {
      CheckoutSession.getInstance.paymentType = arrPaymentMethods.first;
    }

    _getTaxes();
  }

  void reloadState({bool showLoader}) {
    setState(() {
      _showFullLoader = showLoader ?? false;
    });
  }

  _getTaxes() async {
    _taxRates = await appPasalConnector((api) {
      return api.getTaxRates(page: 1, perPage: 100);
    });

    if (CheckoutSession.getInstance.billingDetails.shippingAddress == null) {
      setState(() {
        _showFullLoader = false;
      });
      return;
    }
    String country =
        CheckoutSession.getInstance.billingDetails.shippingAddress.country;
    Map<String, dynamic> countryMap = appCountryOptions
        .firstWhere((c) => c['name'] == country, orElse: () => null);
    if (countryMap == null) {
      _showFullLoader = false;
      setState(() {});
      return;
    }
    String countryCode = countryMap["code"];

    TaxRate taxRate = _taxRates.firstWhere((t) => t.country == countryCode,
        orElse: () => null);

    if (taxRate != null) {
      _taxRate = taxRate;
    }
    setState(() {
      _showFullLoader = false;
    });
  }

  _actionCheckoutDetails() {
    Navigator.pushNamed(context, "/checkout-details").then((e) {
      _showFullLoader = true;
      _getTaxes();
    });
  }

  _actionPayWith() {
    Navigator.pushNamed(context, "/checkout-payment-type");
  }

  _actionSelectShipping() {
    CustomerAddress shippingAddress =
        CheckoutSession.getInstance.billingDetails.shippingAddress;
    if (shippingAddress == null || shippingAddress.country == "") {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Add your shipping details first"),
          icon: Icons.local_shipping);
      return;
    }
    Navigator.pushNamed(context, "/checkout-shipping-type").then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Image.asset('assets/images/logo.png',height: 40),
        centerTitle: true,
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: !_showFullLoader
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(trans(context, "Checkout"),
                        style: Theme.of(context).primaryTextTheme.subtitle1),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: wsBoxShadow()),
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ((CheckoutSession.getInstance.billingDetails
                                      .billingAddress !=
                                  null)
                              ? wsCheckoutRow(context,
                                  heading: trans(
                                      context, "Billing/shipping details"),
                                  leadImage: Icon(Icons.home),
                                  leadTitle: (CheckoutSession.getInstance
                                          .billingDetails.billingAddress
                                          .hasMissingFields()
                                      ? "Billing address is incomplete"
                                      : CheckoutSession.getInstance
                                          .billingDetails.billingAddress
                                          .addressFull()),
                                  action: _actionCheckoutDetails,
                                  showBorderBottom: true)
                              : wsCheckoutRow(context,
                                  heading: trans(
                                      context, "Billing/shipping details"),
                                  leadImage: Icon(Icons.home),
                                  leadTitle: trans(context,
                                      "Add billing & shipping details"),
                                  action: _actionCheckoutDetails,
                                  showBorderBottom: true)),
                          (CheckoutSession.getInstance.paymentType != null
                              ? wsCheckoutRow(context,
                                  heading: trans(context, "Payment method"),
                                  leadImage: Image(
                                      image: AssetImage("assets/images/" +
                                          CheckoutSession.getInstance
                                              .paymentType.assetImage),
                                      width: 70),
                                  leadTitle: CheckoutSession
                                      .getInstance.paymentType.desc,
                                  action: _actionPayWith,
                                  showBorderBottom: true)
                              : wsCheckoutRow(context,
                                  heading: trans(context, "Pay with"),
                                  leadImage: Icon(Icons.payment),
                                  leadTitle:
                                      trans(context, "Select a payment method"),
                                  action: _actionPayWith,
                                  showBorderBottom: true)),
                          (CheckoutSession.getInstance.shippingType != null
                              ? wsCheckoutRow(context,
                                  heading: trans(context, "Shipping selected"),
                                  leadImage: Icon(Icons.local_shipping),
                                  leadTitle: CheckoutSession
                                      .getInstance.shippingType
                                      .getTitle(),
                                  action: _actionSelectShipping)
                              : wsCheckoutRow(context,
                                  heading: trans(context, "Select shipping"),
                                  leadImage: Icon(Icons.local_shipping),
                                  leadTitle: trans(
                                      context, "Select a shipping option"),
                                  action: _actionSelectShipping)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
                      wsCheckoutSubtotalWidgetFB(
                          title: trans(context, "Subtotal")),
                      widgetCheckoutMeta(context,
                          title: trans(context, "Shipping fee"),
                          amount:
                              CheckoutSession.getInstance.shippingType == null
                                  ? trans(context, "Select shipping")
                                  : CheckoutSession.getInstance.shippingType
                                      .getTotal(withFormatting: true)),
                      (_taxRate != null
                          ? wsCheckoutTaxAmountWidgetFB(taxRate: _taxRate)
                          : Container()),
                      wsCheckoutTotalWidgetFB(
                          title: trans(context, "Total"), taxRate: _taxRate),
                      Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
                    ],
                  ),
                  wsPrimaryButton(context,
                      title: _isProcessingPayment
                          ? "PROCESSING..."
                          : trans(context, "CHECKOUT"),
                      action: _isProcessingPayment ? null : _handleCheckout),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showAppLoader(),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        trans(context, "One moment") + "...",
                        style: Theme.of(context).primaryTextTheme.subtitle1,
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  _handleCheckout() async {
    if (CheckoutSession.getInstance.billingDetails.billingAddress == null) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context,
              "Please select add your billing/shipping address to proceed"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.local_shipping);
      return;
    }

    if (CheckoutSession.getInstance.billingDetails.billingAddress
        .hasMissingFields()) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Your billing/shipping details are incomplete"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.local_shipping);
      return;
    }

    if (CheckoutSession.getInstance.shippingType == null) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Please select a shipping method to proceed"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.local_shipping);
      return;
    }

    if (CheckoutSession.getInstance.paymentType == null) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Please select a payment method to proceed"),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.payment);
      return;
    }

    if (_isProcessingPayment == true) {
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    CheckoutSession.getInstance.paymentType
        .pay(context, state: this, taxRate: _taxRate);

    Future.delayed(Duration(milliseconds: 5000), () {
      setState(() {
        _isProcessingPayment = false;
      });
    });
  }
}
