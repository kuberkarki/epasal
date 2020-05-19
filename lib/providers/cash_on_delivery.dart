//
//  LabelCore

//

import 'package:flutter/widgets.dart';
import 'package:pasal1/helpers/data/order_wc.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/models/cart.dart';
import 'package:pasal1/pages/checkout_confirmation.dart';
import '../models/payload/order_wc.dart';
import '../models/order.dart';
import '../models/tax_rate.dart';

cashOnDeliveryPay(context,
    {@required CheckoutConfirmationPageState state, TaxRate taxRate}) async {
  try {
    OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: false);

    Order order = await appPasalConnector((api) => api.createOrder(orderWC));

    if (order != null) {
      Cart.getInstance.clear();
      Navigator.pushNamed(context, "/checkout-status", arguments: order);
    } else {
      showEdgeAlertWith(
        context,
        title: trans(context, "Error"),
        desc: trans(context,
            trans(context, "Something went wrong, please contact our store")),
      );
      state.reloadState(showLoader: false);
    }
  } catch (ex) {
    showEdgeAlertWith(
      context,
      title: trans(context, "Error"),
      desc: trans(context,
          trans(context, "Something went wrong, please contact our store")),
    );
    state.reloadState(showLoader: false);
  }
}
