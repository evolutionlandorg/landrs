pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibMinerStorage {

	struct MinerStatus {
		uint256 landTokenId;
		address resource;
		uint64 indexInResource;
	}

    struct Storage {
        mapping(uint256 => MinerStatus) miner2Index;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.MINER2INDEX
        );
        assembly { stor_slot := storageSlot }
    }
}
