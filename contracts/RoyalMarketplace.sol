// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@manifoldxyz/royalty-registry-solidity/contracts/IRoyaltyEngineV1.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";


struct Offer {
  IERC721 collection;
  uint256 token_id;
  uint256 priceInWei;
}

contract RoyalMarketplace is ReentrancyGuard{
      mapping(bytes32 => Offer) public offers;

      // https://royaltyregistry.xyz/lookup
      IRoyaltyEngineV1 royaltyEngineGoerli = IRoyaltyEngineV1(0xe7c9Cb6D966f76f3B5142167088927Bf34966a1f);
      
      event OnSale(bytes32 encoded, address indexed collection, uint256 token_id, address indexed owner);
      event Sold(address indexed collection, uint256 token_id, address buyer, uint256 price);

        // Sell NFT 
        function sellNFT(IERC721 collection, uint256 token_id, uint256 priceInWei) public {
              require(collection.ownerOf(token_id) == msg.sender, "Error: You must be the owner of this collection to sell");
              require(collection.getApproved(token_id) == address(this), "Error: Must be approved prior to selling on marketplace");
              
              bytes32 encoded = keccak256(abi.encodePacked(collection, token_id));
              
              offers[encoded] = Offer({
                  collection: collection,
                  token_id: token_id,
                  priceInWei: priceInWei
              });
              emit OnSale(encoded, address(collection), token_id, msg.sender);
        }

        // Buy NFT
        function buyNFT(bytes32 encoded) public payable nonReentrant  {
              Offer memory offer = offers[encoded];

              require(address(offer.collection) != address(0x0), "Error: offer not found");
              require(msg.value >= offer.priceInWei, "Error: current reserve price not met");

              address payable owner = payable(offer.collection.ownerOf(offer.token_id));

              emit Sold(address(offer.collection), offer.token_id, msg.sender, offer.priceInWei);

              // clear offer from offers listing since it's sold
              delete offers[encoded];

              (address payable[] memory recipients, uint256[] memory total) = royaltyEngineGoerli.getRoyalty(address(offer.collection), offer.token_id, msg.value);
              uint256 amountToSeller = offer.priceInWei;

              // transfer royalties
              for(uint i = 0; i < recipients.length; i++) {
                    amountToSeller = amountToSeller - total[i];
                    Address.sendValue(recipients[i], total[i]);
              }

              // transfer remaining  revenue to seller 
              Address.sendValue(owner, amountToSeller);

              // safely transfer nft
              offer.collection.safeTransferFrom(owner, msg.sender, offer.token_id);
        }

}
