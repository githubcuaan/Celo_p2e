// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GameOwner.sol";
import "./PlayerGame.sol";

contract OwnerPlayer {
    GameOwner public gameOwner;
    PlayerGame public playerGame;

    struct Interaction {
        address player;
        uint256 score;
        bool won;
        uint256 timestamp;
    }

    Interaction[] public interactions;

    event GamePlayed(address indexed player, uint256 score, bool won, uint256 time);

    constructor(address _gameOwner, address _playerGame) {
        gameOwner = GameOwner(_gameOwner);
        playerGame = PlayerGame(payable(_playerGame));
    }

    function recordInteraction(address _player, uint256 _score, bool _won) external {
        require(msg.sender == address(playerGame), "Chi PlayerGame moi duoc goi");
        interactions.push(Interaction({
            player: _player,
            score: _score,
            won: _won,
            timestamp: block.timestamp
        }));
        emit GamePlayed(_player, _score, _won, block.timestamp);
    }

    function getTotalPlays() public view returns (uint256) {
        return interactions.length;
    }
}
