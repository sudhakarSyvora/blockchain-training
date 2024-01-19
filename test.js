const bitcoin = require('bitcoinjs-lib');
const bip39 = require('bip39');
const bip32 = require('bip32');

// Generate a random mnemonic (12 words)
const mnemonic = bip39.generateMnemonic();

// Optional: Print the mnemonic for backup purposes (keep this private)
console.log('Mnemonic:', mnemonic);

// Derive a seed from the mnemonic
const seed = bip39.mnemonicToSeedSync(mnemonic);

// Create an HD wallet from the seed
const root = bip32.fromSeed(seed);

// Derive a specific account (in this case, account 0)
const accountIndex = 0;
const account = root.derivePath(`m/44'/0'/${accountIndex}'`);

// Derive an address for the first receiving address
const addressIndex = 0;
const addressNode = account.derive(addressIndex);
const address = bitcoin.payments.p2pkh({ pubkey: addressNode.publicKey }).address;

console.log('Address:', address);
