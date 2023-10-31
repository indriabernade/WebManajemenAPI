class Connection {
  static const hostConnection = "http://localhost:8081/register_login/";
  static const hostConnectionUser = "$hostConnection/user/";

  static const register = "$hostConnectionUser/register.php";
  static const validate = "$hostConnectionUser/validate_email.php";
  static const login = "$hostConnectionUser/login.php";
  static const getData = "$hostConnectionUser/getdata.php";
  static const updateData = "$hostConnectionUser/update.php";
  static const deleteData = "$hostConnectionUser/delete.php";
  static const notice = "$hostConnectionUser/notify.php";
  static const deletenotice = "$hostConnectionUser/deletenotify.php";

  static const localData = "http://localhost:8080/tyk/apis";
  static const localReload = "http://localhost:8080/tyk/reload/?block=true";
  static const localKeys = "http://localhost:8080/tyk/keys/create";
  static const foo = '352d20ee67be67f6340b4c0605b044b7';

  static const authAPI = "http://localhost:9000/auth";
  static const validateAPI = "http://localhost:9000/email";
}
