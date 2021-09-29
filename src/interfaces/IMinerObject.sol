pragma solidity >=0.4.24;

interface IMinerObject {
    function strengthOf(uint256 _tokenId, address _resourceToken, uint256 _landTokenId) external view returns (uint256);

}
