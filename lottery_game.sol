// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ---------------------------------------------------------------
// ERC20Interface 3-42
// ---------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external  view returns (uint balance);
    function allowance(address tokenOwner, address spender) external  view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);   //這邊的tokens就是amount
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ---------------------------------------------------------------
// SafeMath library 3-44
// ---------------------------------------------------------------
contract SafeMath {
    function safeAdd (uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "Invalid operation!");
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a==0 || c/a==b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ---------------------------------------------------------------
// ERC20 Content 3-52~3-58
// ---------------------------------------------------------------
contract myToken is ERC20Interface, SafeMath{

    // 3 optional rules
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;
    address public owner;
    uint public ticketPrice;
    uint public ticket;
    uint public pool;
    uint public minimumPlayers;
    bool public lotteryOpen;
    uint public lotteryEndTime;
    uint public lastFaucetTime;
    uint public lastWinnerTime;
    address public lastFaucetAddress;
    address[] public players;
    address public Banker;


    mapping(address => uint256) public ticketCount;
    mapping(address => uint256) public override balanceOf;  //將address用mapping的方式映射到uint256上，之後使用陣列就可以輸入address輸出uint256型別了
    mapping(address => mapping(address => uint256)) allowed;        //用來儲存tokenown對於spender的授權金額
    //mapping(address => uint) public balances;   //用來判斷是否領過錢了
    mapping(address => bool) public hasTicket;

    modifier onlyOwner {        //用modifier修飾函數，讓只有合約擁有者可以調用此函數
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
    
    

    constructor()
    {
        // optional rules
        name = "m11115101";     //代幣名稱
        symbol = "M11115101";   //代幣的簡稱
        decimals = 18;

        _totalSupply = 0;
        balanceOf[msg.sender] = _totalSupply;        //nsg是一種全域變數，代表當前的交易訊息，這邊也就是交易訊息的sender擁有的餘額==totalSupply
        emit Transfer(address(0), msg.sender, _totalSupply);       //emit是一種使function立即生效的指令
        
        owner = msg.sender;     //合約的擁有者==msg.sender/Banker
        ticketPrice = 100;
        ticket= 0;      
        pool = 0;
        minimumPlayers = 2;
        lotteryOpen = false;
        lotteryEndTime = 0;
        ticket=0;
        Banker=msg.sender;
        lastFaucetAddress = address(0x0);
        lastWinnerTime = 0;
    }

    function whoIsBanker() public view returns(address){
        return Banker;
    }

    function faucet() public {
        require(balanceOf[msg.sender] == 0, "You have already received tokens.");
        if(lastFaucetAddress == msg.sender){
            require(block.timestamp > lastFaucetTime + 30 seconds, "You can only receive tokens once every 30 seconds.");
        }
        balanceOf[msg.sender] += 500;
        _totalSupply += 500;
        lastFaucetTime = block.timestamp;
        lastFaucetAddress = msg.sender;
        emit Transfer(address(0), msg.sender, 500);
        //require(block.timestamp > lotteryEndTime + 30 seconds, "You can only receive tokens once every 30 seconds.");
    }

    // implement mandatory rules
    function totalSupply() public view override returns (uint)      //view代表這個funciton不能從內部更改變數，只能使用return的方式去操作，而returns這邊只是單純宣告回傳值的型別屬於uint，而return才是真正的回傳值
    {
        //返回tokens的總供應量
        return _totalSupply - balanceOf[address(0)];
    }

    //function balanceOf(address tokenOwner) public view override returns (uint balance)      //會接收一個地址然後映射到一個uint的整數，也就是說輸入一個地址就可以看餘額
    //{
    //    return balances[tokenOwner];        //接收一個地址之後回傳那個地址剩下的餘額
    //}
    function transfer(address to, uint tokens) public override returns (bool success)   //
    {
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], tokens);       //讓msg.sender的balances運行減法，減去送出去的tokens
        balanceOf[to] = safeAdd(balanceOf[to], tokens);       //讓被發送的人擁有我們送出去的tokens
        emit Transfer(msg.sender, to, tokens);              //emit立即生效這個function，Transfer接收三個引數，
        return true;                                        //回傳一個bool型態的true
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining)   //餘額接收兩個address
    {
        return allowed[tokenOwner][spender];            //總體來說，這個函數主要是為了查詢一個地址對另一個地址的授權金額，以保證在交易 token 時，spender 不會超過被授權的額度。
    }

    function approve(address spender, uint tokens) public override returns (bool success)       //接收地址跟tokens的數量
    {
        allowed[msg.sender][spender] = tokens;      //授予spender(自己)tokens
        emit Approval(msg.sender, spender, tokens);         //生成一個Approval事件，這個事件會被記錄到區塊鏈上。這個事件包含三個參數，分別是授權人（msg.sender）、被授權人（spender）以及被授權代幣的數量（tokens）。
        return true;        //回傳bool值，判斷function是否成功
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success)
    {
        balanceOf[from] = safeSub(balanceOf[from], tokens);         //查看餘額是否足夠支付交易的金額
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);     //
        balanceOf[to] = safeAdd(balanceOf[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    //function createTokens(uint tokens) external{
     //   balanceOf[msg.sender] += tokens;
     //   _totalSupply += tokens;
    //    emit Transfer(address(0), msg.sender, tokens);
    //}

    function random() private view returns (uint){
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    }

    function buyTicket() public {
        require(balanceOf[msg.sender] >= ticketPrice, "You don't have enough tokens.");
        //require(!hasTicket[msg.sender], "You already have a ticket.");
        require(msg.sender != Banker);
        balanceOf[msg.sender] -= ticketPrice;
        if(!hasTicket[msg.sender]){
            players.length+1;
            players.push(msg.sender);
        }
        hasTicket[msg.sender] = true;
        ticketCount[msg.sender]++;  //增加玩家的票數
        pool += ticketPrice;
        if (players.length >= minimumPlayers && !lotteryOpen) {
            lotteryOpen = true;
            lotteryEndTime = block.timestamp + 3 minutes;
        }
    }

    /*function Winner() public onlyOwner {
        require(block.timestamp > lotteryEndTime, "The lottery is still open.");
        require(players.length >= minimumPlayers, "There are not enough players.");
        uint winningIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players))) % players.length;
        address winner = players[winningIndex];
        balanceOf[winner] += pool * 9 / 10;
        balanceOf[msg.sender] = pool * 1 / 10;
        lotteryOpen = false;
        pool=0;
        hasTicket[winner] = false;
        delete players;
    }*/

    function winner() public onlyOwner returns(address){
        //require(block.timestamp > lotteryEndTime, "The lottery is still open .");
        require(players.length >= minimumPlayers, "There are not enough players.");
        if(lastWinnerTime!=0){
            require(block.timestamp > lastWinnerTime + 180, "Can not choose the winner again whthin 180 seconds");
        }
        
        //計算票數
        uint totalTickets = 0;
        for(uint i = 0; i< players.length; i++){
            totalTickets += ticketCount[players[i]];
        }

        //生成隨機數
        uint randomNumber = random();

        //根據隨機數根票數計算獲勝者
        uint winningIndex = randomNumber % totalTickets;
        uint accumulatedTickets = 0;
        address winner;
        
        for(uint i = 0;i < players.length; i++){
            accumulatedTickets += ticketCount[players[i]];
            if(winningIndex < accumulatedTickets){
                winner = players[i];
                break;
            }
        }

        //將奬池分配給獲勝者
        uint winnings = pool *9/10;
        balanceOf[winner] += winnings;
        balanceOf[msg.sender] += pool - winnings;

        //重置彩票遊戲
        lotteryOpen = false;
        pool = 0;
        hasTicket[winner] = false;
        lastWinnerTime = block.timestamp;
        delete players;
        return winner;
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function getNumberOfPlayers() public view returns (uint) {
        return players.length;
    }

    function getTicketCount(address player) public view returns(uint){
        return ticketCount[player];
    }
}
