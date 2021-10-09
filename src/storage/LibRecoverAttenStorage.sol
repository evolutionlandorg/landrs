pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibRecoverAttenStorage {

    struct Storage {
        uint256 recoverAttenPerDay;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.RECOVERATTENPERDAY
        );
        assembly { stor_slot := storageSlot }
    }
}
