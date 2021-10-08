pragma solidity ^0.6.7;

import "../storage/LibSlot2Storage.sol";

contract Owner {
    function owner() public view returns (address) {
        return LibSlot2Storage.getStorage().owner;
    }
}
