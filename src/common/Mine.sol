pragma solidity ^0.6.7;

import "../storage/LibRecoverAttenStorage.sol";
import "../storage/LibAttenPerDayStorage.sol";
import "../storage/LibRegistryStorage.sol";
import "../storage/LibReleaseStorage.sol";
import "../storage/LibERC165Storage.sol";
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

    function supportsInterface(bytes4 _interfaceId) public view returns (bool) {
        return LibERC165Storage.getStorage().supportedInterfaces[_interfaceId];
    }

    function resourceReleaseStartTime() public view returns (uint256) {
        return LibReleaseStorage.getStorage().resourceReleaseStartTime;
    }

    function getTotalMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
        return getLandMiningStrength(_landId, _resource).add(getBarsMiningStrength(_landId, _resource));
    }
}
