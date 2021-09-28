pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibItemBalanceStorage {

    struct Storage {
        // (itemTokenAddress => (itemTokenId => (resourceAddress => mined balance)))
        mapping(address => mapping(uint256 => mapping(address => uint256))) itemMinedBalance;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.ITEMMINEDBALANCE
        );
        assembly { stor_slot := storageSlot }
    }
}
