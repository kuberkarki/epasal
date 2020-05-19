

import 'package:flutter/material.dart';
import 'package:pasal1/helpers/shared_pref/sp_auth.dart';
import 'package:pasal1/helpers/shared_pref/sp_user_id.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/labelconfig.dart';
import 'package:pasal1/widgets/buttons.dart';
import 'package:pasal1/widgets/pasal_widgets.dart';
import '../helpers/shared_pref.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
// import 'package:wp_json_api/models/responses/WPUserRegisterResponse.dart';
// import 'package:wp_json_api/wp_json_api.dart';

class AccountRegistrationPage extends StatefulWidget {
  AccountRegistrationPage();

  @override
  _AccountRegistrationPageState createState() =>
      _AccountRegistrationPageState();
}

class _AccountRegistrationPageState extends State<AccountRegistrationPage> {
  _AccountRegistrationPageState();

  bool _hasTappedRegister;
  TextEditingController _tfEmailAddressController;
  TextEditingController _tfPasswordController;
  TextEditingController _tfFirstNameController;
  TextEditingController _tfLastNameController;

  @override
  void initState() {
    super.initState();

    _hasTappedRegister = false;
    _tfEmailAddressController = TextEditingController();
    _tfPasswordController = TextEditingController();
    _tfFirstNameController = TextEditingController();
    _tfLastNameController = TextEditingController();
  }


// wp.WordPress wordPress;

// adminName and adminKey is needed only for admin level APIs
wp.WordPress wordPress = wp.WordPress(
  baseUrl: app_base_url,
  authenticator: wp.WordPressAuthenticator.ApplicationPasswords,
  adminName: 'mobile',
  adminKey: admintoken,
);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Register",
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: wsTextEditingRow(context,
                          heading: trans(context, "First Name"),
                          controller: _tfFirstNameController,
                          shouldAutoFocus: true,
                          keyboardType: TextInputType.text),
                    ),
                    Flexible(
                      child: wsTextEditingRow(context,
                          heading: trans(context, "Last Name"),
                          controller: _tfLastNameController,
                          shouldAutoFocus: false,
                          keyboardType: TextInputType.text),
                    ),
                  ],
                )),
            wsTextEditingRow(
              context,
              heading: trans(context, "Email address"),
              controller: _tfEmailAddressController,
              shouldAutoFocus: false,
              keyboardType: TextInputType.emailAddress,
            ),
            wsTextEditingRow(
              context,
              heading: trans(context, "Password"),
              controller: _tfPasswordController,
              shouldAutoFocus: true,
              obscureText: true,
            ),
            Padding(
              child: wsPrimaryButton(context,
                  title: trans(context, "Sign up"),
                  action: _hasTappedRegister ? null : _signUpTapped),
              padding: EdgeInsets.only(top: 10),
            ),
            Padding(
              child: InkWell(
                child: RichText(
                  text: TextSpan(
                    text: trans(
                            context, "By tapping \"Register\" you agree to ") +
                        app_name +
                        '\'s ',
                    children: <TextSpan>[
                      TextSpan(
                          text: trans(context, "terms and conditions"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '  ' + trans(context, "and") + '  '),
                      TextSpan(
                          text: trans(context, "privacy policy"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                    style: TextStyle(color: Colors.black45),
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: _viewTOSModal,
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ],
        ),
      ),
    );
  }

  _signUpTapped() async {
    String email = _tfEmailAddressController.text;
    String password = _tfPasswordController.text;
    String firstName = _tfFirstNameController.text;
    String lastName = _tfLastNameController.text;

    if (!isEmail(email)) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "That email address is not valid"),
          style: EdgeAlertStyle.DANGER);
      return;
    }

    if (password.length <= 5) {
      showEdgeAlertWith(context,
          title: trans(context, "Oops"),
          desc: trans(context, "Password must be a min 6 characters"),
          style: EdgeAlertStyle.DANGER);
      return;
    }

    if (_hasTappedRegister == false) {
      setState(() {
        _hasTappedRegister = true;
      });

      String username =
          (email.replaceAll(new RegExp(r'(@|\.)'), "")) + randomStr(4);

      // WPUserRegisterResponse wpUserRegisterResponse = await WPJsonAPI.instance
      //     .api((request) => request.wpRegister(
      //         email: email.toLowerCase(),
      //         password: password,
      //         username: username));
      var wpUserRegisterResponse=await wordPress.createUser(
      user: wp.User(
        email: email.toLowerCase(),
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName
      )
    );
    print(wpUserRegisterResponse);

      if (wpUserRegisterResponse != null) {
        wp.User wcCustomerInfoResponse=await wordPress.fetchUser(email: email.toLowerCase());
        String token = wcCustomerInfoResponse.id.toString();
        authUser(token);
        storeUserId(token);

        // await WPJsonAPI.instance.api((request) => request
        //     .wpUpdateUserInfo(token, firstName: firstName, lastName: lastName));

        showEdgeAlertWith(context,
            title: trans(context, "Hello") + " $firstName",
            desc: trans(context, "you're now logged in"),
            style: EdgeAlertStyle.SUCCESS,
            icon: Icons.account_circle);
        navigatorPush(context,
            routeName: UserAuth.instance.redirect, forgetLast: 2);
      } else {
        setState(() {
          showEdgeAlertWith(context,
              title: trans(context, "Invalid"),
              desc: trans(context, "Please check your details"),
              style: EdgeAlertStyle.WARNING);
          _hasTappedRegister = false;
        });
      }
    }
  }

  _viewTOSModal() {
    showPlatformAlertDialog(context,
        title: trans(context, "Actions"),
        subtitle: trans(context, "View Terms and Conditions or Privacy policy"),
        actions: [
          dialogAction(context,
              title: trans(context, "Terms and Conditions"),
              action: _viewTermsConditions),
          dialogAction(context,
              title: trans(context, "Privacy Policy"),
              action: _viewPrivacyPolicy),
        ]);
  }

  void _viewTermsConditions() {
    Navigator.pop(context);
    openBrowserTab(url: app_terms_url);
  }

  void _viewPrivacyPolicy() {
    Navigator.pop(context);
    openBrowserTab(url: app_privacy_url);
  }
}
