

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pasal1/helpers/shared_pref/sp_auth.dart';
import 'package:pasal1/helpers/shared_pref/sp_user_id.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/labelconfig.dart';
import 'package:pasal1/widgets/buttons.dart';
import 'package:pasal1/widgets/pasal_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wp_json_api/models/responses/WPUserLoginResponse.dart';
import 'package:wp_json_api/wp_json_api.dart';

import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;

class AccountLandingPage extends StatefulWidget {
  AccountLandingPage();

  @override
  _AccountLandingPageState createState() => _AccountLandingPageState();
}

class _AccountLandingPageState extends State<AccountLandingPage> {
  bool _hasTappedLogin;
  TextEditingController _tfEmailController;
  TextEditingController _tfPasswordController;

  @override
  void initState() {
    super.initState();

    _hasTappedLogin = false;
    _tfEmailController = TextEditingController();
    _tfPasswordController = TextEditingController();
  }

  wp.WordPress wordPress = wp.WordPress(
  baseUrl: app_base_url,
  authenticator: wp.WordPressAuthenticator.ApplicationPasswords,
  adminName: 'mobile',
  adminKey: admintoken,
);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                 Image.asset('assets/images/logo.png',height: 40),
                  Flexible(
                    child: Container(
                      height: 70,
                      padding: EdgeInsets.only(bottom: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        trans(context, "Login"),
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline4
                            .copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: wsBoxShadow(),
                        color: Colors.white),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        wsTextEditingRow(context,
                            heading: trans(context, "Email"),
                            controller: _tfEmailController,
                            keyboardType: TextInputType.emailAddress),
                        wsTextEditingRow(context,
                            heading: trans(context, "Password"),
                            controller: _tfPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true),
                        wsPrimaryButton(
                          context,
                          title: trans(context, "Login"),
                          action: _hasTappedLogin == true ? null : _loginUser,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FlatButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    color: Colors.black38,
                  ),
                  Padding(
                    child: Text(
                      trans(context, "Create an account"),
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                    ),
                    padding: EdgeInsets.only(left: 8),
                  )
                ],
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/account-register");
              },
            ),
            wsLinkButton(context, title: trans(context, "Forgot Password"),
                action: () {
              launch(app_forgot_password_url);
            }),
            Divider(),
            wsLinkButton(context, title: trans(context, "Back"), action: () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  _loginUser() async {
    String email = _tfEmailController.text;
    String password = _tfPasswordController.text;

    if (_hasTappedLogin == false) {
      setState(() {
        _hasTappedLogin = true;
      });

      // WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance
      //     .api((request) => request.wpLogin(email: email, password: password));

      wp.User wpUserLoginResponse=await wordPress.authenticateUser(username: email, password: password);
      // print(wordPress.fetchUser();
      
        
        // wordPress.getToken();
      _hasTappedLogin = false;

      if (wpUserLoginResponse != null) {
        String token = wpUserLoginResponse.id.toString();
        authUser(token);
        storeUserId(wpUserLoginResponse.id.toString());

        showEdgeAlertWith(context,
            title: trans(context, "Hello"),
            desc: trans(context, "Welcome back"),
            style: EdgeAlertStyle.SUCCESS,
            icon: Icons.account_circle);
        navigatorPush(context,
            routeName: UserAuth.instance.redirect, forgetLast: 1);
      } else {
        showEdgeAlertWith(context,
            title: trans(context, "Oops!"),
            desc: trans(context, "Invalid login credentials"),
            style: EdgeAlertStyle.WARNING,
            icon: Icons.account_circle);
        setState(() {
          _hasTappedLogin = false;
        });
      }
    }
  }
}
