/* //
//  LabelCore

//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pasal1/helpers/data/order_wc.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/labelconfig.dart';
import 'package:pasal1/models/cart.dart';
import 'package:pasal1/pages/checkout_confirmation.dart';
import '../models/payload/order_wc.dart';
import '../models/order.dart';
import '../models/tax_rate.dart';
import 'package:woosignal_stripe/woosignal_stripe.dart';

stripePay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  try {
    // CONFIGURE STRIPE
    FlutterStripePayment.setStripeSettings(
        stripeAccount: app_stripe_account, liveMode: app_stripe_live_mode);

    var paymentResponse = await FlutterStripePayment.addPaymentMethod();

    // CHECK STATUS FROM STRIPE
    if (paymentResponse.status == PaymentResponseStatus.succeeded) {
      state.reloadState(showLoader: true);

      // CHECKOUT HELPER
      await checkout(taxRate, (total, billingDetails, cart) async {
        Map<String, dynamic> address = {
          "name": billingDetails.billingAddress.nameFull(),
          "line1": billingDetails.shippingAddress.addressLine,
          "city": billingDetails.shippingAddress.city,
          "postal_code": billingDetails.shippingAddress.postalCode,
          "country": billingDetails.shippingAddress.country
        };

        String cartShortDesc = await cart.cartShortDesc();

        dynamic rsp = await appPasalConnector((api) => api.stripePaymentIntent(
              amount: total,
              email: billingDetails.billingAddress.emailAddress,
              desc: cartShortDesc,
              shipping: address,
            ));

        if (rsp == null) {
          showEdgeAlertWith(context,
              title: trans(context, "Oops!"),
              desc: trans(context, "Something went wrong, please try again."),
              icon: Icons.payment,
              style: EdgeAlertStyle.WARNING);
          state.reloadState(showLoader: false);
          return;
        }

        String clientSecret = rsp["client_secret"];
        var intentResponse = await FlutterStripePayment.confirmPaymentIntent(
          clientSecret,
          paymentResponse.paymentMethodId,
          (double.parse(total) * 100),
        );

        if (intentResponse.status == PaymentResponseStatus.succeeded) {
          OrderWC orderWC = await buildOrderWC(taxRate: taxRate);
          Order order = await appPasalConnector((api) => api.createOrder(orderWC));

          if (order != null) {
            Cart.getInstance.clear();
            Navigator.pushNamed(context, "/checkout-status", arguments: order);
          } else {
            showEdgeAlertWith(
              context,
              title: trans(context, "Error"),
              desc: trans(
                  context,
                  trans(context,
                      "Something went wrong, please contact our store")),
            );
            state.reloadState(showLoader: false);
          }
        } else if (intentResponse.status == PaymentResponseStatus.failed) {
          if (app_debug) {
            print(intentResponse.errorMessage);
          }
          showEdgeAlertWith(
            context,
            title: trans(context, "Error"),
            desc: intentResponse.errorMessage,
          );
          state.reloadState(showLoader: false);
        } else {
          state.reloadState(showLoader: false);
        }
      });
    } else {
      state.reloadState(showLoader: false);
    }
  } catch (ex) {
    showEdgeAlertWith(context,
        title: trans(context, "Oops!"),
        desc: trans(context, "Something went wrong, please try again."),
        icon: Icons.payment,
        style: EdgeAlertStyle.WARNING);
    state.reloadState(showLoader: false);
  }
}
 */