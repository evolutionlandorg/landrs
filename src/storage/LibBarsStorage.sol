pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibBarsStorage {

    // land bar
    struct Bar {
        address staker;
        address token;
        uint256 id;
        address resource;
    }

    struct Storage {
        // (landTokenId => (landBarIndex => BAR))
        mapping(uint256 => mapping(uint256 => Bar)) landId2Bars;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.LANDID2BARS
        );
        assembly { stor_slot := storageSlot }
    }
}
