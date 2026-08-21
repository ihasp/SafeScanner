// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Escáner QR';

  @override
  String get navScan => 'Escanear';

  @override
  String get navGallery => 'Galería';

  @override
  String get navResults => 'Resultados';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get scannerPreferences => 'Preferencias del escáner';

  @override
  String get defaultCamera => 'Cámara predeterminada';

  @override
  String get cameraBack => 'Trasera';

  @override
  String get cameraFront => 'Frontal';

  @override
  String get defaultScanMode => 'Modo predeterminado';

  @override
  String get scanModeQr => 'QR';

  @override
  String get scanModeCrypto => 'Cripto';

  @override
  String get hapticsOnScan => 'Vibración al escanear';

  @override
  String get hapticsSubtitle => 'Vibrar en éxito/error';

  @override
  String get autoOpenSafeLinks => 'Abrir enlaces seguros automáticamente';

  @override
  String get autoOpenSubtitle => 'Abrir en navegador si hay 0 amenazas';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Elegir idioma de la aplicación';

  @override
  String get systemLanguage => 'Predeterminado del sistema';

  @override
  String get langEn => 'English';

  @override
  String get langPl => 'Polski';

  @override
  String get langEs => 'Español';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langFr => 'Français';

  @override
  String get langIt => 'Italiano';

  @override
  String get langPt => 'Português';

  @override
  String get cameraAccessRequired => 'Acceso a la cámara necesario';

  @override
  String get cameraAccessDesc =>
      'La aplicación necesita acceso a la cámara para escanear códigos QR y direcciones de criptomonedas.';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String get galleryPermissionNeeded => 'Permiso de galería necesario';

  @override
  String get galleryPermissionDesc =>
      'Permite el acceso a tus fotos para escanear códigos QR y direcciones cripto desde imágenes.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get selectPhotos => 'Seleccionar fotos';

  @override
  String get manageInSettings => 'Gestionar en ajustes';

  @override
  String get addPhotos => 'Añadir fotos';

  @override
  String get noPhotosSelected => 'No hay fotos seleccionadas';

  @override
  String get noPhotosSelectedDesc =>
      'Diste acceso limitado sin seleccionar ninguna foto. Elige fotos de la galería para escanearlas.';

  @override
  String get noPhotosFound => 'No se encontraron fotos';

  @override
  String get scanSelectedImage => 'Escanear imagen seleccionada';

  @override
  String get unableToReadPhoto => 'No se puede leer la foto seleccionada.';

  @override
  String get noQrFoundInImage =>
      'No se encontró ningún código QR en la imagen seleccionada.';

  @override
  String get failedToAnalyzeImage =>
      'Error al analizar la imagen seleccionada.';

  @override
  String get qrEmptyContent =>
      'El código QR escaneado no contiene contenido legible.';

  @override
  String get scanResults => 'Resultados del escaneo';

  @override
  String get removeAllResults => 'Eliminar todos los resultados';

  @override
  String get removeAllResultsTitle => '¿Eliminar todos los resultados?';

  @override
  String get removeAllResultsContent =>
      'Esto eliminará permanentemente todos los resultados. Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get removeAll => 'Eliminar todos';

  @override
  String get allResultsRemoved => 'Todos los resultados han sido eliminados.';

  @override
  String get noScanResultsYet => 'Aún no hay resultados';

  @override
  String get noScanResultsDesc =>
      'Escanea un código QR o dirección cripto para guardar y ver los resultados aquí.';

  @override
  String get cryptoWalletTitle => 'Billetera cripto:';

  @override
  String get scannedLinkTitle => 'Enlace escaneado:';

  @override
  String get scanningLink => 'Escaneando el enlace...';

  @override
  String get scanningWallet => 'Escaneando billetera cripto...';

  @override
  String get openLinkInBrowser => 'Abrir enlace en el navegador';

  @override
  String get blockedLinkDesc =>
      'El acceso a este enlace está bloqueado debido a amenazas de seguridad detectadas.';

  @override
  String get analysisTimedOut =>
      'Tiempo de espera agotado. El servicio está tardando más de lo esperado.';

  @override
  String get unableToScanLink => 'No se pudo escanear este enlace.';

  @override
  String get unableToScanWallet => 'No se pudo escanear esta billetera cripto.';

  @override
  String get plainTextNotLink =>
      'El contenido escaneado es texto plano, no un enlace web.';

  @override
  String get scanError => 'Error de escaneo';

  @override
  String get safe => 'Seguro';

  @override
  String get safeDesc =>
      'No se encontraron problemas de seguridad en este enlace.';

  @override
  String get potentiallyUnsafe => 'Potencialmente no seguro';

  @override
  String get potentiallyUnsafeDesc =>
      'Se detectaron advertencias de seguridad. Ábrelo solo si confías en la fuente.';

  @override
  String get dangerousLink => 'Enlace peligroso';

  @override
  String get dangerousLinkDesc =>
      'Varios motores de seguridad marcaron este enlace como peligroso o malicioso.';

  @override
  String get malicious => 'Malicioso';

  @override
  String get unverified => 'No verificado';

  @override
  String get unverifiedDesc =>
      'Dirección no verificada en bases de datos de amenazas. Verifica al destinatario antes de enviar fondos.';

  @override
  String get maliciousReportedDesc =>
      'Esta billetera fue reportada en bases de direcciones maliciosas.';

  @override
  String get safety => 'Seguridad';

  @override
  String get chain => 'Red';

  @override
  String get balance => 'Saldo';

  @override
  String get transactions => 'Transacciones';

  @override
  String get signals => 'Señales';

  @override
  String get enginesScanning => 'Motores de escaneo';

  @override
  String get showAllEngines => 'Mostrar todos los motores';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get checksCompleted => 'pruebas completadas';

  @override
  String get warningsFound => 'advertencias detectadas';

  @override
  String get phishing => 'Phishing';

  @override
  String get suspicious => 'Sospechoso';

  @override
  String get scannerResults => 'Resultados del escáner';

  @override
  String enginesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count motores',
      one: '1 motor',
    );
    return '$_temp0';
  }

  @override
  String get showFewerEngines => 'Mostrar menos motores';

  @override
  String showAllEnginesCount(int count) {
    return 'Mostrar todos los $count motores';
  }

  @override
  String warningsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count advertencias',
      one: '1 advertencia',
    );
    return '$_temp0';
  }

  @override
  String threatsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amenazas',
      one: '1 amenaza',
    );
    return '$_temp0';
  }

  @override
  String get tapToOpenInBrowser => 'Toca el enlace para abrir en el navegador';

  @override
  String get reviewWarningsBeforeOpening =>
      'Revisa las advertencias antes de abrir';

  @override
  String get linkBlockedDueToThreats =>
      'Enlace bloqueado por amenazas de seguridad';

  @override
  String walletType(String label) {
    return 'Billetera $label';
  }

  @override
  String assetsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activos',
      one: '1 activo',
    );
    return '$_temp0';
  }

  @override
  String get network => 'Red';

  @override
  String get nativeBalance => 'Saldo nativo';

  @override
  String get walletAssets => 'Activos de la billetera';

  @override
  String get noAssetsFound => 'No se encontraron activos para esta billetera.';
}
