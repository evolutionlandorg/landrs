pragma solidity ^0.6.7;

import "../storage/LibRecoverAttenStorage.sol";
import "../storage/LibAttenPerDayStorage.sol";
import "../storage/LibRegistryStorage.sol";
import "../storage/LibReleaseStorage.sol";
import "../storage/LibSlot2Storage.sol";
import "../storage/LibAuthStorage.sol";
import "./ItemBar.sol";

contract Mine is ItemBar {

    function singletonLock() internal view returns (bool) {
        return LibSlot2Storage.getStorage().singletonLock;
    }

    function attenPerDay() internal view returns (uint256) {
        return LibAttenPerDayStorage.getStorage().attenPerDay;
    }

    function recoverAttenPerDay() internal view returns (uint256) {
        return LibRecoverAttenStorage.getStorage().recoverAttenPerDay;
    }

    ///////////////////////////////////////////////////////////////////////

    function resourceReleaseStartTime() public view returns (uint256) {
        return LibReleaseStorage.getStorage().resourceReleaseStartTime;
    }

    function getTotalMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
        return getLandMiningStrength(_landId, _resource).add(getBarsMiningStrength(_landId, _resource));
    }
}
