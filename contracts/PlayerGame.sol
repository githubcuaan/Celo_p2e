// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./GameOwner.sol";
import "./OwnerPlayer.sol";

contract PlayerGame {
    GameOwner public gameOwner;
    OwnerPlayer public ownerPlayer;

    mapping(address => uint256) public playerScores;
    mapping(address => bool) public hasStaked;

    event PlayerStaked(address indexed player, uint256 amount);
    event PlayerScored(address indexed player, uint256 score);
    event PlayerWon(address indexed player, uint256 reward);

    // now takes owner address of GameOwner and optional OwnerPlayer address
    constructor(address _gameOwnerAddress, address _ownerPlayerAddress) {
        gameOwner = GameOwner(_gameOwnerAddress);
        if (_ownerPlayerAddress != address(0)) {
            ownerPlayer = OwnerPlayer(_ownerPlayerAddress);
        }
    }

    // stake for start the game
    function startGame() public payable {
        uint256 stake = gameOwner.stakeAmount();
        require(msg.value == stake, "u need to stake correct the stake");
        hasStaked[msg.sender] = true;
        emit PlayerStaked(msg.sender, stake);
    }

    // store the score when finish
    function finishGame(uint256 _score) public {
        require(hasStaked[msg.sender], "u need to stake first");
        playerScores[msg.sender] = _score;
        emit PlayerScored(msg.sender, _score);

        if (_score >= gameOwner.targetScore()) {
            gameOwner.recordWin(msg.sender); // will succeed if GameOwner.setPlayerGame(...) was set to this contract
            emit PlayerWon(msg.sender, gameOwner.rewardAmount());
        }

        // optional: notify OwnerPlayer log (only works if OwnerPlayer was supplied & its playerGame points to this contract)
        if (address(ownerPlayer) != address(0)) {
            ownerPlayer.recordInteraction(msg.sender, _score, _score >= gameOwner.targetScore());
        }

        hasStaked[msg.sender] = false;
    }

    // fallback nhận thưởng từ contract chủ
    receive() external payable {}
}