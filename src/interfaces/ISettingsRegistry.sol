pragma solidity >=0.4.24;

interface ISettingsRegistry {
    function addressOf(bytes32 _propertyName) external view returns (address);
    function uintOf(bytes32 _propertyName) external view returns (uint256);
}
