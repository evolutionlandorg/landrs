pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibReleaseStorage {

    struct Storage {
        uint256 resourceReleaseStartTime;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.RESOURCERELEASESTARTTIME
        );
        assembly { stor_slot := storageSlot }
    }
}
