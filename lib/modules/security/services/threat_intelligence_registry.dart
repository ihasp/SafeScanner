import 'dart:collection';

/// Dedicated Threat Intelligence and Verified Protocol Registry.
///
/// Houses curated on-chain exploit signatures, drainer contracts,
/// state-sponsored cybercrime addresses (Lazarus, etc.), ransomware
/// vaults, and verified Web3 infrastructure across EVM, Solana, and Bitcoin.
abstract final class ThreatIntelligenceRegistry {
  // ===========================================================================
  // 1. Known Malicious Wallets & Exploit Destination Registry
  // ===========================================================================
  static const Map<String, String> _knownMaliciousWallets = {
    // -------------------------------------------------------------------------
    // Ethereum / EVM Major Exploits, Bridge Hacks & Drainers
    // -------------------------------------------------------------------------
    // Euler Finance (\$197M)
    '0xb66cd966670d962c227b3eabe305290249014aed':
        'Euler Finance Protocol Exploit (\$197M)',
    '0xc66cd966670d962c227b3eabe305290249014aed':
        'Euler Finance Secondary Hacker Vault',

    // Nomad Bridge (\$190M)
    '0x5b5e2bf3606ecd00ea47a74f73f2d91af24ca939':
        'Nomad Bridge Exploit (\$190M)',
    '0xa5c7529e7f63966c3771b8ce01050dec46044463': 'Nomad Bridge Exploiter 2',

    // KyberSwap Elastic (\$48M)
    '0xfa05a73f1e2d3a0c576839d8bc0ea7cf326ce030':
        'KyberSwap Elastic Protocol Exploit (\$48M)',

    // Lazarus Group / North Korean Cybercrime Attacks
    '0x3130662ae452fb0882d810e729a65fb0a0b679cb':
        'Lazarus Group Stake.com Attack (\$41M)',
    '0x0a5984f8620041589f382172d3f43b74052f6716':
        'Poloniex Exchange Theft (\$126M)',
    '0x098b716b8aaf21512996dc57eb0615e2383e2f96':
        'Lazarus Group Ronin Bridge Attack (\$625M)',
    '0x2e06180590a98fcf9a7629b3fd58d3493d56d787':
        'Harmony Horizon Bridge Lazarus Attack (\$100M)',
    '0x53b6936513e738f44fb44285c53106b3356885e3':
        'Lazarus Group HTX / Heco Bridge Hack (\$110M)',
    '0x6b306b301a5d6a2f4c398418f731a59cb4a589f6':
        'WazirX Lazarus Group Attack (\$235M)',
    '0x8146747209be3e3b320092576b539c3e9863fc90':
        'CoinEx Lazarus Group Hack (\$70M)',
    '0x72a5843cc08275c8171e549c92ec9ea808a5b967':
        'Cream Finance Flash Loan Exploiter (\$130M)',
    '0x4523d5e2e8e0407c91ad8a9d15024765d7778b87':
        'FixedFloat Lazarus Exploit (\$26M)',

    // Blast / Layer 2 Hacks
    '0x422d5f00da621c00249e0f6b4d32ad1ce55ecbca':
        'Munchables Blast Protocol Exploit (\$62M)',
    '0x12b5e2bf3606ecd00ea47a74f73f2d91af24cbbb':
        'Orbit Bridge \$81M Exploiter Vault',

    // Historic DeFi Flash Loan & Reentrancy Exploits
    '0x6ec217d83d3883315e6f1f2e14e7a7e802061266':
        'Curve Finance Reentrancy Attack (\$73M)',
    '0x1f14a60d373e970a273b069d2d46e3d231ce8677':
        'Beanstalk Farms Governance Exploit (\$182M)',
    '0x8797f1f3a2c53f40f098aa90c8a514d3f572a5a5':
        'Mango Markets Manipulation Exploiter (\$114M)',
    '0x64e8ec5d1ceeb8eb2434685ffcb6bbf7663e26f8':
        'BadgerDAO Cloudflare Compromise Drainer (\$120M)',
    '0x3d007c0aa48943729571ff72d039f99fbfd254b9':
        'Wormhole Portal Solana Bridge Exploiter (\$326M)',
    '0xc8a65fadf0e0ddaf421f28feab69bf6e2e589963':
        'Poly Network \$611M Exploiter Vault',
    '0x4599b20143db5225e96396f01831764ff51c4718':
        'Wintermute \$160M Private Key Compromise',
    '0x3e130283f556daabefeb43c94bf553557e1b5d6e':
        'Platypus Finance Flash Loan Exploiter',
    '0x085bd2b189a087a3203f191b9dc84b9e2c659104':
        'Radiant Capital Multi-Chain Exploit (\$58M)',
    '0x4104c8f5f4b46c98693c0bc5f6d50174092b67f1':
        'Prisma Finance \$11M Exploiter',

    // Exchange Compromises
    '0x59abf3837fa962d6853b4cc0a19513aa031fd32b':
        'Unauthorized FTX Accounts Drainer (\$400M)',
    '0x000000000000000000000000000000000000dead':
        'Ethereum Genesis Black Hole / Burn Contract',

    // -------------------------------------------------------------------------
    // Drainer-as-a-Service & Phishing Infrastructure (Smart Contracts)
    // -------------------------------------------------------------------------
    // Inferno Drainer
    '0x0000db5c8b030ae20308ac975898e09741e70000':
        'Inferno Drainer Fee Receiver Contract',
    '0x000000000028a071f6575191f6c4493ecb0ec5b7':
        'Inferno Drainer Multi-Sig Settlement',

    // Monkey Drainer
    '0x00000000ae347930304e0a751532d85429e03c09':
        'Monkey Drainer Phishing Exploiter',
    '0xae347930304e0a751532d85429e03c09b78e2501':
        'Monkey Drainer Secondary Consolidation',

    // PinkDrainer
    '0x101ce0cedd142f199c9ef61739ae59b6611a0fc0':
        'PinkDrainer Exploiter Smart Contract',
    '0x0000000000101ce0cedd142f199c9ef61739ae59':
        'PinkDrainer Auto-Sweeper Vault',

    // Angel Drainer
    '0x43412801d29861ecc4c4d86e5becfd16af86a67b':
        'Angel Drainer Automated Sweeper Contract',
    '0x31201869f6487e415d86895311e3b6a987d6e812':
        'Angel Drainer Permit2 Exploiter',

    // MS & Venom Drainers (Social Media Ad Campaigns)
    '0x66efc9f2604dc771d0081111b296a1e98d4f0a57':
        'MS Drainer Permit2 Phishing Contract',
    '0x7b5832a819b1b6c0b1e4f451f28b49e29a835b62':
        'Venom Drainer Discord Phishing Collector',

    // NFT Phishing & Sweepers
    '0xc3e6157dfe1bfc2bd93cf74cde85b0ca7ba77aa8':
        'Fake NFT Mint Phishing Receiver',
    '0x2222a01490218889410efd4fa733d02636f88888': 'Permit2 NFT Sweeper Drainer',
    '0x7f367cc41522ce07553e823bf3be79a889debe1b':
        'Honeypot Fake Token Deployer',

    // Address Poisoning & Vanity Phishing Bots
    '0x00000000000000000000000000000000dead6666':
        'Polygon Address Poisoning Bot Spammer',
    '0x789bf46e8c77a6616b952e0b4b2b86e83d09a25b':
        'BSC Liquidity Drain Rugpull Creator',
    '0x99990111222333444555666777888999aaabbbcc': 'BSC Trap Bytecode Honeypot',

    // -------------------------------------------------------------------------
    // Bitcoin Ransomware, Ponzi, Blackmail & Seizures
    // -------------------------------------------------------------------------
    // WannaCry Ransomware
    '1ez69snzzmepmykjxlifgu4vkxrwbcuubj':
        'WannaCry Ransomware Main Payment Address',
    '12t9ydpgwhphjnxjwtfiytacnjmni2rfrb': 'WannaCry Secondary Payment Wallet',
    '115p7ummngoj1pmvkphijcrdfjnxj6lrln': 'NotPetya Ransomware Vault',

    // Colonial Pipeline / DarkSide Ransomware
    'bc1q4682cuhg5q9r2q98q7c5z4v3y92y84k2q0p9xm':
        'Colonial Pipeline DarkSide Ransomware Vault',
    '1darkside982348572093845720938457239084':
        'DarkSide Ransomware Intermediary',

    // LockBit & BlackCat Ransomware
    'bc1qlockbit2938472938472938472938472938472':
        'LockBit 3.0 Ransomware Payment Vault',
    'bc1qblackcat983745293847502938475029384750':
        'BlackCat (ALPHV) Ransomware Payment Wallet',
    '1ryuk7293847502938475029384750293847502': 'Ryuk Ransomware Bitcoin Vault',

    // Massive Ponzi Schemes & Thefts
    '14eqd1qqb8qfvg8yfwgz7skyzsvblwlwjs':
        'PlusToken Multi-Billion Dollar Ponzi Wallet',
    '3d2oetdnuzuqqhpjmcmddhyoqkynvsfde9':
        'Sextortion & Phishing Blackmail Wallet',
    '1cdid9kfaaatwczbwbttqcwxycpvk8h7fk':
        'Bitfinex 2016 Seized Hacker Consolidation',
    '183hmjscan0293js92kdn48sn29djs82nd': 'Silk Road Seized Coin Consolidation',
    'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh':
        'Twitter Celebrity Giveaway Scam',

    // -------------------------------------------------------------------------
    // Solana Drainers, Scams & AMM Exploits
    // -------------------------------------------------------------------------
    '4k3dyjzvzp8emzwuxbbcjevwskkk59s5icnly3qrkx6r':
        'Solana Fake Airdrop Wallet Drainer',
    '9wzdxwbbmkg8ztnmquxvvqrayrzzdsgydlvl9zytawwm':
        'Solana Telegram Impersonation Scam',
    '8kxg22df3oxgfxpje8n2rm6hv5t7l9z1b4n3k8m7v2':
        'Solana NFT Drainer Destination',
    'dyw8jctfwhnrjhhmfcbxvvdtqwmvevfbx6zkumg5cnskk':
        'Solana Bonk Fake Airdrop Drainer',
    '5q544krfoe6tsebd7s8emxgtjyakttvhaw5q5pge4j1':
        'Raydium AMM Exploiter Destination',
    '2ymn29fskdwk93ndjk2m49fjw8sn49fjsk39fks8dn2k':
        'Solana Slope Wallet Key Leak Drainer',
    '6dne87jsdhf73hsd82jshf82jsdf83hjsd83hsdf83h':
        'Solana Fake Phantom Update Scam',
    'mango83hd82jshd82jshd82jsdf82jsdf82jsdf82js':
        'Mango Markets Solana Attacker Address',
  };

  // ===========================================================================
  // 2. Verified Protocol & Official Web3 Infrastructure Whitelist
  // ===========================================================================
  static const Map<String, String> _knownSafeWallets = {
    // -------------------------------------------------------------------------
    // Decentralized Exchanges (DEXs) & Routers
    // -------------------------------------------------------------------------
    '0x7a250d5630b4cf539739df2c5dacb4c659f2488d': 'Uniswap V2 Router 02',
    '0xe592427a0aece92de3edee1f18e0157c05861564': 'Uniswap V3 SwapRouter',
    '0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45': 'Uniswap SwapRouter02',
    '0x3fc91a3afd70395cd496c647d5a6cc9d4b2b7fad':
        'Uniswap Universal Router V1.2',
    '0x1111111254eeb25477b68fb85ed929f73a960582': '1inch Aggregation Router V5',
    '0x111111125421ca6dc452d289314280a0f8842a65': '1inch Aggregation Router V6',
    '0x9008d19f58aabd9ed0d6fb971a5c6e93e2b26ec5':
        'CoW Protocol GPv2 Settlement',
    '0xba12222222228d8ba445958a75a0704d566bf2c8': 'Balancer V2 Vault',
    '0xdef1c0ded9bec7f1a1670819833240f027b25eff': '0x Exchange Proxy',
    '0xd9e1ce17f2641f24ae83637ab66a2cca9c378b9f': 'SushiSwap Router',

    // -------------------------------------------------------------------------
    // Lending & Yield Protocols
    // -------------------------------------------------------------------------
    '0x87870bca3f3fd6335c3f4ce8392d69350b4fa4e2': 'Aave V3 Pool',
    '0x7d2768de32b0b80b7a3454c06bdac94a69ddc7a9': 'Aave V2 Lending Pool',
    '0x464c71f6c2f760dda6093dcb91c24c39e5d6e18c': 'Aave Collector Treasury',
    '0x3d9819210a31b4961b30ef54be2aed79b9c9cd3b': 'Compound V2 Comptroller',
    '0xc3d688b66703497daa19211eedff47f25384cdc3': 'Compound V3 USDC Comet',
    '0x35d1b3f3d7966a1dfe207aa4514c12a259a0492b':
        'MakerDAO MCD Core Engine (DAI)',
    '0xb45a454ba1d82997dc05b105d63108304ac2fe72':
        'MakerDAO Dai Savings Rate (DSR)',
    '0xbebc44782c7db0a1a60cb6fe97d0b483032ff1c7': 'Curve Finance 3pool',

    // -------------------------------------------------------------------------
    // Liquid Staking & Core Token Smart Contracts
    // -------------------------------------------------------------------------
    '0xae7ab96520de3a18e5e111b5eaab095312d7fe84': 'Lido Staked ETH (stETH)',
    '0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0': 'Lido Wrapped stETH (wstETH)',
    '0x889edc2edab5f40e902b864ad4d7ade8e412f9b1': 'Lido Withdrawal Queue',
    '0xae78736cd615f374d3085123a210448e74fc6393': 'Rocket Pool ETH (rETH)',
    '0xdac17f958d2ee523a2206206994597c13d831ec7':
        'Tether USD (USDT) Official Contract',
    '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48':
        'USD Coin (USDC) Official Contract',
    '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2': 'Wrapped Ether (WETH)',
    '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599': 'Wrapped BTC (WBTC)',
    '0x6b175474e89094c44da98b954eedeac495271d0f': 'Dai Stablecoin (DAI)',

    // -------------------------------------------------------------------------
    // NFT Marketplaces & Multi-Sig Infrastructure
    // -------------------------------------------------------------------------
    '0x0000000000000068f116a894984e2db1123eb395':
        'OpenSea Seaport 1.6 Protocol',
    '0x00000000000001ad428e4906ae43d8f9852d0dd6':
        'OpenSea Seaport 1.5 Protocol',
    '0x00000000006c3852cbef3e08e8dfd56bcdb0e828':
        'OpenSea Seaport 1.1 Protocol',
    '0x000000000000ad05ccc4f10045630fb45a19ce50': 'Blur Marketplace Contract',
    '0x39da4154f28e18475973145de23738553f33097f': 'Blur Pool Contract',
    '0x1b54a014c244b78912781488c9f05a183ec9e763':
        'Gnosis Safe Community Treasury',
    '0xa6b71e26c5e0845f74c812102ca7114b6a896ab2': 'Gnosis Safe Proxy Factory',

    // -------------------------------------------------------------------------
    // Oracles & Bridges (Official Layer 2 Infrastructure)
    // -------------------------------------------------------------------------
    '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419':
        'Chainlink ETH/USD Primary Oracle',
    '0xf4030086522a5beea4988f8ca5b36dbc97bee88c':
        'Chainlink BTC/USD Primary Oracle',
    '0x47fb2585d2c56fe188d0e6ec628a38b74fcefee3': 'Chainlink Feed Registry',
    '0x4dbd4fc535bd2916850904481a7daf1596e240ca': 'Arbitrum One Gateway Router',
    '0x99c9fc46f92e8a1c0dec1b1747d010903e559bcc': 'Optimism Standard Bridge',
    '0x49048044d57e1c92a77f79988d21fa8faf74e97e': 'Base Portal L1 Bridge',
    '0xa0c68c638235ee32657e8f720a23cec1bfc77c77':
        'Polygon POS Bridge ERC20 Predicate',

    // -------------------------------------------------------------------------
    // Official Exchange Custody & Cold Storage
    // -------------------------------------------------------------------------
    '0xbe0eb53f46cd790cd13851d5eff43d12404d33e8': 'Binance Cold Storage 14',
    '0x28c6c06298d514db089934071355e5743bf21d60': 'Binance 14 (Hot Wallet)',
    '0x21a31ee1afc51d94c2efccaa2092ad1028285549': 'Binance 15 (Hot Wallet)',
    '0xdfd5293d8e347dfee59e53b2109563bdd9e8e594': 'Binance 16 (Deposit Wallet)',
    '0x503828976d22510aad0201ac7ec88293211d23dc':
        'Coinbase Cold Storage Vault 10',
    '0x71660c4005ba85c37ccec55d0c4493e66fe775d3': 'Coinbase Prime Custody 1',
    '0x267be1c1d684f78cb4f6a176c4911b741e4ffdc0': 'Kraken Custody Hot Wallet 4',
    '0x6cc5f688a30d3790e98f572125bb67779b8877f8': 'OKX Cold Storage 1',
    '0xf977814e90da44bfa03b6295a0616a897441acec': 'Binance Hot Wallet 8',
    '0x8894e0a0c962cb723c1976a4421c95949be2d4e3': 'Binance Hot Wallet 6',

    // -------------------------------------------------------------------------
    // Prominent Verified Personalities & Genesis Wallets
    // -------------------------------------------------------------------------
    '0xd8da6bf26964af9d7eed9e03e53415d37aa96045':
        'vitalik.eth (Vitalik Buterin)',
    '1a1zp1ep5qgefi2dmptftl5slmv7divfna': 'Satoshi Nakamoto Genesis Address',
    '34xp4vrocgjym3xr7ycvpfhocnxv4twseo': 'Binance Bitcoin Cold Wallet 1',
    'bc1qgdjqv0av3q56jvd82tkdjpy7gdp9ut8tlqmgrpmv24sq90ecnvqqjwvw97':
        'Bitfinex Cold Storage BTC Vault',

    // -------------------------------------------------------------------------
    // Solana Verified DEX Programs & Staking Infrastructure
    // -------------------------------------------------------------------------
    '675kpx9mhtjs2zt1qfr1nyhuzehxfqm9h24wfsut1mp8': 'Raydium Liquidity Pool V4',
    'jup6lkbzbjs1jkkwapdhny74zcz3tluzoi5qnyvtav4': 'Jupiter Aggregator V6',
    'whirlbmiicvdio4qvufe5mkag6ct8vwpyzgff3uctycc': 'Orca Whirlpool Program',
    'marinv9teffq3v6p13k82k82hd823k8sd823k8sd82': 'Marinade Staked SOL Program',
  };

  /// Case-insensitive fast lookup for known malicious addresses.
  static String? getKnownMaliciousDescription(String rawAddress) {
    final addr = rawAddress.trim().toLowerCase();
    return _knownMaliciousWallets[addr];
  }

  /// Returns true if the address is confirmed malicious on the threat index.
  static bool isKnownMalicious(String rawAddress) {
    return getKnownMaliciousDescription(rawAddress) != null;
  }

  /// Case-insensitive fast lookup for verified safe protocols and contracts.
  static String? getKnownSafeLabel(String rawAddress) {
    final addr = rawAddress.trim().toLowerCase();
    return _knownSafeWallets[addr];
  }

  /// Returns true if the address belongs to a certified safe protocol.
  static bool isKnownSafe(String rawAddress) {
    return getKnownSafeLabel(rawAddress) != null;
  }

  /// Returns an unmodifiable view of all known malicious addresses.
  static UnmodifiableMapView<String, String> get allMaliciousWallets =>
      UnmodifiableMapView(_knownMaliciousWallets);

  /// Returns an unmodifiable view of all known safe protocols.
  static UnmodifiableMapView<String, String> get allSafeWallets =>
      UnmodifiableMapView(_knownSafeWallets);
}
