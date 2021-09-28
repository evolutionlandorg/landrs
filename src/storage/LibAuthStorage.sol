pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibAuthStorage {

    struct Storage {
        address authority;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.AUTHORITY
        );
        assembly { stor_slot := storageSlot }
    }
}
