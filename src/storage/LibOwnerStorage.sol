pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibOwnerStorage {

    struct Storage {
        address owner;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.OWNER
        );
        assembly { stor_slot := storageSlot }
    }
}
