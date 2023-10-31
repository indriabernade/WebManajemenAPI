class Connection {
  static const hostConnection = "https://l2c.oss.myrepublic.co.id/tik/";
  static const hostConnectionUser = "$hostConnection/user/";

  static const register = "$hostConnectionUser/register.php";
  static const validate = "$hostConnectionUser/validate_email.php";
  static const login = "$hostConnectionUser/login.php";
  static const getData = "$hostConnectionUser/getdata.php";
  static const updateData = "$hostConnectionUser/update.php";
  static const deleteData = "$hostConnectionUser/delete.php";
  static const notice = "$hostConnectionUser/notify.php";
  static const deletenotice = "$hostConnectionUser/deletenotify.php";

  static const myrepData = "https://apicore.myrepublic.net.id/tyk/apis/";
  static const myrepReload =
      "https://apicore.myrepublic.net.id/tyk/reload/group";
  static const myrepKeys = "https://apicore.myrepublic.net.id/tyk/keys/create";
}
