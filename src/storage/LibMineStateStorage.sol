pragma solidity ^0.6.7;

import "./LibStorage.sol";

library LibMineStateStorage {

    // Struct for recording resouces on land which have already been pinged.
    // 金, Evolution Land Gold
    // 木, Evolution Land Wood
    // 水, Evolution Land Water
    // 火, Evolution Land fire
    // 土, Evolution Land Silicon

    struct Storage {
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

    function getStorage(uint256 landId) internal pure returns (Storage storage stor) {
        uint256 slot = LibStorage.getStorageSlot(
            LibStorage.StorageId.LAND2RESOURCEMINESTATE
        );
        uint256 storageSlot = mapLocation(slot, landId);
        assembly { stor_slot := storageSlot }
    }

    function mapLocation(uint256 slot, uint256 key) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(key, slot)));
    }
}
