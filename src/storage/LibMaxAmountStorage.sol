pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibMaxAmountStorage {

    struct Storage {
        uint256 maxAmount;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.MAXAMOUNT
        );
        assembly { stor_slot := storageSlot }
    }
}
