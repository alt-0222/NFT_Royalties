// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Migrations {
      address public owner = msg.sender;
      uint public last_migration;

      modifier restricted() {
            require(msg.sender == owner, "Error: this function is restricted to the contract owner");
            _;    // check first
      }

      function completedMigration(uint completed) public restricted {
            last_migration = completed;
      }
}