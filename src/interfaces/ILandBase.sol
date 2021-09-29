pragma solidity >=0.4.24;

interface ILandBase {
    function getResourceRate(uint _landTokenId, address _resouceToken) external view returns (uint16);
}
