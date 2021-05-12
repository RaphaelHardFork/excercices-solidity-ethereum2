// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Deployed at 0xf5811343e29d529D3C0b8C052709AABeaf469a29 on Rinkeby
// recipient 0x9086701Ecc7eFe724fC906DDF5Bf7D481FA3B055
// Birthday date : 14/05/2021 | contributors : 2
    
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
    
contract Birthday {
    using Address for address payable;
// storage
    address private _recipient;
    uint256 private _present;
    uint256 private _contributions;
    mapping (address => bool) private _contributors;
    uint256 private _birthdayDate;
    
    // event
    event Contribution(address indexed recipient_,address contributor_,uint256 amount);

    constructor (address recipient_,uint256 year,uint256 month,uint256 day){
        _birthdayDate=_humanDateToEpochTime(year,month,day);
        require(_birthdayDate>block.timestamp,"Birthday: This date is already passed.");
        _recipient=recipient_;
    }
    
    modifier afterDayD (){
        require(block.timestamp>=_birthdayDate, "Birthday: You have to wait your birthday to withdraw your present.");
        _;
    }
    
    modifier onlyRecipient (){
        require(msg.sender==_recipient, "Birthday: You are not the recipient of this present.");
        _;
    }
    
    receive()external payable {
        _deposit(msg.value);
    }
    
    function offer() external payable{
        _deposit(msg.value);
    }
    
    function getPresent() public onlyRecipient afterDayD {
        require (_present!=0,"Birthday: Sorry, nobody have done any contributions for your present..");
        _present=0;
        payable(msg.sender).sendValue(address(this).balance);
    }
    
    function present() public view returns(uint256){
        return _present;
    }
    
    function nbContributors() public view returns(uint256){
        return _contributions;
    }
    
    function timeBeforeBirthday() public view returns(uint256){
        return _birthdayDate-block.timestamp;
    }
    
    
    function _deposit(uint256 amount) private {
        if (_contributors[msg.sender]==false){
            _contributions++;
            _contributors[msg.sender]==true;
        }
        _present+=amount;
        emit Contribution(_recipient,msg.sender,amount);
    }
    
    function _humanDateToEpochTime(uint256 year,uint256 month, uint256 day)private pure returns (uint256){
        require(year>1970 && month<=12&&day<=31,"Birthday: wrong input in the date");
        return ((year - 1970)*31556926)+(2629743*(month-1)+(86400*(day-1))+36000);
    }
}