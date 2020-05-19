

import 'package:flutter/material.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/models/checkout_session.dart';
import 'package:pasal1/widgets/buttons.dart';
import 'package:pasal1/widgets/pasal_widgets.dart';

class CheckoutPaymentTypePage extends StatefulWidget {
  CheckoutPaymentTypePage();

  @override
  _CheckoutPaymentTypePageState createState() =>
      _CheckoutPaymentTypePageState();
}

class _CheckoutPaymentTypePageState extends State<CheckoutPaymentTypePage> {
  _CheckoutPaymentTypePageState();

  @override
  void initState() {
    super.initState();

    if (CheckoutSession.getInstance.paymentType == null) {
      if (getPaymentTypes() != null && getPaymentTypes().length > 0) {
        CheckoutSession.getInstance.paymentType = getPaymentTypes().first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(trans(context, "Payment Method"),
            style: Theme.of(context).primaryTextTheme.headline6),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  child: Center(
                    child: Image(
                        image: AssetImage("assets/images/credit_cards.png"),
                        fit: BoxFit.fitHeight,
                        height: 100),
                  ),
                  padding: EdgeInsets.only(top: 20),
                ),
                SizedBox(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: ListView.separated(
                            itemCount: getPaymentTypes().length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                contentPadding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 8, right: 8),
                                leading: Image(
                                    image: AssetImage("assets/images/" +
                                        getPaymentTypes()[index].assetImage),
                                    width: 60,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center),
                                title: Text(getPaymentTypes()[index].desc,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1),
                                selected: true,
                                trailing:
                                    (CheckoutSession.getInstance.paymentType ==
                                            getPaymentTypes()[index]
                                        ? Icon(Icons.check)
                                        : null),
                                onTap: () {
                                  CheckoutSession.getInstance.paymentType =
                                      getPaymentTypes()[index];
                                  Navigator.pop(context);
                                },
                              );
                            },
                            separatorBuilder: (cxt, i) {
                              return Divider(
                                color: Colors.black12,
                              );
                            },
                          ),
                        ),
                        wsLinkButton(context, title: trans(context, "CANCEL"),
                            action: () {
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: wsBoxShadow(),
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                  height: (constraints.maxHeight - constraints.minHeight) * 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
