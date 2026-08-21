// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Scanner QR';

  @override
  String get navScan => 'Escanear';

  @override
  String get navGallery => 'Galeria';

  @override
  String get navResults => 'Resultados';

  @override
  String get navSettings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get scannerPreferences => 'Preferências do Scanner';

  @override
  String get defaultCamera => 'Câmera Padrão';

  @override
  String get cameraBack => 'Traseira';

  @override
  String get cameraFront => 'Frontal';

  @override
  String get defaultScanMode => 'Modo Padrão';

  @override
  String get scanModeQr => 'QR';

  @override
  String get scanModeCrypto => 'Cripto';

  @override
  String get hapticsOnScan => 'Vibração ao escanear';

  @override
  String get hapticsSubtitle => 'Vibrar em caso de sucesso/erro';

  @override
  String get autoOpenSafeLinks => 'Abrir links seguros automaticamente';

  @override
  String get autoOpenSubtitle => 'Abrir no navegador se 0 ameaças';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Escolha o idioma do aplicativo';

  @override
  String get systemLanguage => 'Padrão do sistema';

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
  String get cameraAccessRequired => 'Acesso à câmera necessário';

  @override
  String get cameraAccessDesc =>
      'O aplicativo precisa de acesso à câmera para escanear códigos QR e endereços de criptomoedas.';

  @override
  String get grantPermission => 'Conceder Permissão';

  @override
  String get galleryPermissionNeeded => 'Permissão da Galeria necessária';

  @override
  String get galleryPermissionDesc =>
      'Permita o acesso às suas fotos para escanear códigos QR e endereços cripto a partir de imagens.';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get selectPhotos => 'Selecionar Fotos';

  @override
  String get manageInSettings => 'Gerenciar nas Configurações';

  @override
  String get addPhotos => 'Adicionar Fotos';

  @override
  String get noPhotosSelected => 'Nenhuma foto selecionada';

  @override
  String get noPhotosSelectedDesc =>
      'Você concedeu acesso limitado sem selecionar fotos. Escolha fotos da galeria para escanear.';

  @override
  String get noPhotosFound => 'Nenhuma foto encontrada';

  @override
  String get scanSelectedImage => 'Escanear imagem selecionada';

  @override
  String get unableToReadPhoto => 'Não foi possível ler a foto selecionada.';

  @override
  String get noQrFoundInImage => 'Nenhum código QR encontrado na imagem.';

  @override
  String get failedToAnalyzeImage => 'Falha ao analisar a imagem selecionada.';

  @override
  String get qrEmptyContent =>
      'O código QR escaneado não contém conteúdo legível.';

  @override
  String get scanResults => 'Resultados do scan';

  @override
  String get removeAllResults => 'Remover todos os resultados';

  @override
  String get removeAllResultsTitle => 'Remover todos os resultados?';

  @override
  String get removeAllResultsContent =>
      'Isso excluirá permanentemente todos os resultados. Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get removeAll => 'Remover tudo';

  @override
  String get allResultsRemoved => 'Todos os resultados foram removidos.';

  @override
  String get noScanResultsYet => 'Nenhum resultado de scan ainda';

  @override
  String get noScanResultsDesc =>
      'Escaneie um código QR ou endereço cripto para ver os resultados aqui.';

  @override
  String get cryptoWalletTitle => 'Carteira cripto:';

  @override
  String get scannedLinkTitle => 'Link escaneado:';

  @override
  String get scanningLink => 'Escaneando o link...';

  @override
  String get scanningWallet => 'Escaneando carteira cripto...';

  @override
  String get openLinkInBrowser => 'Abrir link no navegador';

  @override
  String get blockedLinkDesc =>
      'A abertura deste link foi bloqueada devido a ameaças de segurança detectadas.';

  @override
  String get analysisTimedOut =>
      'Tempo limite de análise esgotado. O serviço está demorando mais do que o esperado.';

  @override
  String get unableToScanLink => 'Não foi possível escanear este link.';

  @override
  String get unableToScanWallet =>
      'Não foi possível escanear esta carteira cripto.';

  @override
  String get plainTextNotLink =>
      'O conteúdo escaneado é texto simples, não um link web.';

  @override
  String get scanError => 'Erro de escaneamento';

  @override
  String get safe => 'Seguro';

  @override
  String get safeDesc =>
      'Nenhum problema de segurança encontrado para este link.';

  @override
  String get potentiallyUnsafe => 'Potencialmente inseguro';

  @override
  String get potentiallyUnsafeDesc =>
      'Sinais de alerta detectados. Abra apenas se confiar na fonte.';

  @override
  String get dangerousLink => 'Link perigoso';

  @override
  String get dangerousLinkDesc =>
      'Vários mecanismos de segurança sinalizaram este link como perigoso ou malicioso.';

  @override
  String get malicious => 'Malicioso';

  @override
  String get unverified => 'Não verificado';

  @override
  String get unverifiedDesc =>
      'Endereço não verificado em bancos de dados de ameaças. Verifique o destinatário antes de enviar fundos.';

  @override
  String get maliciousReportedDesc =>
      'Esta carteira foi relatada em bancos de dados de endereços maliciosos.';

  @override
  String get safety => 'Segurança';

  @override
  String get chain => 'Rede';

  @override
  String get balance => 'Saldo';

  @override
  String get transactions => 'Transações';

  @override
  String get signals => 'Sinais';

  @override
  String get enginesScanning => 'Mecanismos de verificação';

  @override
  String get showAllEngines => 'Mostrar todos os mecanismos';

  @override
  String get showLess => 'Mostrar menos';
}
