const crypto = require('crypto');
var sha256 = require('js-sha256');

const string='01101110011011100101000011000000011001000000001010111110010011011100010000111011011100110111110110101110011111010110101101000001'
const uint8Array = new Uint8Array(string.length / 8);
for (let i = 0; i < string.length; i += 8) {
    const byte = string.slice(i, i + 8);
    uint8Array[i / 8] = parseInt(byte, 2);
}
 
const hash = sha256(uint8Array)
 
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
// console.log(hexToBinary(hash).length);
 

function generateMasterNode(seed) {
  // Step 1: Calculate I = HMAC-SHA512(Key = "Bitcoin seed", Data = S)
  const key = Buffer.from('Bitcoin seed');
  const hmacResult = crypto.createHmac('sha512', "Bitcoin seed").update(seed).digest();

  return hmacResult;
}

// Example usage
const mseed = '6a5e5754ae0393a03167da8853f56ede81e6ec2a80da80bd54a3f9f7220242587f18f9ffdd9a773f64dc15ca0ee3aaa3d4552615821157acbc4180cfdfb4fef9'; // Replace with your actual hex seed
const seed = Buffer.from(mseed, 'hex');
const masterNode = generateMasterNode(seed);

  // Example usage

  console.log('Master Node:', masterNode.toString('hex'));
// console.log(hash.substring(0,2))
// function test(n){
     
//     return (parseInt(n, 16).toString(2)).padStart(8, '0');
      
// }
// console.log(test(hash).length)