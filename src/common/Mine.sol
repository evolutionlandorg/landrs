pragma solidity ^0.6.7;

import "../storage/LibRegisterStorage.sol";
import "../storage/LibReleaseStorage.sol";
import "./ItemBar.sol";

contract Mine {

	// For every seconds, the speed will decrease by current speed multiplying (DENOMINATOR_in_seconds - seconds) / DENOMINATOR_in_seconds
	// resource will decrease 1/10000 every day.
	uint256 public constant DENOMINATOR = 10000;

	uint256 public constant TOTAL_SECONDS = DENOMINATOR * (1 days);

	// rate precision
	uint128 public constant RATE_PRECISION = 10**8;

    // 0x434f4e54524143545f4c414e445f4d494e450000000000000000000000000000
    bytes32 public constant CONTRACT_LAND_MINE = "CONTRACT_LAND_MINE";

    function registry() public view returns (address) {
        return LibRegisterStorage.getStorage().registry;
    }

    function resourceReleaseStartTime() public view returns (uint256) {
        return LibReleaseStorage.getStorage().resourceReleaseStartTime;
    }

	function getTotalMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
		return getLandMiningStrength(_landId, _resource).add(getBarsMiningStrength(_landId, _resource));
	}
}
