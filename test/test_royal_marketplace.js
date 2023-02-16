const RoyalMarketplace = artifacts.require("RoyalMarketplace");
const IERC721 = require("../build/contracts/IERC721.json");
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
const collectionAddress = "0xed5af388653567af2f388e6224dc7c4b3241c544";   
const sellerAddress = "";
const buyerAddress = "0x5E904A05033D728315dD23Bea210d17A68cA3d19";    // Azuki
const tokenId = 1111;

module.exports = async function (callback) {
    try {
        const marketplace = await RoyalMarketplace.deployed();
        const erc721 = new web3.eth.Contract(IERC721.abi, collectionAddress);
        const salePrice = web3.utils.toWei("1", "ether");

        // marketplace needs the seller approval to transfer their tokens
        const approval = await erc721.methods.approve(marketplace.address, tokenId).send({ from: sellerAddress });
        const sellReceipt = await marketplace.sellNFT(collectionAddress, tokenId, salePrice, {
          from: sellerAddress
      });
      const { encoded } = sellReceipt.logs[0].args;

      const oldOwner = await erc721.methods.ownerOf(tokenId).call();
      console.log(`owner of ${collectionAddress} #${tokenId}`, oldOwner);

      const oldSellerBalance = web3.utils.toBN(await web3.eth.getBalance(sellerAddress));
      console.log("Seller Balance (Eth):", web3.utils.fromWei(oldSellerBalance));

      // buyer buys the item for a sales price of 1 Eth
      const buyReceipt = await marketplace.buyNft(encoded, { from: buyerAddress, value: salePrice });
      const newOwner = await erc721.methods.ownerOf(tokenId).call();
      console.log(`owner of ${collectionAddress} #${tokenId}`, newOwner);

      const newSellerBalance = web3.utils.toBN(await web3.eth.getBalance(sellerAddress));
      console.log("Seller Balance (Eth):", web3.utils.fromWei(newSellerBalance));
      console.log("Seller Balance Diff (Eth):", web3.utils.fromWei(newSellerBalance.sub(oldSellerBalance)));

    }   catch (e) {
          console.error(e)
    }   finally {
          callback();
    }
}

