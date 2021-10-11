pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibERC165Storage {

    struct Storage {
      mapping(bytes4 => bool) supportedInterfaces;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.SUPPORTEDINTERFACES
        );
        assembly { stor_slot := storageSlot }
    }
}
