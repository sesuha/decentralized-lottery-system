// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedLottery is Ownable {
    address[] public participants;
    uint256 public lotteryEndTime;
    uint256 public ticketPrice;

    event LotteryEntered(address indexed participant);
    event WinnerSelected(address indexed winner, uint256 amountWon);

    constructor(uint256 _ticketPrice, uint256 _duration, address _initialOwner) Ownable(_initialOwner) {
        ticketPrice = _ticketPrice;
        lotteryEndTime = block.timestamp + _duration;
    }

    function enter() external payable {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(block.timestamp < lotteryEndTime, "Lottery has ended");

        participants.push(msg.sender);
        emit LotteryEntered(msg.sender);
    }

    function pickWinner() external onlyOwner {
        require(block.timestamp >= lotteryEndTime, "Lottery is still ongoing");
        require(participants.length > 0, "No participants in the lottery");

        uint256 randomIndex = random() % participants.length;
        address winner = participants[randomIndex];

        uint256 prize = address(this).balance;
        (bool success, ) = winner.call{value: prize}("");
        require(success, "Transfer failed");

        emit WinnerSelected(winner, prize);

        participants = new address[](0) ;
        lotteryEndTime = block.timestamp + 1 days; 
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, participants)));
    }

    function getParticipants() external view returns (address[] memory) {
        return participants;
    }
}
