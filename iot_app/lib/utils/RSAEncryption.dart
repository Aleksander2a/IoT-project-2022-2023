import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' show PublicKey, RSAEngine, RSAPublicKey;
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class RSAEncryption {
  late RSAPublicKey publicKey;
  late RSAPrivateKey privateKey;
  late Encrypter encrypter;


  RSAEncryption() {
    readKeys();
    encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));
  }

  Future<void> readKeys() async {
    publicKey = await parseKeyFromFile<RSAPublicKey>('assets/keys/esp_public_key.pem');
    privateKey = await parseKeyFromFile<RSAPrivateKey>('assets/keys/app_private_key.pem');
  }

  String encrypt(String data) {
    return encrypter.encrypt(data).base64;
  }

  String decrypt(String data) {
    Encrypted encrypted = Encrypted.fromBase64(data);
    return encrypter.decrypt(encrypted);
  }
}
