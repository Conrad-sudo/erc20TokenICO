// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0<0.9.0;

//EIP-20:ERC20 Token Standard


interface ERC20Interface{

    //These are the only 3 mandatory functions needed for an erc20 token
    function totalSupply()external view returns(uint);
    function balanceOf(address tokenOwner) external view returns(uint balance);
    function transfer(address to, uint amount) external returns(bool success);


    //these are the 3 additional function needed to make a fully ERC-20 compliable token
    function allowance(address tokenOwner,address spender) external view returns(uint remaining);
    function approve(address spender, uint tokens) external returns(bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from,address indexed to, uint tokens);
    event Approval(address indexed tokenOwner,address indexed  spender, uint tokens);
}


   contract ArkCoin is ERC20Interface{

       string public name= "ArkCoin";
       string public symbol="ARK";
       uint public decimals = 0;
        //though this is a state variable it creates a getter function beacuse its public so we have to use "override"
       uint public override totalSupply;
       address public founder;
       mapping(address=>uint) public balances;
       //a mapping that mapps the addresses of token owner to the addresses of the accounts they allow to transfer tokens from their balance
       mapping(address=>mapping(address=>uint)) allowed;


       constructor(){

           totalSupply=1000000;
           founder=msg.sender;
           balances[founder]=totalSupply;
       }

       function balanceOf(address tokenOwner)   public view override returns(uint balance){
           return balances[tokenOwner];
       }


       function transfer(address to, uint amount) public virtual override returns(bool success){
           //Fuction reverts on failure
           require(amount <= balances[msg.sender],"You dont have enough in your account");

           //debit the sender account
           balances[msg.sender]-=amount;
           //credit the receiver account,adding it to the mapping
           balances[to]+=amount;
           //emit an event
           emit Transfer(msg.sender,to,amount);
           return true;

       }

        //retruns the number of tokens the token owner has allowed the spender to transfer
       function allowance( address tokenOwner, address spender) view public override returns(uint){

            return allowed[tokenOwner][spender];
       }

       

        //allows the token owner to allow the  spender to spend a given amount
         function approve(address spender, uint tokens) public override returns(bool success){
             require(tokens<=balances[msg.sender]);

             allowed[msg.sender][spender]=tokens;

             //emit the Approval event
             emit Approval(msg.sender,spender,tokens);
             return true;

         }



        //allows a speder to withdraw from the sender account up until the allowance
        function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success){

            //make sure the tokens the spender wants to send are not more than the allowed amount
            require(allowed[from][msg.sender]>=tokens,"Tokens exceed the allowed limit");
            //check that the balance of the sender is  more than the amount the spender wants to transfer
            require(balances[from]>=tokens,"The approver does not have enough balance");

            //debit the sender account
           balances[from]-=tokens;

           //credit the receiver account,adding it to the mapping
           balances[to]+=tokens;

           //emit an event
           emit Transfer(from,to,tokens);

            //Update the mapping
            allowed[from][msg.sender]-=tokens;

            return true;


        }





    }



contract ARKtokenICO is ArkCoin{
    
    address public admin;
    address payable public depositAdr;
    uint public tokenPrice= 0.01 ether;
    uint public minInvestment=0.01 ether;
    uint public maxInvestment=5 ether;
    uint public hardcap= 300 ether;
    uint public raisedAmount;
    uint public icoStart= block.timestamp;
    uint public icoEnd = block.timestamp+ 604800;
    // lockup time for the tokens to prevent investors from dumping the coins
    uint tokenTradeStart=icoEnd+86400;
    

    enum state{beforeStart,running,afterEnd,halted}
    state public icoState=state.beforeStart;


    constructor(address _depositAdr){

        depositAdr=payable (_depositAdr);
        admin=msg.sender;

       
    }

    modifier restricted( ){

        require(msg.sender==admin,"Admin access only");
        _;

    }

    //allows admin to halt the ico incase of emergency  
    function halt() public restricted {
        icoState=state.halted;
    }

     //allows admin to resume ico
    function resume() public restricted{
        icoState=state.running;
    }

    //allows admin to change deposit address
    function changeDepositAdr(address newDepositAdr) public restricted{

            depositAdr=payable(newDepositAdr);
    }


    function getCurrentState() public view returns(state){

        if(icoState==state.halted){
            return state.halted;
        }

        else if (block.timestamp<icoStart){
            return state.beforeStart;
        }
        else if( block.timestamp >= icoStart && block.timestamp <= icoEnd){
            return state.running;
        }

        else {
            return state.afterEnd;
        }


    }

    event InvestmentMade(address investor, uint value,uint token);

    //allows an investor to send money and get alloted a number of tokens
    function invest() public payable returns(bool){

        //get the current state of the ico
        icoState=getCurrentState();
        require(icoState==state.running,"The ICO is not running");
        require(msg.value >=minInvestment && msg.value <=maxInvestment,"Investment amount is out of bounds");
        raisedAmount+=msg.value;
        require(raisedAmount<=hardcap,"Hardcap has been reached");
        //the number of tokens alotted to the investor
        uint tokens=msg.value/tokenPrice;
        //set the balances of the investors in the erc20 token contract
        balances[msg.sender]+=tokens;
        //subtract from the founders account
        balances[founder]-=msg.value/tokenPrice;
        //transfer Eth to the deposit address
        depositAdr.transfer(msg.value);

        //emit event
        emit InvestmentMade(msg.sender, msg.value, tokens);

        return true;


    }


    receive() external payable{

        invest();
    }


    //use signature of the transfer function in the base contract to inforce the lockup of tokens
    function transfer(address to, uint amount) public override returns(bool success){
        require(block.timestamp>=tokenTradeStart );
        //call the function of the base ERC-20 contract
        super.transfer(to,amount);
        return true;
    }

    //use signature of the transfer function in the base contract to inforce the lockup of tokens
    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(block.timestamp>=tokenTradeStart );
        //call the function of the base ERC-20 contract
        super.transferFrom(from,to,tokens);
        return true;

    
    }


//allows anyone to burn tokens
    function burn() public returns(bool){

        icoState=getCurrentState();

        require(icoState==state.afterEnd);

        balances[founder]=0;
        return true;

    }




}
