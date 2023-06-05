// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AssetTransfer {
    address public owner;
    bool public deceased;
    uint256 public createdAt;
    uint256 public celoBalance;

    address[] familyWallets;
    mapping(address => uint256) inheritance;

    event InheritanceSet(address indexed wallet, uint256 amount);
    event Payout(address indexed wallet, uint256 amount);
    event Deceased();

    constructor() payable {
        owner = msg.sender;
        createdAt = block.timestamp;
        celoBalance = msg.value;
        deceased = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier mustBeDeceased() {
        require(deceased == true, "The owner must be marked as deceased");
        _;
    }

    function getTotalInheritance() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < familyWallets.length; i++) {
            total += inheritance[familyWallets[i]];
        }
        return total;
    }

    function setInheritance(address wallet, uint256 amount) public onlyOwner {
        require(wallet != address(0), "Invalid wallet address");
        require(amount > 0, "Inheritance amount must be greater than zero");
        require(
            celoBalance >= getTotalInheritance() + amount,
            "Total inheritance exceeds contract balance"
        );

        familyWallets.push(wallet);
        inheritance[wallet] = amount;

        emit InheritanceSet(wallet, amount);
    }

    function payout() private mustBeDeceased {
        for (uint256 i = 0; i < familyWallets.length; i++) {
            address payable wallet = payable(familyWallets[i]);
            uint256 amount = inheritance[wallet];
            wallet.transfer(amount);

            emit Payout(wallet, amount);
        }
    }

    function markAsDeceased() public onlyOwner {
        deceased = true;
        payout();

        emit Deceased();
    }


        // Allow the contract to receive funds
receive() external payable {
    }
}
