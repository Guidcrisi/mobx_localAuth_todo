import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:todomobx/stores/login_store.dart';
import 'package:todomobx/widgets/custom_icon_button.dart';
import 'package:todomobx/widgets/custom_text_field.dart';

import 'list_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginStore loginStore;

  late ReactionDisposer disposer;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool deviceSupported = false;

  Future<List<BiometricType>> _initBiometrics() async {
    deviceSupported = await _localAuth.isDeviceSupported();
    List<BiometricType> _availableBiometrics = <BiometricType>[];
    if (deviceSupported) {
      try {
        if (await _localAuth.canCheckBiometrics) {
          _availableBiometrics = await _localAuth.getAvailableBiometrics();
        }
        return _availableBiometrics;
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Future<void> _auth() async {
    bool authentication = false;
    try {
      authentication = await _localAuth.authenticate(
          localizedReason: "Use sua digital para efetuar login",
          androidAuthStrings: const AndroidAuthMessages(
              signInTitle: "Autenticação por necessária",
              biometricHint: "Use sua digital para autenticar"),
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
      if (authentication) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ListScreen()));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loginStore = Provider.of<LoginStore>(context);
    disposer = reaction((_) => loginStore.loggedIn, (bool loggedIn) {
      if (loggedIn) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => ListScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(32),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 16,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Observer(builder: (_) {
                      return CustomTextField(
                        hint: 'E-mail',
                        prefix: Icon(Icons.account_circle),
                        textInputType: TextInputType.emailAddress,
                        onChanged: loginStore.setEmail,
                        enabled: !loginStore.isLoading,
                      );
                    }),
                    const SizedBox(
                      height: 16,
                    ),
                    Observer(builder: (_) {
                      return CustomTextField(
                        hint: 'Senha',
                        prefix: Icon(Icons.lock),
                        obscure: loginStore.isHidden,
                        onChanged: loginStore.setPassword,
                        enabled: !loginStore.isLoading,
                        suffix: CustomIconButton(
                          radius: 32,
                          iconData: loginStore.isHidden
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onTap: loginStore.setHidden,
                        ),
                      );
                    }),
                    const SizedBox(
                      height: 16,
                    ),
                    Observer(builder: (_) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 44,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: loginStore.isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text("Login"),
                              color: Theme.of(context).primaryColor,
                              disabledColor:
                                  Theme.of(context).primaryColor.withAlpha(100),
                              textColor: Colors.white,
                              onPressed: loginStore.isFormValid
                                  ? () {
                                      loginStore.login();
                                      /*
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => ListScreen()));
                                          */
                                    }
                                  : null,
                            ),
                          ),
                          FutureBuilder<List<BiometricType>>(
                              future: _initBiometrics(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<BiometricType>> snapshot) {
                                if (snapshot.hasData) {
                                  if (!deviceSupported) {
                                    return Container();
                                  }
                                  return IconButton(
                                      onPressed: () async {
                                        await _auth();
                                      },
                                      icon: const Icon(
                                        Icons.fingerprint,
                                        size: 30,
                                      ));
                                } else {
                                  return Container();
                                }
                              })
                        ],
                      );
                    })
                  ],
                ),
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    disposer();
    super.dispose();
  }
}
