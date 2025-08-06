import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class globalAccountData {
  static SharedPreferences? _preferences;

  static const _username = 'name';
  static const _loginInState = 'LogInState';
  static const _email = 'email';
  static const _id = 'id';
  static const _activeStatus = 'status';
  static const _phone="phone";
  static const _adminPhone="adminPhone";
  static const _userPin="userPin";
  static const _showAgain="showAgain";
  static const _stateDialog="_stateDialog";
  static const _tokenKey = 'auth_token';
  static const _isAdmin = 'isAdmin';

  static Future<void> setToken(String token) async =>
      await _preferences?.setString(_tokenKey, token);

  static String? getToken() =>
      _preferences?.getString(_tokenKey);

  static Future init() async => _preferences = await SharedPreferences.getInstance();

  static Future setUsername(String username) async => await _preferences?.setString(_username, username);

  static String? getUsername() => _preferences?.getString(_username);

  static Future setUserPin(int userPin) async => await _preferences?.setInt(_userPin, userPin);

  static int? getUserPin() => _preferences?.getInt(_userPin);

  static Future setAdminPhone(String aminPhone) async => await _preferences?.setString(_adminPhone, aminPhone);

  static String? getAdminPhone() => _preferences?.getString(_adminPhone);

  static Future setLoginInState(bool loginInState) async => await _preferences?.setBool(_loginInState, loginInState);

  static bool? getLoginInState() => _preferences?.getBool(_loginInState);
  static Future setStateDialog(bool stateDialog) async => await _preferences?.setBool(_stateDialog,  stateDialog);

  static bool? getStateDialog() => _preferences?.getBool(_stateDialog);

  static Future setShowAgain(bool  showAgain) async => await _preferences?.setBool(_showAgain,  showAgain);

  static bool? getShowAgain() => _preferences?.getBool(_showAgain);

  static Future setEmail(String email) async => await _preferences?.setString(_email, email);

  static String? getPhone() => _preferences?.getString(_phone);

  static Future setPhone(String phone) async => await _preferences?.setString(_phone, phone);

  static String? getEmail() => _preferences?.getString(_email);
  static Future setId(String id) async => await _preferences?.setString(_id, id);

  static String? getId() => _preferences?.getString(_id);

  static Future setActiveStatus(String activeStatus) async => await _preferences?.setString(_activeStatus, activeStatus);

  static String? getActiveStatus() => _preferences?.getString(_activeStatus);

  static Future setIsAdmin(bool isAdmin) async => await _preferences?.setBool(_isAdmin, isAdmin);
  static bool getIsAdmin() => _preferences?.getBool(_isAdmin) ?? false;

}
