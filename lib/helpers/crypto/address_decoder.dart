import '../../modules/security/models/tatum_chain.dart';

abstract final class AddressDecoder {
  static const Map<String, TatumChain> _schemeChains = {
    'arb': TatumChain.arbOneMainnet,
    'arbitrum': TatumChain.arbOneMainnet,
    'base': TatumChain.baseMainnet,
    'bitcoin': TatumChain.bitcoinMainnet,
    'bsc': TatumChain.bscMainnet,
    'btc': TatumChain.bitcoinMainnet,
    'celo': TatumChain.celoMainnet,
    'eth': TatumChain.ethereumMainnet,
    'ethereum': TatumChain.ethereumMainnet,
    'matic': TatumChain.polygonMainnet,
    'optimism': TatumChain.optimismMainnet,
    'polygon': TatumChain.polygonMainnet,
    'sol': TatumChain.solanaMainnet,
    'solana': TatumChain.solanaMainnet,
    'tezos': TatumChain.tezosMainnet,
    'xtz': TatumChain.tezosMainnet,
  };

  static const Set<TatumChain> _evmChains = {
    TatumChain.ethereumMainnet,
    TatumChain.polygonMainnet,
    TatumChain.bscMainnet,
    TatumChain.baseMainnet,
    TatumChain.arbOneMainnet,
    TatumChain.optimismMainnet,
    TatumChain.celoMainnet,
  };

  static ({String? scheme, String addressText, String originalText})
  _normalizeAddressPayload(String payload) {
    final trimmed = payload.trim();
    final schemeMatch = RegExp(
      r'^([a-z][a-z0-9+.-]*):',
      caseSensitive: false,
    ).firstMatch(trimmed);
    final scheme = schemeMatch?.group(1)?.toLowerCase();

    final withoutScheme = scheme != null
        ? trimmed.substring(scheme.length + 1).replaceFirst(RegExp(r'^//'), '')
        : trimmed;

    final beforeQuery = withoutScheme.split(RegExp(r'[?&]')).first;
    final addressText = beforeQuery
        .replaceFirst(RegExp(r'^pay-'), '')
        .split('@')
        .first;

    return (scheme: scheme, addressText: addressText, originalText: trimmed);
  }

  static CryptoWallet? decode(String payload) {
    if (payload.trim().isEmpty) return null;

    final normalized = _normalizeAddressPayload(payload);
    final hintedChain = normalized.scheme != null
        ? _schemeChains[normalized.scheme!]
        : null;
    final textToSearch = normalized.addressText.isNotEmpty
        ? normalized.addressText
        : normalized.originalText;

    // EVM address check (0x...)
    final evmMatch = RegExp(r'\b0x[a-fA-F0-9]{40}\b').firstMatch(textToSearch);
    if (evmMatch != null) {
      final chain = (hintedChain != null && _evmChains.contains(hintedChain))
          ? hintedChain
          : TatumChain.ethereumMainnet;
      return CryptoWallet(
        address: evmMatch.group(0)!,
        chain: chain,
        label: chain.label,
        rawPayload: normalized.originalText,
      );
    }

    // Bitcoin address check
    final btcMatch = RegExp(
      r'\b(?:bc1[a-zA-HJ-NP-Z0-9]{25,62}|[13][a-km-zA-HJ-NP-Z1-9]{25,34})\b',
    ).firstMatch(textToSearch);
    if (btcMatch != null) {
      return CryptoWallet(
        address: btcMatch.group(0)!,
        chain: TatumChain.bitcoinMainnet,
        label: TatumChain.bitcoinMainnet.label,
        rawPayload: normalized.originalText,
      );
    }

    // Tezos address check
    final tezosMatch = RegExp(r'\b(?:tz1|tz2|tz3|KT1)[a-zA-Z0-9]{33}\b')
        .firstMatch(textToSearch);
    if (tezosMatch != null) {
      return CryptoWallet(
        address: tezosMatch.group(0)!,
        chain: TatumChain.tezosMainnet,
        label: TatumChain.tezosMainnet.label,
        rawPayload: normalized.originalText,
      );
    }

    // Exclude standard web schemes from crypto address decoding
    if (normalized.scheme == 'http' ||
        normalized.scheme == 'https' ||
        normalized.scheme == 'ftp') {
      return null;
    }

    // Solana address check
    if (hintedChain == TatumChain.solanaMainnet) {
      final solMatch = RegExp(r'\b[1-9A-HJ-NP-Za-km-z]{32,44}\b')
          .firstMatch(textToSearch);
      if (solMatch != null) {
        return CryptoWallet(
          address: solMatch.group(0)!,
          chain: TatumChain.solanaMainnet,
          label: TatumChain.solanaMainnet.label,
          rawPayload: normalized.originalText,
        );
      }
    } else if (hintedChain == null && normalized.scheme == null) {
      final strictSolMatch = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$')
          .firstMatch(textToSearch);
      if (strictSolMatch != null) {
        return CryptoWallet(
          address: strictSolMatch.group(0)!,
          chain: TatumChain.solanaMainnet,
          label: TatumChain.solanaMainnet.label,
          rawPayload: normalized.originalText,
        );
      }
    }

    return null;
  }
}
