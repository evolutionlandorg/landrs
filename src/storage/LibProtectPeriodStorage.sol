pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibProtectPeriodStorage {

    struct Storage {
        // (itemTokenAddress => (itemTokenId => itemProtectPeriod))
        mapping(address => mapping(uint256 => uint256)) protectPeriod;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.PROTECTPERIOD
        );
        assembly { stor_slot := storageSlot }
    }
}
