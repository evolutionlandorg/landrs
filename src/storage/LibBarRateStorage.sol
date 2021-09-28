pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibBarRateStorage {

    struct Storage {
        // (landTokenId => (resourceAddress => (landBarIndex => itemEnhancedRate)))
        mapping(uint256 => mapping(address => mapping(uint256 => uint256))) land2BarRate;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.LAND2BARRATE
        );
        assembly { stor_slot := storageSlot }
    }
}
