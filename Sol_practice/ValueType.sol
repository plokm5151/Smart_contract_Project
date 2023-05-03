// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
contract ValueTypes{
    //布林運算
    
    bool public _bool = true;

    bool public _bool1 = !_bool;
    bool public _bool2 = bool1 && _bool1;
    bool public _bool3 = bool1 || _bool1;
    bool public _bool4 = bool1 == _bool1;
    bool public _bool5 = bool1 != _bool1;
    //整數

    int public _int = -1;
    uint public _uint = 1;
    uint256 public _number = 20220330;
    //整數運算
    uint256 public _number1 =  _number + 1;
    uint256 public _number2 = 2**2;
    uint256 public _number3 = 7 % 2;
    bool public _number = _number2 > _number3;
    
    //地址類固定20字元
    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;

    //支付地址，比普通地址多了transfer跟send兩個成員方法，用於接收轉帳
    address payable public _address1 = payable(_address); //payable address可以轉帳查金額
    //地址類型的成員
    uint256 public balance  = _addess1.balance; /f/balance of address

    //固定長度的字結數組
    bytes32 public _bytes32 = "MiniSolidity";   //bytes: 
    bytes1 public _byte = _byte32[0];
    //不固定長度的就bytes
    
    //Enum，主要用於分配uint名稱ㄍ
    //將uint 0,1,2表示為Buy，Hold，Sell
    enum ActionSet{Buy, Hold,Sell}
    //創建enum變數 Actio
    ActionSet action = ActionSet.Buy;

    //enum可以跟uint顯式的轉換
    function enumToUint() external view returns(uint){
        return uint(action)
    }
    
}