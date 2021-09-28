pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibMineStateStorage {

	// Struct for recording resouces on land which have already been pinged.
	// 金, Evolution Land Gold
	// 木, Evolution Land Wood
	// 水, Evolution Land Water
	// 火, Evolution Land fire
	// 土, Evolution Land Silicon
	struct ResourceMineState {
		mapping(address => uint256) mintedBalance;
		mapping(address => uint256[]) miners;
		mapping(address => uint256) totalMinerStrength;
		uint256 lastUpdateSpeedInSeconds;
		uint256 lastDestoryAttenInSeconds;
		uint256 industryIndex;
		uint128 lastUpdateTime;
		uint64 totalMiners;
		uint64 maxMiners;
	}

    struct Storage {
        mapping(uint256 => ResourceMineState) land2ResourceMineState;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.LAND2RESOURCEMINESTATE
        );
        assembly { stor_slot := storageSlot }
    }
}
