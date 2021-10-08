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

	// For every seconds, the speed will decrease by current speed multiplying (DENOMINATOR_in_seconds - seconds) / DENOMINATOR_in_seconds
	// resource will decrease 1/10000 every day.
	uint256 internal constant DENOMINATOR = 10000;

	uint256 internal constant TOTAL_SECONDS = DENOMINATOR * (1 days);

	// 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
	bytes32 internal constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	// 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_GOLD_ERC20_TOKEN =
		"CONTRACT_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_WOOD_ERC20_TOKEN =
		"CONTRACT_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
	bytes32 internal constant CONTRACT_WATER_ERC20_TOKEN =
		"CONTRACT_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_FIRE_ERC20_TOKEN =
		"CONTRACT_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_SOIL_ERC20_TOKEN =
		"CONTRACT_SOIL_ERC20_TOKEN";

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 internal constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 internal constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

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
