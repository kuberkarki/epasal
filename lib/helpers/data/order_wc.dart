

import 'dart:io';

import 'package:pasal1/helpers/shared_pref/sp_user_id.dart';
import 'package:pasal1/labelconfig.dart';
import 'package:pasal1/models/billing_details.dart';
import 'package:pasal1/models/cart.dart';
import 'package:pasal1/models/cart_line_item.dart';
import 'package:pasal1/models/checkout_session.dart';
import '../../models/payload/order_wc.dart';
import '../../models/tax_rate.dart';

Future<OrderWC> buildOrderWC({TaxRate taxRate, bool markPaid = true}) async {
  OrderWC orderWC = OrderWC();

  String paymentMethodName = CheckoutSession.getInstance.paymentType.name ?? "";

  orderWC.paymentMethod = Platform.isAndroid
      ? "$paymentMethodName - Android App"
      : "$paymentMethodName - IOS App";

  orderWC.paymentMethodTitle = paymentMethodName.toLowerCase();

  orderWC.setPaid = markPaid;
  orderWC.status = "pending";
  orderWC.currency = app_currency_iso.toUpperCase();
  orderWC.customerId =
      (use_wp_login == true) ? int.parse(await readUserId()) : 0;

  List<LineItems> lineItems = [];
  List<CartLineItem> cartItems = await Cart.getInstance.getCart();
  cartItems.forEach((cartItem) {
    LineItems tmpLineItem = LineItems();
    tmpLineItem.quantity = cartItem.quantity;
    tmpLineItem.name = cartItem.name;
    tmpLineItem.productId = cartItem.productId;
    if (cartItem.variationId != null && cartItem.variationId != 0) {
      tmpLineItem.variationId = cartItem.variationId;
    }

    tmpLineItem.total =
        (cartItem.quantity > 1 ? cartItem.getCartTotal() : cartItem.subtotal);
    tmpLineItem.subtotal = cartItem.subtotal;

    lineItems.add(tmpLineItem);
  });

  orderWC.lineItems = lineItems;

  BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails;

  Billing billing = Billing();
  billing.firstName = billingDetails.billingAddress.firstName;
  billing.lastName = billingDetails.billingAddress.lastName;
  billing.address1 = billingDetails.billingAddress.addressLine;
  billing.city = billingDetails.billingAddress.city;
  billing.postcode = billingDetails.billingAddress.postalCode;
  billing.country = billingDetails.billingAddress.country;
  billing.email = billingDetails.billingAddress.emailAddress;

  orderWC.billing = billing;

  Shipping shipping = Shipping();
  shipping.firstName = billingDetails.shippingAddress.firstName;
  shipping.lastName = billingDetails.shippingAddress.lastName;
  shipping.address1 = billingDetails.shippingAddress.addressLine;
  shipping.city = billingDetails.shippingAddress.city;
  shipping.postcode = billingDetails.shippingAddress.postalCode;
  shipping.country = billingDetails.shippingAddress.country;

  orderWC.shipping = shipping;

  orderWC.shippingLines = [];
  Map<String, dynamic> shippingLineFeeObj =
      CheckoutSession.getInstance.shippingType.toShippingLineFee();
  if (shippingLineFeeObj != null) {
    ShippingLines shippingLine = ShippingLines();
    shippingLine.methodId = shippingLineFeeObj['method_id'];
    shippingLine.methodTitle = shippingLineFeeObj['method_title'];
    shippingLine.total = shippingLineFeeObj['total'];
    orderWC.shippingLines.add(shippingLine);
  }

  if (taxRate != null) {
    orderWC.feeLines = [];
    FeeLines feeLines = FeeLines();
    feeLines.name = taxRate.name;
    feeLines.total = await Cart.getInstance.taxAmount(taxRate);
    feeLines.taxClass = "";
    feeLines.taxStatus = "taxable";
    orderWC.feeLines.add(feeLines);
  }

  return orderWC;
}
