pragma solidity ^0.6.7;

interface IMintableERC20 {
    function mint(address _to, uint256 _value) external;
}
