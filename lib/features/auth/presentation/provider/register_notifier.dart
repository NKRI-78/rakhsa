import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/promt_helper.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';

import 'package:firebase_auth/firebase_auth.dart' as fa;

import 'package:rakhsa/features/auth/domain/usecases/register.dart';
import 'package:rakhsa/features/auth/presentation/pages/register_otp.dart';
import 'package:rakhsa/features/document/domain/usecase/update_passport_use_case.dart';
import 'package:rakhsa/features/media/domain/usecases/upload_media.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/websockets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RegisterNotifier with ChangeNotifier {
  final UploadMediaUseCase mediaUseCase;
  final UpdatePassportUseCase updatePassport;

  final WebSocketsService webSocketsService;
  final RegisterUseCase useCase;
  final Gemini gemini;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  // media passport 
  String _mediaPassport = '';
  String get mediaPassport => _mediaPassport;

  // media avatar 
  String _mediaAvatar = '';
  String get mediaAvatar => _mediaAvatar;

   // register google
  bool _ssoLoading = false;
  bool get ssoLoading => _ssoLoading;

  // user
  fa.User? _userGoogle;
  fa.User? get userGoogle => _userGoogle;

  // register passport
  Passport? _passport;
  Passport? get passport => _passport;
  bool get hasPassport => _passport != null;

  // path
  String _passportPath = '';
  String get passportPath => _passportPath;
  bool get hasPath => _passportPath.isNotEmpty;

  // panel controller
  final _panelMinHeightActualy = kBottomNavigationBarHeight + 24;
  double _panelMinHeight = 0.0;
  double get panelMinHeight => _panelMinHeight;
  late PanelController _panelController;
  PanelController get panelController => _panelController;
  void registerPanelController(PanelController controller) {
    _panelController = controller;
  }

  RegisterNotifier({
    required this.mediaUseCase,
    required this.updatePassport,
    required this.webSocketsService,
    required this.useCase,
    required this.googleSignIn,
    required this.firebaseAuth,
    required this.gemini,
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> register(
      {
    required String countryCode,
    required String passportNumber,
    required String fullName,
    required String nasionality,
    required String placeOfBirth,
    required String dateOfBirth,
    required String gender,
    required String dateOfIssue,
    required String dateOfExpiry,
    required String registrationNumber,
    required String issuingAuthority,
    required String mrzCode,
    required String email,
    required String emergencyContact,
    required String password,
  }) async {
    setStateProviderState(ProviderState.loading);

    final register = await useCase.execute(
      countryCode: countryCode,
        passportNumber: passportNumber,
        fullName: fullName,
        nasionality: nasionality,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        gender: gender,
        dateOfIssue: dateOfIssue,
        dateOfExpiry: dateOfExpiry,
        registrationNumber: registrationNumber,
        issuingAuthority: issuingAuthority,
        mrzCode: mrzCode,
        email: email,
        emergencyContact: emergencyContact,
        password: password
    );

    register.fold((l) {
      _message = l.message;
      setStateProviderState(ProviderState.error);
    }, (r) {
      _authModel = r;

      StorageHelper.saveUserId(userId: authModel.data?.user.id ?? "-");
      StorageHelper.saveUserEmail(email: authModel.data?.user.email ?? "-");
      StorageHelper.saveUserPhone(phone: authModel.data?.user.phone ?? "-");

      webSocketsService.join();

      ShowSnackbar.snackbarOk(
          "Silahkan periksa alamat E-mail $email untuk mengisi kode otp yang telah dikirimkan");

      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) {
          return RegisterOtp(email: email);
        }),
        (route) => false,
      );

      setStateProviderState(ProviderState.loaded);
    });
  }


  Future<void> registerWithGoogle(BuildContext context) async {
    bool hasUser = firebaseAuth.currentUser != null;

    if (hasUser) {
      // navigate to register page
      Navigator.pushNamed(context, RoutesNavigation.scanRegisterPassport);
    } else {
      final connection = await Connectivity().checkConnectivity();
      if (connection == ConnectivityResult.mobile ||
          connection == ConnectivityResult.wifi ||
          connection == ConnectivityResult.vpn) {
        try {
          _ssoLoading = true;
          notifyListeners();

          final gUser = await googleSignIn.signIn();

          final gAuth = await gUser?.authentication;

          final credential = fa.GoogleAuthProvider.credential(
            accessToken: gAuth?.accessToken,
            idToken: gAuth?.idToken,
          );

          final user = await firebaseAuth.signInWithCredential(credential);

          _userGoogle = user.user;
          notifyListeners();

          ShowSnackbar.snackbarOk(
              'Berhasil login sebagai ${user.user?.email}');
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, RoutesNavigation.scanRegisterPassport);
        } on fa.FirebaseException catch (e) {
          _ssoLoading = false;
          notifyListeners();

          ShowSnackbar.snackbarErr('Kesalahan authentikasi ${e.code}');
        } catch (e) {
          _ssoLoading = false;
          notifyListeners();
        } finally {
          _ssoLoading = false;
          notifyListeners();
        }
      } else {
        // show snackbar
        ShowSnackbar.snackbarErr('Tidak ada koneksi internet');
      }
    }
  }

  Future<void> startScan(BuildContext context, String userId) async {
    try {
      final scanResult = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
        noOfPages: 1,
      );

      if (scanResult != null) {
        _passportPath = scanResult.last;
        notifyListeners();

        // start extract data
        final passport = await _launchPromt(
          documentPath: scanResult.last,
          errorCallback: (e) {
            debugPrint(e.toString());

            FailureDocumentDialog.launch(
              context,
              title: 'Kesalahan Ekstraksi Data Paspor',
              content:
                  'Kami mengalami kendala saat memproses paspor Anda. Pastikan gambar jelas dan tidak buram, lalu coba lagi. [${e.toString()}]',
              actionCallback: () async {
                Navigator.of(context).pop(); // close dialog
                await startScan(context, userId);
              },
            );
          },
          passportCallback: (e) {
            FailureDocumentDialog.launch(
              context,
              title: 'Data Tidak Valid',
              content: e,
              actionCallback: () async {
                Navigator.of(context).pop(); // close dialog
                await startScan(context, userId);
              },
            );
          },
        );

        // valid response
        if (passport != null) {

          final uploadPassportToServer = await mediaUseCase.execute(
            file: File(_passportPath),
            folderName: 'passport',
          );
          
          uploadPassportToServer.fold((failure) {
            ShowSnackbar.snackbarErr(failure.message);
            notifyListeners();
          }, (picture) async {
            _mediaPassport = picture.path; 
            notifyListeners();
          });

          _passport = passport;
          _panelMinHeight = _panelMinHeightActualy;
          notifyListeners();

          // open panel
          _panelController.open();
        }
      }
    } catch (e) {
      // kondisi untuk catch error dari _launchPromt
      // karena error pada launch promt mengembalikan null
      // progam ini hanya untuk error pada scan document
      if (_passport == null) {
        _passportPath = '';

        // back to previous page
        if (context.mounted) Navigator.of(context).pop();
        await Future.delayed(const Duration(seconds: 1), () {
          ShowSnackbar.snackbarDefault('Register Paspor Dibatalkan');
        });
      }
    }
  }

  void deleteData() {
    _passportPath = '';
    _passport = null;
    _panelMinHeight = 0.0;
  }

  Future<Passport?> _launchPromt({
    required String documentPath,
    ValueChanged<String>? passportCallback,
    ValueChanged<String>? errorCallback,
  }) async {
    log('memulai scanning');
    try {
      // scan promt
      final scanResult = await gemini.prompt(
        model: 'gemini-1.5-pro',
        generationConfig: GenerationConfig(temperature: 0),
        parts: [
          Part.bytes(await File(documentPath).readAsBytes()),
          Part.text(PromptHelper.getPromt()),
        ],
      );

      if (int.tryParse(scanResult?.output ?? '400') == 400) {
        _resetScan();

        // show wrong document callback
        passportCallback?.call(
          'Dokumen yang Anda Pindai Terdeketsi Bukan Passpor, Berikan Dokumen Paspor yang Benar',
        );

        return null;
      } else {
        final rawJson = scanResult?.output;
        log('raw data = $rawJson');

        final filteredJson = rawJson?.substring(8).replaceAll('```', '');
        log('paspor = $filteredJson');

        Map<String, dynamic> passportData = jsonDecode(filteredJson ?? '');

        if (passportData['mrzCode'] == null ||
            (passportData['mrzCode'] as String).isEmpty) {
          throw PassportException(
              'Kode MRZ tidak terbaca. Harap pindai ulang paspor dengan jelas.');
        } else if ((passportData['mrzCode'] as String)[0].contains('V')) {
          throw PassportException(
              'MRZ terdeteksi sebagai visa. Harap masukkan paspor yang valid.');
        } else if ((passportData['mrzCode'] as String)[0].contains('P')) {
          return Passport.fromMap(passportData);
        } else {
          throw PassportException(
              'Kode MRZ tidak lengkap atau tidak jelas. '
              'Pastikan seluruh bagian MRZ di bagian bawah paspor terlihat jelas dalam satu frame, tidak terpotong, dan cahaya cukup. '
              'Pegang perangkat dengan stabil dan coba pindai ulang.'
            );
        }
      }
    } on GeminiException catch (e) {
      log('gemini exception = ${e.message.toString()}');

      _resetScan();

      // show dialog
      errorCallback?.call('Kesalahan Server');

      return null;
    } on PassportException catch (e) {
      log('passport exception = ${e.toString()}');

      _resetScan();

      // show dialog
      passportCallback?.call(e.message);

      // exception
      return null;
    } on FormatException catch (e) {
      log('format exception = ${e.toString()}');

      _resetScan();

      // show dialog
      errorCallback?.call('Kesalahan Proses Pemformatan');

      // exception
      return null;
    } catch (e) {
      log('exception = ${e.toString()}');

      _resetScan();

      // show dialog
      errorCallback?.call('Kesalahan yang tidak diketahui');

      // exception
      return null;
    }
  }

  void _resetScan() {
    _passportPath = '';
    notifyListeners();
  }

}

class FailureDocumentDialog extends StatelessWidget {
  const FailureDocumentDialog({
    super.key,
    required this.actionCallback,
    required this.title,
    required this.content,
  });

  final VoidCallback actionCallback;
  final String title;
  final String content;

  static void launch(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback actionCallback,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: FailureDocumentDialog(
            title: title,
            content: content,
            actionCallback: actionCallback,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.only(
              top: 60.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 5,
                      child: CustomButton(
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.grey,
                        btnTextColor: ColorResources.white,
                        onTap: () {
                          Navigator.of(context).pop(); // close dialog
                          Navigator.of(context).pop(); // back
                        },
                        btnTxt: 'Kembali',
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Expanded(
                      flex: 5,
                      child: CustomButton(
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.error,
                        btnTextColor: ColorResources.white,
                        onTap: actionCallback,
                        btnTxt: "Scan Ulang",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -50,
            child: Image.asset(
              AssetSource.iconAlert,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}