import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class EncryptionUtils {
  static const String _encryptionKey =
      'm_6PvU5uL5kF9PQxCfF9pdKDY2U8uCL49ZXCAKuY0go=';
  //'dHVnYXNha2hpcmluZHJpYWJlcm5hZGVzaW51cmF5YTE='; //decode = tugasakhirindriabernadesinuraya1

  static Uint8List _decodeEncryptionKey() {
    final decodedKey = base64.decode(_encryptionKey);
    return Uint8List.fromList(decodedKey);
  }

  static Uint8List _generateIV() {
    final encryptionKey = _decodeEncryptionKey();
    return encryptionKey.sublist(0, 16);
  }

  static String encrypt(String value) {
    final key = _decodeEncryptionKey();
    final iv = _generateIV();
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(value, iv: IV(iv));
    return encrypted.base64;
  }

  static String decrypt(String value) {
    final key = _decodeEncryptionKey();
    final iv = _generateIV();
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final encrypted = Encrypted.fromBase64(value);
    final decrypted = encrypter.decrypt(encrypted, iv: IV(iv));
    return decrypted;
  }
}
