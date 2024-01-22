const { BIP39LIST } = require("./BIP-39 wordlist.js");
const crypto = require("crypto");
const readline = require('readline');
const {
  hexToBinary,
  generateSeedFromMnemonic,
} = require("./utills.js");
const HDKey = require('hdkey');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Use readline to get input for entropy, path, and number of accounts
rl.question('Enter entropy size (128, 160, 192, 224, 256): ', (entropyInput) => {
  const entropySizes = [128, 160, 192, 224, 256];
  const selectedEntropySize = entropySizes.includes(Number(entropyInput)) ? Number(entropyInput) : entropySizes[0];

  rl.question('Enter HD key derivation path (e.g., m/44\'/0\'/0\'/0): ', (path) => {
    path = path || "m/44'/0'/0'/0"; // Default path if not provided

    rl.question('Enter the number of accounts: ', (numAccountsInput) => {
      const numAccounts = Number(numAccountsInput) || 1; // Default to 1 if not provided

      // Code to generate random binary equal to the length of selectedEntropySize
      let randomBinaryNo = "";
      for (let i = 1; i <= selectedEntropySize; i++) {
        randomBinaryNo = randomBinaryNo + (Math.random() > 0.5 ? 1 : 0);
      }

      // Convert random binary to Uint8Array
      const uint8Array = new Uint8Array(randomBinaryNo.length / 8);
      for (let i = 0; i < randomBinaryNo.length; i += 8) {
        const byte = randomBinaryNo.slice(i, i + 8);
        uint8Array[i / 8] = parseInt(byte, 2);
      }

      // Hash the Uint8Array
      const hashedRandomBinaryNo = crypto
        .createHash("sha256")
        .update(uint8Array)
        .digest("hex");

      // Convert hash to binary
      const binaryOfHashedRandomBinaryNo = hexToBinary(hashedRandomBinaryNo);

      // Calculate checksum
      const checkSumLengthInBits = selectedEntropySize / 32;
      let checkSum = binaryOfHashedRandomBinaryNo.substring(0, checkSumLengthInBits);

      // Append checksum to randomBinaryNo
      const randomBinaryNoAndChecksum = `${randomBinaryNo}${checkSum}`;

      // Split randomBinaryNoAndChecksum into groups of 11 bits
      let seedPhrase = "";
      for (let i = 0; i < randomBinaryNoAndChecksum.length; i += 11) {
        seedPhrase +=
          BIP39LIST[parseInt(randomBinaryNoAndChecksum.substring(i, i + 11), 2)] +
          " ";
      }
      seedPhrase = seedPhrase.trim();
      console.log(seedPhrase);

      // Generate seed from mnemonic and passphrase
      let passPhrase = 'hi';
      const SEED = generateSeedFromMnemonic(seedPhrase, passPhrase);

      // Derive root key from seed
      const root = HDKey.fromMasterSeed(Buffer.from(SEED, 'hex'));

      // Derive child keys based on the specified path and number of accounts
      for (let accountIndex = 0; accountIndex < numAccounts; accountIndex++) {
        const accountPath = `${path}/${accountIndex}`;
        const childkey = root.derive(accountPath);
        console.log(`Account ${accountIndex + 1} (${accountPath}) - Private Key: ${childkey.privateExtendedKey}, Public Key: ${childkey.publicExtendedKey}`);
      }

      rl.close();
    });
  });
});
