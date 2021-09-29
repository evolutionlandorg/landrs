pragma solidity ^0.6.7;

import "../storage/LibRegisterStorage.sol";
import "../storage/LibReleaseStorage.sol";
import "../interfaces/ISettingsRegistry.sol";
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
	event ResourceClaimed(
		address owner,
		uint256 landTokenId,
		uint256 goldBalance,
		uint256 woodBalance,
		uint256 waterBalance,
		uint256 fireBalance,
		uint256 soilBalance
	);

	// For every seconds, the speed will decrease by current speed multiplying (DENOMINATOR_in_seconds - seconds) / DENOMINATOR_in_seconds
	// resource will decrease 1/10000 every day.
	uint256 public constant DENOMINATOR = 10000;

	uint256 public constant TOTAL_SECONDS = DENOMINATOR * (1 days);

	// 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	// 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN =
		"CONTRACT_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN =
		"CONTRACT_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
	bytes32 public constant CONTRACT_WATER_ERC20_TOKEN =
		"CONTRACT_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN =
		"CONTRACT_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN =
		"CONTRACT_SOIL_ERC20_TOKEN";

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	// 0x434f4e54524143545f544f4b454e5f5553450000000000000000000000000000
	bytes32 public constant CONTRACT_TOKEN_USE = "CONTRACT_TOKEN_USE";

    // 0x434f4e54524143545f4c414e445f4d494e450000000000000000000000000000
    bytes32 public constant CONTRACT_LAND_MINE = "CONTRACT_LAND_MINE";

    function registry() public view returns (ISettingsRegistry) {
        return ISettingsRegistry(LibRegisterStorage.getStorage().registry);
    }

    function resourceReleaseStartTime() public view returns (uint256) {
        return LibReleaseStorage.getStorage().resourceReleaseStartTime;
    }

	function getTotalMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
		return getLandMiningStrength(_landId, _resource).add(getBarsMiningStrength(_landId, _resource));
	}
}
