// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract GatedStaking{

    uint constant rate = 3854;
    uint256 constant factor = 1e11;
    address owner;

    address constant cUSDAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    constructor(){
        owner = msg.sender;
    }

    struct stakeInfo{
        address staker;
        address tokenStaked;
        uint amountStaked;
        uint timeStaked;
    }

    mapping(address => mapping(address => stakeInfo)) public usersStake;

    function stake (address _tokenAddress, uint _amount) public {
        require(IERC20(cUSDAddress).balanceOf(msg.sender) > 3, "User does not have a Celo Token balance that is more than 3");
        require(IERC20(_tokenAddress).balanceOf(msg.sender) > _amount, "insufficient balance");
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        stakeInfo storage ST = usersStake[msg.sender][_tokenAddress];
        if(ST.amountStaked > 0){
            uint interest = _interestGotten(_tokenAddress);
            ST.amountStaked += interest;
        }
        ST.staker = msg.sender;
        ST.amountStaked = _amount;
        ST.tokenStaked = _tokenAddress;
        ST.timeStaked = block.timestamp;
    }


    function withdraw(address _tokenAddress, uint _amount) public{
        stakeInfo storage ST = usersStake[msg.sender][_tokenAddress];
        //require(ST.timeStaked > 0, "You have no staked token here");
        require(ST.amountStaked > _amount, "insufficient balance");
        uint interest = _interestGotten(_tokenAddress);
        ST.amountStaked -= _amount;
        uint totalAmount = _amount + interest;
        IERC20(_tokenAddress).transferFrom(address(this), msg.sender, totalAmount);

    }


    function _interestGotten(address _tokenAddress) internal view returns(uint ){
        stakeInfo storage ST = usersStake[msg.sender][_tokenAddress];
        uint interest;
        if(ST.amountStaked > 0){
            uint time = ST.timeStaked - block.timestamp;
            uint principal = ST.amountStaked;
            interest = principal * rate + time;
             interest /=  factor;
        }
        return interest;
    }

    // function showInterest(address _tokenAddress) external view returns(uint){
    //     uint interest = _interestGotten(_tokenAddress);
    //     return interest;
    // }

    // function amountStaked(address _tokenAddress) external view returns(uint){
    //     stakeInfo storage ST = usersStake[msg.sender][_tokenAddress];
    //     return  ST.amountStaked;
    // }

}

interface IERC20{
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

}