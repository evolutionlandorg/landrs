pragma solidity ^0.6.7;

import "zeppelin-solidity/math/SafeMath.sol";
import "../storage/LibMineStateStorage.sol";
import "../storage/LibMinerStorage.sol";
import "../storage/LibMaxMinersStorage.sol";

contract Apostle {
	using SafeMath for *;

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 internal constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";
	// 0x434f4e54524143545f544f4b454e5f5553450000000000000000000000000000
	bytes32 internal constant CONTRACT_TOKEN_USE = "CONTRACT_TOKEN_USE";
	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 internal constant CONTRACT_INTERSTELLAR_ENCODER = "CONTRACT_INTERSTELLAR_ENCODER";


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
