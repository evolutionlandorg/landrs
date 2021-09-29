pragma solidity >=0.4.24;

interface IInterstellarEncoder {
    function getObjectClass(uint256 _tokenId) external view returns (uint8);
    function getObjectAddress(uint256 _tokenId) external view returns (address);
}
