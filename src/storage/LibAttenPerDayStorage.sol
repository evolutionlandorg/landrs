pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibAttenPerDayStorage {

    struct Storage {
        uint256 attenPerDay;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.ATTENPERDAY
        );
        assembly { stor_slot := storageSlot }
    }
}
