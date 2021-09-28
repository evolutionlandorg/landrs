pragma solidity ^0.6.7;

import "../storage/LibMineStateStorage.sol";
import "../storage/LibMinerStorage.sol";

contract Apostle {

	function getLandMinedBalance(uint256 _landId, address _resource) public view returns (uint256) {
		return LibMineStateStorage.getStorage().land2ResourceMineState[_landId].mintedBalance[_resource];
	}

    function getLandMineStateLastUpdateTime(uint256 _landId) public view returns (uint256) {
        return LibMineStateStorage.getStorage().land2ResourceMineState[_landId].lastUpdateTime;
    }

	function getLandMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
		return LibMineStateStorage.getStorage().land2ResourceMineState[_landId].totalMinerStrength[_resource];
	}

	function landWorkingOn(uint256 _apostleTokenId) public view returns (uint256) {
		return LibMinerStorage.getStorage().miner2Index[_apostleTokenId].landTokenId;
	}
}
