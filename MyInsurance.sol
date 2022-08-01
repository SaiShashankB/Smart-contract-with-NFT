// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "ITM"){
    }

    struct newInsurance{
        string name;
        uint256 bill;
        uint256 amount;
        uint256 lastPayment;
        bool banned;
        bool validity;
    }

    mapping( address => newInsurance) public AllInsurance;

    uint256 public paymentPeriod = 30;

    function AddnewInsurance(address person, string memory _tokenURI, string memory _name, uint256 _bill, uint256 _amount, uint256 _lastPayment, bool _banned, bool _validity) public payable returns (uint256){
        uint256 newInsuranceId = _tokenIdCounter.current();
        _mint(person, newInsuranceId);
        _setTokenURI(newInsuranceId, _tokenURI);
        AllInsurance[person] = newInsurance(_name, _bill, _amount, _lastPayment, _banned, _validity);
        newInsurance storage MyInsurance = AllInsurance[person];
        MyInsurance.lastPayment = block.timestamp;
        MyInsurance.validity = true;
        //AllInsurance[person] = newInsurance(_name, _bill, _amount, _lastPayment, banned, validity);
        _tokenIdCounter.increment();
        return newInsuranceId;
    }

    function updateInsurance(address person) public {
        newInsurance storage requiredInsurance = AllInsurance[person];
        if(requiredInsurance.validity && requiredInsurance.lastPayment + paymentPeriod < block.timestamp){
            requiredInsurance.validity = false;
            requiredInsurance.banned = true;
        }
    }

    function CheckInsurance(address person) public view returns (bool insured){
      newInsurance storage searchInsurance = AllInsurance[person];
      if(searchInsurance.validity && !searchInsurance.banned && searchInsurance.lastPayment >= block.timestamp)
      {
          return true;
      }
      else{
          return false;
      }
    }

    function getClaim(address person) public view returns (uint256 claim){
        newInsurance storage getInsurance = AllInsurance[person];
        if(getInsurance.amount > 150000){
            return 150000;
        }

        else{
            getInsurance.amount;
        }
    }

    function InsuranceClaim(address payable person) public payable{
        newInsurance storage claimInsurance = AllInsurance[person];
        require(CheckInsurance(person) && claimInsurance.validity && !claimInsurance.banned);
        person.transfer(getClaim(person));
        claimInsurance.lastPayment = block.timestamp;
        updateInsurance(person);
    }

    function VerifiedInsurance(address person, uint256 bill_no, uint256 verAmount) public onlyOwner{
       newInsurance storage VerInsurance = AllInsurance[person];
       VerInsurance.bill = bill_no;
       VerInsurance.amount = verAmount;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
