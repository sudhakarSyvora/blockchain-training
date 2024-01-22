const crypto = require('crypto');
function hexToBinary(hexString) {
    let binaryResult = "";
  
    for (let i = 0; i < hexString.length; i++) {
     
      let binaryDigit = parseInt(hexString[i], 16).toString(2);
  
      while (binaryDigit.length < 4) {
        binaryDigit = "0" + binaryDigit;
      }
  
      binaryResult += binaryDigit;
    }
  
    return binaryResult;
  }
  function hmacSha512(key, data) {
    const hmac = crypto.createHmac('sha512', key);
    hmac.update(data);
    const hash = hmac.digest('hex');
    return hash;
  }
  function generateSeedFromMnemonic(mnemonic, passphrase = "") {
    const key = crypto.pbkdf2Sync(
      mnemonic,
      `mnemonic${passphrase}`,
      2048,
      64,
      "sha512"
    );
    return key.toString("hex");
  }
  

module.exports={
    hexToBinary
    ,hmacSha512,
    generateSeedFromMnemonic
}
