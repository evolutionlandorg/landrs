pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibSlot2Storage {

    struct Storage {
        address owner;
        bool singletonLock;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.SLOT_2
        );
        assembly { stor_slot := storageSlot }
    }
}
