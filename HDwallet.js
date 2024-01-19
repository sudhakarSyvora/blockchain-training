const { BIP39LIST } = require("./BIP-39 wordlist.js");
const crypto = require("crypto");
var {
  hexToBinary,
  generateSeedFromMnemonic,
} = require("./utills.js");
var HDKey = require('hdkey')
 
//First we need to get a seed, it can be done by following BIP-39 which states using combination of seedphrase+passPhrase(optional) to generate the seedPhrase

//code to generate a random seedPhrase

const entropySizes = [128, 160, 192, 224, 256];
//Entropies should be in multiple of 32
const selectedEntropySize = entropySizes[0];

//Code to generate random binary equal to length of selectedEntropySize

let randomBinaryNo = "";
for (let i = 1; i <= selectedEntropySize; i++) {
  randomBinaryNo = randomBinaryNo + (Math.random() > 0.5 ? 1 : 0);
}
let checkSumLengthInBits = selectedEntropySize / 32;

const uint8Array = new Uint8Array(randomBinaryNo.length / 8);
for (let i = 0; i < randomBinaryNo.length; i += 8) {
  const byte = randomBinaryNo.slice(i, i + 8);
  uint8Array[i / 8] = parseInt(byte, 2);
}
const hashedRandomBinaryNo = crypto
  .createHash("sha256")
  .update(uint8Array)
  .digest("hex");

//converting in binary to get checksum of size checkSumLengthInBits from starting of it
const binaryOfHashedRandomBinaryNo = hexToBinary(hashedRandomBinaryNo);
 
let checkSum = binaryOfHashedRandomBinaryNo.substring(0, checkSumLengthInBits);
 
//Append checksum with randomBinaryNo
const randomBinaryNoAndChecksum = `${randomBinaryNo}${checkSum}`;
//split randomBinaryNoAndChecksum in group of 11 bits to get a seedphrase from bip-39 list of words
let seedPhrase = "";

for (let i = 0; i < randomBinaryNoAndChecksum.length; i += 11) {
  seedPhrase +=
    BIP39LIST[parseInt(randomBinaryNoAndChecksum.substring(i, i + 11), 2)] +
    " ";
}
seedPhrase = seedPhrase.trim();
console.log(seedPhrase)
let passPhrase='hi'
const SEED=generateSeedFromMnemonic(seedPhrase, passPhrase);
var root = HDKey.fromMasterSeed(Buffer.from(SEED, 'hex'))

var childkey = root.derive("m/44'/0'/0'/0/0");
 
console.log(childkey.privateExtendedKey)
console.log(childkey.publicExtendedKey)
 