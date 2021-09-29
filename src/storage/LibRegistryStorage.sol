pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibRegistryStorage {

    struct Storage {
        address registry;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.REGISTRY
        );
        assembly { stor_slot := storageSlot }
    }
}
