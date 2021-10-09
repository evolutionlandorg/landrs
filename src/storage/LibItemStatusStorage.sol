pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibItemStatusStorage {

	// bar status
	struct Status {
		address staker;
		uint256 tokenId;
		uint256 index;
	}

    struct Storage {
        // (itemTokenAddress => (itemTokenId => STATUS))
        mapping(address => mapping(uint256 => Status)) itemId2Status;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.ITEMID2STATUS
        );
        assembly { stor_slot := storageSlot }
    }
}
