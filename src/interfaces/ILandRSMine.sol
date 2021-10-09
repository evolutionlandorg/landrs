pragma solidity ^0.6.7;

interface ILandRSMine {
    function mine(uint256 _landTokenId) external;
    function claimItemResource(address _itemToken, uint256 _itemId) external;
}
