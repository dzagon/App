// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract LipToken is ERC721, Ownable {
  constructor(string memory _name, string memory _symbol)
    ERC721(_name, _symbol)
  {}
 address public constant WTLOS = 0xaE85Bf723A9e74d6c663dd226996AC1b8d075AA9;

  uint256 COUNTER;
uint randNonce = 0;
  uint enchantProbability = 70;
  uint256 fee = 0.01 ether;
uint256 missionFee = 0.02 ether;

  struct Lip {
    string name;
    uint256 id;
    uint256 dna;
    uint power;
    uint8 level;
    uint8 rarity;
    uint8 endurance;
    bool weaponEquipped;
     bool armorEquipped;
    bool onSale;
   
  }

  struct Weapon{
    string name;
    uint256 id;
    uint256 power;
    uint256 price;
    uint8 enchant;
    address itemOwner;
    bool onSale;
  }
 
   struct Armor{
    string name;
    uint256 id;
    uint256 power;
    uint256 price;
    uint8 enchant;
    address itemOwner;
    bool onSale;
  }
   
   

  Lip[] public lips;
  Weapon[] public weapons;
  Armor[] public armors;
 

  event NewLip(address indexed owner, uint256 id, uint256 dna);
event NewWeapon(address indexed owner, uint256 id );
event NewOwner(string name, uint256 id, address itemOwner );
event Enchanted(uint256 id, uint256 power, uint256 enchant);

 function randMod(uint _modulus) internal returns(uint) {
    randNonce = randNonce +=1;
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }
  // Helpers
  function _createRandomNum(uint256 _mod) internal view returns (uint256) {
    uint256 randomNum = uint256(
      keccak256(abi.encodePacked(block.timestamp, msg.sender))
    );
    return randomNum % _mod;
  }

  function updateFee(uint256 _fee) external onlyOwner {
    fee = _fee;
  }

  function withdraw() external payable onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
  }

  // Creation
  function _createLip(string memory _name) internal {
require(balanceOf(msg.sender) == 0);
    uint8 randRarity = uint8(_createRandomNum(100));
    uint256 randDna = _createRandomNum(10**16);
    Lip memory newLip = Lip(_name, COUNTER, randDna,0, 1, randRarity, 100, false, false, true);
    lips.push(newLip);
    _safeMint(msg.sender, COUNTER);
    emit NewLip(msg.sender, COUNTER, randDna);
    COUNTER++;
  }

  function _createItem(string memory _name, uint256 _power) internal onlyOwner {
    Weapon memory newWeapon = Weapon(_name, COUNTER, _power,0 , 0,msg.sender, true);
    weapons.push(newWeapon);
    _safeMint(msg.sender, COUNTER);
    emit NewWeapon(msg.sender, COUNTER);
    COUNTER++;
  }

  function createRandomLip(string memory _name) public payable {
    require(msg.value >= fee);
    _createLip(_name);
  }

 function createWeapon(string memory _name, uint256 _power) public onlyOwner {
    _createItem(_name, _power);
  }

  // Getters
  function getLips() public view returns (Lip[] memory) {
    return lips;
  }

   function getWeapons() public view returns (Weapon[] memory) {
    return weapons;
  }
  function getOwnerWeapons(address _owner) public view returns (Weapon[] memory) {
    Weapon[] memory result = new Weapon[](balanceOf(_owner));
    uint256 counter = 0;
    for (uint256 i = 0; i < weapons.length; i++) {
      if (ownerOf(i) == _owner) {
        result[counter] = weapons[i];
        counter++;
      }
    }
    return result;
  }

  function getOwnerLips(address _owner) public view returns (Lip[] memory) {
    Lip[] memory result = new Lip[](balanceOf(_owner));
    uint256 counter = 0;
    for (uint256 i = 0; i < lips.length; i++) {
      if (ownerOf(i) == _owner) {
        result[counter] = lips[i];
        counter++;
      }
    }
    return result;
  }

  // Actions
  function levelUp(uint256 _lipId) public {
    require(ownerOf(_lipId) == msg.sender);
    Lip storage lip = lips[_lipId];
    lip.level++;
  }

  function sellWeapon(uint _weaponId, uint _price) public payable {
    require(ownerOf(_weaponId) == msg.sender, "You are not Owner of Item");
    Weapon storage weapon = weapons[_weaponId];
    require(weapon.onSale == true);
    
    weapon.onSale = false;
    weapon.price = _price;
    

  }
  function buyWeapon(uint _weaponId) public payable {
    
    Weapon storage weapon = weapons[_weaponId];
    require(weapon.onSale == false);
    _transfer(weapon.itemOwner, msg.sender, _weaponId);
    payable(weapon.itemOwner).transfer(msg.value);
    weapon.onSale = true;
    weapon.price = 0;
    weapon.itemOwner = msg.sender;
    

  }

 

   function equipWeapon(uint256 _lipId, uint256 _weaponId) public {
      Lip storage lip = lips[_lipId];
      Weapon storage weapon = weapons[_weaponId];
      require(ownerOf(_weaponId) == msg.sender); 
      require(balanceOf(msg.sender) > 0);
      require(ownerOf(_lipId) == msg.sender);
    require(lip.weaponEquipped == false, "Iteam is already equipped !");
      

      lip.power = (lip.power + weapon.power);
lip.weaponEquipped = true;
      
      
    }

    function unEquipWeapon(uint256 _lipId, uint256 _weaponId) public {
      Lip storage lip = lips[_lipId];
      Weapon storage weapon = weapons[_weaponId];
      require(ownerOf(_weaponId) == msg.sender); 
      require(balanceOf(msg.sender) > 0);
      require(ownerOf(_lipId) == msg.sender);
    require(lip.weaponEquipped == true, "Iteam is already equipped !");
      

      lip.power = (lip.power + weapon.power);
lip.weaponEquipped == false;
      
      
    }

   function Enchant(uint256 _lipId, uint256 _weaponId) public {
     Weapon storage weapon = weapons[_weaponId];
     Lip storage lip = lips[_lipId];
    require(ownerOf(_weaponId) == msg.sender, "You are not the Owner of this weapon!");
    require(ownerOf(_lipId) == msg.sender);
    require(weapon.onSale = true);
    require(weapon.enchant <= 16);
     uint8 randChance = uint8(_createRandomNum(100));
    if(randChance <= enchantProbability && lip.weaponEquipped == true){
 (weapon.enchant++);
    weapon.power += 3;
    lip.power = weapon.power;
    
    }else if(randChance <= enchantProbability && lip.weaponEquipped == false){
(weapon.enchant++);
    weapon.power += 3;
    
    } else if(randChance> enchantProbability && lip.weaponEquipped == true) {
        weapon.power = (weapon.power - weapon.enchant * 3);
      weapon.enchant = 0;
     lip.power = weapon.power;
    }else if(randChance> enchantProbability && lip.weaponEquipped == false) {
        weapon.power = (weapon.power - weapon.enchant * 3);
      weapon.enchant = 0;
     
    }
emit Enchanted(weapon.id, weapon.power, weapon.enchant);
   
   
  }

  function Mission(uint256 _lipId) public payable{
require(msg.value >= missionFee);
require(ownerOf(_lipId) == msg.sender);
Lip storage lip = lips[_lipId];
require(lip.power > 10);
uint8 randChance = uint8(_createRandomNum(100));
if(randChance <= 10 ){
 lip.endurance -= 1;
    
    }
    else if(randChance >= 11 ){
 lip.endurance -= 10;
    
    }

  }
}