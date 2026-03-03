//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract ClikCounter{
    uint256 public counter;
    function click() public
    {
        counter++;
    }
}
