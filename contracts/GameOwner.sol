// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract GameOwner {
    address public owner;
    uint256 public stakeAmount; // so tien stake moi luot
    uint256 public rewardAmount; // phan thuong
    uint256 public targetScore;  // diem can de thang

    // address of the PlayerGame contract that is allowed to record wins
    address public playerGame;

    mapping(address => uint256) public rewards; // luu thuong cua tung nguoi choi

    event GameConfigured(uint256 stake, uint256 reward, uint256 target);
    event RewardAdded(address indexed player, uint256 amount);
    event RewardClaimed(address indexed player, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can do it !");
        _;
    }

    modifier onlyPlayerGame() {
        require(msg.sender == playerGame, "Only PlayerGame can call");
        _;
    }

    constructor(uint256 _stake, uint256 _reward, uint256 _target) {
        owner = msg.sender;
        stakeAmount = _stake;
        rewardAmount = _reward;
        targetScore = _target;
    }

    // re config game
    function updateGameConfig(uint256 _stake, uint256 _reward, uint256 _target) public onlyOwner {
        stakeAmount = _stake;
        rewardAmount = _reward;
        targetScore = _target;
        emit GameConfigured(_stake, _reward, _target);
    }

    // owner fundGame
    function fundGame() public payable onlyOwner() {}

    // owner sets which PlayerGame contract is authorized to record wins
    function setPlayerGame(address _playerGame) external onlyOwner {
        playerGame = _playerGame;
    }

    // winning game -> record win (callable only by authorized PlayerGame)
    function recordWin(address player) external onlyPlayerGame {
        require(address(this).balance >= rewardAmount, "Not enough money");
        rewards[player] += rewardAmount;
        emit RewardAdded(player, rewardAmount);
    }

    // player claim reward
    function claimReward() public {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "U dont have any rewards");
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
        emit RewardClaimed(msg.sender, reward);
    }

    // get the balance of game
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}