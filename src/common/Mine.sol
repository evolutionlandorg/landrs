pragma solidity ^0.6.7;

import "../storage/LibRegisterStorage.sol";

contract Mine {

	// For every seconds, the speed will decrease by current speed multiplying (DENOMINATOR_in_seconds - seconds) / DENOMINATOR_in_seconds
	// resource will decrease 1/10000 every day.
	uint256 public constant DENOMINATOR = 10000;

	uint256 public constant TOTAL_SECONDS = DENOMINATOR * (1 days);

	// rate precision
	uint128 public constant RATE_PRECISION = 10**8;

    function registry() public view returns (address) {
        return LibRegisterStorage.getStorage().registry;
    }

    function resourceReleaseStartTime() public view returns (uint256) {
        return LibRegisterStorage.getStorage().resourceReleaseStartTime;
    }

	function getTotalMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
		return getLandMiningStrength(_landId, _resource).add(getBarsMiningStrength(_landId, _resource));
	}
}
