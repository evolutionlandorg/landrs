pragma solidity >=0.4.24;

interface ITokenUse {
    function getTokenUser(uint256 _tokenId) external view returns (address);
    function addActivity(uint256 _tokenId, address _user, uint256 _endTime) external;
    function removeActivity(uint256 _tokenId, address _user) external;
}
