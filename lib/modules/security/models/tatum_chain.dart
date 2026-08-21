enum TatumChain {
  ethereumMainnet('ethereum-mainnet', 'Ethereum'),
  solanaMainnet('solana-mainnet', 'Solana'),
  bitcoinMainnet('bitcoin-mainnet', 'Bitcoin'),
  polygonMainnet('polygon-mainnet', 'Polygon'),
  bscMainnet('bsc-mainnet', 'BNB Smart Chain'),
  baseMainnet('base-mainnet', 'Base'),
  arbOneMainnet('arb-one-mainnet', 'Arbitrum'),
  optimismMainnet('optimism-mainnet', 'Optimism'),
  celoMainnet('celo-mainnet', 'Celo'),
  tezosMainnet('tezos-mainnet', 'Tezos');

  final String value;
  final String label;

  const TatumChain(this.value, this.label);

  static TatumChain? fromValue(String? value) {
    if (value == null) return null;
    for (final chain in TatumChain.values) {
      if (chain.value == value) return chain;
    }
    return null;
  }
}

class CryptoWallet {
  final String address;
  final TatumChain chain;
  final String label;
  final String rawPayload;

  const CryptoWallet({
    required this.address,
    required this.chain,
    required this.label,
    required this.rawPayload,
  });

  factory CryptoWallet.fromJson(Map<String, dynamic> json) {
    final chain =
        TatumChain.fromValue(json['chain'] as String?) ??
        TatumChain.ethereumMainnet;
    return CryptoWallet(
      address: json['address'] as String? ?? '',
      chain: chain,
      label: json['label'] as String? ?? chain.label,
      rawPayload: json['rawPayload'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'chain': chain.value,
    'label': label,
    'rawPayload': rawPayload,
  };
}

class TatumAssetMetadata {
  final String? name;
  final String? logo;
  final String? image;

  const TatumAssetMetadata({this.name, this.logo, this.image});

  factory TatumAssetMetadata.fromJson(Map<String, dynamic> json) {
    return TatumAssetMetadata(
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (logo != null) 'logo': logo,
    if (image != null) 'image': image,
  };
}

class TatumAssetBalance {
  final String type;
  final String? id;
  final String balance;
  final String? symbol;
  final int? decimals;
  final TatumAssetMetadata? metadata;

  const TatumAssetBalance({
    required this.type,
    this.id,
    required this.balance,
    this.symbol,
    this.decimals,
    this.metadata,
  });

  factory TatumAssetBalance.fromJson(Map<String, dynamic> json) {
    return TatumAssetBalance(
      type: json['type'] as String? ?? '',
      id: json['id'] as String?,
      balance: json['balance']?.toString() ?? '0',
      symbol: json['symbol'] as String?,
      decimals: json['decimals'] is int ? json['decimals'] as int : null,
      metadata: json['metadata'] is Map<String, dynamic>
          ? TatumAssetMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    'balance': balance,
    if (symbol != null) 'symbol': symbol,
    if (decimals != null) 'decimals': decimals,
    if (metadata != null) 'metadata': metadata!.toJson(),
  };
}

class TatumNativeBalance {
  final String? balance;
  final String? incoming;
  final String? outgoing;
  final String? incomingPending;
  final String? outgoingPending;

  const TatumNativeBalance({
    this.balance,
    this.incoming,
    this.outgoing,
    this.incomingPending,
    this.outgoingPending,
  });

  factory TatumNativeBalance.fromJson(Map<String, dynamic> json) {
    return TatumNativeBalance(
      balance: json['balance']?.toString(),
      incoming: json['incoming']?.toString(),
      outgoing: json['outgoing']?.toString(),
      incomingPending: json['incomingPending']?.toString(),
      outgoingPending: json['outgoingPending']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (balance != null) 'balance': balance,
    if (incoming != null) 'incoming': incoming,
    if (outgoing != null) 'outgoing': outgoing,
    if (incomingPending != null) 'incomingPending': incomingPending,
    if (outgoingPending != null) 'outgoingPending': outgoingPending,
  };
}

enum MaliciousCheckStatus {
  valid('valid'),
  invalid('invalid'),
  unknown('unknown');

  final String value;
  const MaliciousCheckStatus(this.value);

  static MaliciousCheckStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'valid' => MaliciousCheckStatus.valid,
      'invalid' => MaliciousCheckStatus.invalid,
      _ => MaliciousCheckStatus.unknown,
    };
  }
}

class TatumMaliciousAddressCheck {
  final MaliciousCheckStatus status;
  final String? source;
  final String? description;
  final List<String>? signals;

  const TatumMaliciousAddressCheck({
    required this.status,
    this.source,
    this.description,
    this.signals,
  });

  factory TatumMaliciousAddressCheck.fromJson(Map<String, dynamic> json) {
    final rawSignals = json['signals'];
    List<String>? signals;
    if (rawSignals is List) {
      signals = rawSignals.map((e) => e.toString()).toList();
    }

    return TatumMaliciousAddressCheck(
      status: MaliciousCheckStatus.fromString(json['status'] as String?),
      source: json['source'] as String?,
      description: json['description'] as String?,
      signals: signals,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.value,
    if (source != null) 'source': source,
    if (description != null) 'description': description,
    if (signals != null) 'signals': signals,
  };
}
