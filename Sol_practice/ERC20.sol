// SPDX-License-Identifier: MIT
// WTF Solidity by 0xAA

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ERC20 is IERC20 {

    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;   // 代幣總和

    string public name;   // 名稱
    string public symbol;  // 符號
    
    uint8 public decimals = 18; // 最大小數位數

    // @dev 在部屬合約的時候利用建構子實現名稱跟符號
    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    // @dev 這邊宣告transfer函數並且實現代幣轉帳的程式碼
    // 特別注意returns在這裡做宣告
        function transfer(address recipient, uint amount) external override returns (bool) {
        //balanceOf是在IERC20.sol定義的一個function，接收一個address，然後回傳一個uint256型態的變數
        balanceOf[msg.sender] -= amount;    //送出的人戶頭扣錢
        balanceOf[recipient] += amount;     //接收的人戶頭加錢
        emit Transfer(msg.sender, recipient, amount);   //這邊使用emit關鍵字觸發事件
        return true;
    }

    // @dev 實現approve函數，還有代幣授權邏輯
    function approve(address spender, uint amount) external override returns (bool) {
        //allowance接收擁有者跟傳送者兩個address
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // @dev 實現`transferFrom`函数，代幣授權轉帳邏輯
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // @dev 創造代幣，從 `0` 地址轉帳給 調用者地址
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // @dev 銷毀代幣
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}