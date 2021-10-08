pragma solidity ^0.6.7;

import "../storage/LibRegistryStorage.sol";
import "../interfaces/ISettingsRegistry.sol";

contract Registry {
    function registry() public view returns (ISettingsRegistry) {
        return ISettingsRegistry(LibRegistryStorage.getStorage().registry);
    }
}
