import 'dart:ffi';

import 'package:mobx/mobx.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  @observable
  bool isHidden = true;
  @action
  void setHidden() => isHidden = !isHidden;
  @observable
  bool isLoading = false;
  @observable
  String email = "";
  @action
  void setEmail(String value) => email = value;
  @observable
  String password = "";
  @observable
  bool loggedIn = false;
  @action
  void setPassword(String value) => password = value;
  @computed
  bool get isEmailValid => email.contains("@");
  @computed
  bool get isPasswordValid => password.length > 6;
  @computed
  bool get isFormValid => isEmailValid && isPasswordValid;
  @action
  Future<void> login() async {
    isLoading = true;
    await Future.delayed(Duration(seconds: 2));
    isLoading = false;
    loggedIn = true;
    email = "";
    password = "";
  }

  @action
  void logout() {
    loggedIn = false;
  }
}
