

import 'package:flutter/material.dart';
import 'package:pasal1/helpers/shared_pref/sp_auth.dart';
import 'package:pasal1/labelconfig.dart';
import 'package:pasal1/widgets/menu_item.dart';
import 'package:pasal1/helpers/tools.dart';



class HomeMenuPage extends StatefulWidget {
  HomeMenuPage();

  @override
  _HomeMenuPageState createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {
  _HomeMenuPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(trans(context, "Menu"),
            style: Theme.of(context).primaryTextTheme.headline6),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png',height: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  (use_wp_login
                      ? wsMenuItem(context,
                          title: trans(context, "Profile"),
                          leading: Icon(Icons.account_circle),
                          action: _actionProfile)
                      : Container()),
                  wsMenuItem(context,
                      title: trans(context, "Cart"),
                      leading: Icon(Icons.shopping_cart),
                      action: _actionCart),
                  wsMenuItem(context,
                      title: trans(context, "About Us"),
                      leading: Icon(Icons.account_balance),
                      action: _actionAboutUs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _actionCart() {
    Navigator.pushNamed(context, "/cart");
  }

  void _actionAboutUs() {
    Navigator.pushNamed(context, "/about");
  }

  void _actionProfile() async {
    if (use_wp_login == true && !(await authCheck())) {
      UserAuth.instance.redirect = "/account-detail";
      Navigator.pushNamed(context, "/account-landing");
      return;
    }
    Navigator.pushNamed(context, "/account-detail");
  }
}
