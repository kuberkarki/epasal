

import 'dart:convert';

import 'package:pasal1/helpers/shared_pref.dart';
import 'package:pasal1/models/billing_details.dart';
import 'package:pasal1/models/cart.dart';
import 'package:pasal1/models/customer_address.dart';
import 'package:pasal1/models/payment_type.dart';
import 'package:pasal1/models/shipping_type.dart';
import '../models/tax_rate.dart';

import '../helpers/tools.dart';

class CheckoutSession {
  String sfKeyCheckout = "CS_BILLING_DETAILS";
  CheckoutSession._privateConstructor();
  static final CheckoutSession getInstance =
      CheckoutSession._privateConstructor();

  BillingDetails billingDetails;
  ShippingType shippingType;
  PaymentType paymentType;

  void initSession() {
    billingDetails = BillingDetails();
    shippingType = null;
  }

  void saveBillingAddress() {
    SharedPref sharedPref = SharedPref();
    CustomerAddress customerAddress =
        CheckoutSession.getInstance.billingDetails.billingAddress;

    String billingAddress = jsonEncode(customerAddress.toJson());
    sharedPref.save(sfKeyCheckout, billingAddress);
  }

  Future<CustomerAddress> getBillingAddress() async {
    SharedPref sharedPref = SharedPref();

    String strCheckoutDetails = await sharedPref.read(sfKeyCheckout);

    if (strCheckoutDetails != null && strCheckoutDetails != "") {
      return CustomerAddress.fromJson(jsonDecode(strCheckoutDetails));
    }
    return null;
  }

  void clearBillingAddress() {
    SharedPref sharedPref = SharedPref();
    sharedPref.remove(sfKeyCheckout);
  }

  Future<String> total({bool withFormat, TaxRate taxRate}) async {
    double totalCart = parseWcPrice(await Cart.getInstance.getTotal());
    double totalShipping = 0;
    if (shippingType != null && shippingType.object != null) {
      switch (shippingType.methodId) {
        case "flat_rate":
          totalShipping = parseWcPrice(shippingType.cost);
          break;
        case "free_shipping":
          totalShipping = parseWcPrice(shippingType.cost);
          break;
        case "local_pickup":
          totalShipping = parseWcPrice(shippingType.cost);
          break;
        default:
          break;
      }
    }

    double total = totalCart + totalShipping;

    if (taxRate != null) {
      String taxAmount = await Cart.getInstance.taxAmount(taxRate);
      total += parseWcPrice(taxAmount);
    }

    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toStringAsFixed(2);
  }
}
