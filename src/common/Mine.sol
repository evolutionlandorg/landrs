pragma solidity ^0.6.7;

import "../storage/LibAuthStorage.sol";
import "../storage/LibSlot2Storage.sol";
import "../storage/LibRegistryStorage.sol";
import "../storage/LibReleaseStorage.sol";
import "./ItemBar.sol";

contract Mine is ItemBar {
	event StartMining(
		uint256 minerTokenId,
		uint256 landId,
		address _resource,
		uint256 strength
	);
	event StopMining(
		uint256 minerTokenId,
		uint256 landId,
		address _resource,
		uint256 strength
	);
	event LandResourceClaimed(
		address owner,
		uint256 landId,
		uint256 goldBalance,
		uint256 woodBalance,
		uint256 waterBalance,
		uint256 fireBalance,
		uint256 soilBalance
	);
	event ItemResourceClaimed(
		address owner,
		address itemToken,
		uint256 itemTokenId,
		uint256 goldBalance,
		uint256 woodBalance,
		uint256 waterBalance,
		uint256 fireBalance,
		uint256 soilBalance
	);

	// For every seconds, the speed will decrease by current speed multiplying (DENOMINATOR_in_seconds - seconds) / DENOMINATOR_in_seconds
	// resource will decrease 1/10000 every day.
	uint256 internal constant DENOMINATOR = 10000;

	uint256 internal constant TOTAL_SECONDS = DENOMINATOR * (1 days);

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 internal constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f544f4b454e5f5553450000000000000000000000000000
	bytes32 internal constant CONTRACT_TOKEN_USE = "CONTRACT_TOKEN_USE";

    // 0x434f4e54524143545f4c414e445f4d494e450000000000000000000000000000
    bytes32 internal constant CONTRACT_LAND_MINE = "CONTRACT_LAND_MINE";

    function singletonLock() internal view returns (bool) {
        return LibSlot2Storage.getStorage().singletonLock;
    }

    /////////////////////////////////////////////////////////////////////

    function resourceReleaseStartTime() public view returns (uint256) {
        return LibReleaseStorage.getStorage().resourceReleaseStartTime;
    }

	function getTotalMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
		return getLandMiningStrength(_landId, _resource).add(getBarsMiningStrength(_landId, _resource));
	}
}
