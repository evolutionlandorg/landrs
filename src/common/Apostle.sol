pragma solidity ^0.6.7;

import "zeppelin-solidity/math/SafeMath.sol";
import "../storage/LibMineStateStorage.sol";
import "../storage/LibMinerStorage.sol";
import "../storage/LibMaxMinersStorage.sol";

contract Apostle {
	using SafeMath for *;

    function maxMiners() public view returns (uint256) {
        return LibMaxMinersStorage.getStorage().maxMiners;
    }

	function getLandMinedBalance(uint256 _landId, address _resource) public view returns (uint256) {
		return LibMineStateStorage.getStorage(_landId).mintedBalance[_resource];
	}

    function getLandMineStateLastUpdateTime(uint256 _landId) public view returns (uint256) {
        return LibMineStateStorage.getStorage(_landId).lastUpdateTime;
    }

	function getLandMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
		return LibMineStateStorage.getStorage(_landId).totalMinerStrength[_resource];
	}

	function landWorkingOn(uint256 _apostleTokenId) public view returns (uint256) {
		return LibMinerStorage.getStorage().miner2Index[_apostleTokenId].landTokenId;
	}

    function getMinerIndexInResource(uint256 _apostleTokenId) public view returns (uint64) {
        return LibMinerStorage.getStorage().miner2Index[_apostleTokenId].indexInResource;
    }

    function getMinerResource(uint256 _apostleTokenId) public view returns (address) {
        return LibMinerStorage.getStorage().miner2Index[_apostleTokenId].resource;
    }

	function getMinerOnLand(uint256 _landId, address _resource, uint256 _index) public view returns (uint256) {
        return LibMineStateStorage.getStorage(_landId).miners[_resource][_index];
	}

    function land2ResourceMineState(uint256 _landId) public view returns (uint256, uint256, uint256, uint128, uint64, uint64) {
        LibMineStateStorage.Storage storage stor = LibMineStateStorage.getStorage(_landId);
        return (
            stor.lastUpdateSpeedInSeconds,
            stor.lastDestoryAttenInSeconds,
            stor.industryIndex,
            stor.lastUpdateTime,
            stor.totalMiners,
            stor.maxMiners
        );
    }

    function miner2Index(uint256 _apostleTokenId) public view returns (uint256, address, uint64) {
        LibMinerStorage.MinerStatus memory sts = LibMinerStorage.getStorage().miner2Index[_apostleTokenId];
        return (sts.landTokenId, sts.resource, sts.indexInResource);
    }

}
