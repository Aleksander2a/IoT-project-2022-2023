import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' show PublicKey, RSAEngine, RSAPublicKey;
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class AESEncryption {
  late Key key;
  late IV iv;
  late Encrypter encrypter;

  AESEncryption() {
    key = Key.fromUtf8('my 32 length key................');
    iv = IV.fromUtf8('my 16 length iv!');
    encrypter = Encrypter(AES(key));
  }

  String encrypt(String data) {
    return encrypter.encrypt(data, iv: iv).base64;
  }

  String decrypt(String data) {
    Encrypted encrypted = Encrypted.fromBase64(data);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}