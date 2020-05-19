

import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/models/payment_type.dart';
import 'package:pasal1/providers/cash_on_delivery.dart';
// import 'package:pasal1/providers/stripe_pay.dart';

// Payment methods available for uses in the app

List<PaymentType> arrPaymentMethods = [
  // addPayment(
  //   PaymentType(
  //     id: 1,
  //     name: "Stripe",
  //     desc: "Debit or Credit Card",
  //     assetImage: "dark_powered_by_stripe.png",
  //     pay: stripe,
  //   ),
  // ),

  addPayment(
    PaymentType(
      id: 2,
      name: "CashOnDelivery",
      desc: "Cash on delivery",
      assetImage: "cash_on_delivery.jpeg",
      pay: cashOnDeliveryPay,
    ),
  ),

  // e.g. add more here

//  addPayment(
//    PaymentType(
//      id: 3,
//      name: "MyNewPaymentMethod",
//      desc: "Debit or Credit Card",
//      assetImage: "add icon image to assets/images/myimage.png",
//      pay: stripePay
//    ),
//  ),
];
