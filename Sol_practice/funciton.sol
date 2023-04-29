// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//這邊是一個合約，可以看做一個class

contract FunctionTypes{

    //宣告number=5
    uint256 public number = 5;
    
    constructor() payable {}

    //定義一個add()函數，每次執行都number+1，external是一種修飾字，代表只能從合約外部訪問
    //internal就是代表只能從合約內部訪問
    function add() external{
        number = number + 1;
    }

    // pure: 使用pure/view關鍵字代表不修改上鏈狀態，不用付gas
    // 這邊使用pure是不能改變合約裡狀態變化的，pure只能在回傳值的時候改變value
    function addPure(uint256 _number) external pure returns(uint256 new_number){
        new_number = _number+1;
    }
    
    // view: 也是同理
    function addView() external view returns(uint256 new_number) {
        new_number = number + 1;
    }

    // internal: 内部
    function minus() internal {
        number = number - 1;
    }

    // 合约内的函数可以调用内部函数
    function minusCall() external {
        //這邊調用剛剛使用internal宣告的functions
        minus();
    }

    // payable: 
    function minusPayable() external payable returns(uint256 balance) {
        minus();
        //這邊的this指標指向我們引用的合約地址
        balance = address(this).balance;
    }
}