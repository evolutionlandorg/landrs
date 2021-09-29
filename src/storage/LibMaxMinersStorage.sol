pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibMaxMinersStorage {

    struct Storage {
        uint256 maxMiners;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.MAXMINERS
        );
        assembly { stor_slot := storageSlot }
    }
}
