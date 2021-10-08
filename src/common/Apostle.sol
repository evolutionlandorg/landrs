pragma solidity ^0.6.7;

import "../storage/LibMineStateStorage.sol";
import "../storage/LibMinerStorage.sol";
import "../storage/LibMaxMinersStorage.sol";

contract Apostle {

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

}
