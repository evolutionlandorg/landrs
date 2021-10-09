pragma solidity ^0.6.7;

import "../storage/LibBarRateStorage.sol";
import "../storage/LibMaxAmountStorage.sol";
import "../storage/LibItemBalanceStorage.sol";
import "../storage/LibBarsStorage.sol";
import "../storage/LibProtectPeriodStorage.sol";
import "../storage/LibItemStatusStorage.sol";
import "./Apostle.sol";

contract ItemBar is Apostle {
    // rate precision
    uint128 internal constant RATE_PRECISION = 10**8;

    function maxAmount() public view returns (uint256) {
        return LibMaxAmountStorage.getStorage().maxAmount;
    }

    function getBarsMiningStrength(uint256 _landId, address _resource) public view returns (uint256) {
        return getLandMiningStrength(_landId, _resource).mul(getBarsRate(_landId, _resource)).div(RATE_PRECISION);
    }

    function getBarsRate(uint256 _landId, address _resource) public view returns (uint256 barsRate) {
        for (uint256 i = 0; i < maxAmount(); i++) {
            barsRate = barsRate.add(getBarRate(_landId, _resource, i));
        }
    }

    function getBarRate(uint256 _landId, address _resource, uint256 _index) public view returns (uint256) {
        return LibBarRateStorage.getStorage().land2BarRate[_landId][_resource][_index];
    }

    function getBarItem(uint256 _tokenId, uint256 _index) public view returns (address, uint256, address) {
        require(_index < maxAmount(), "Furnace: INDEX_FORBIDDEN.");
        LibBarsStorage.Bar memory bar = LibBarsStorage.getStorage().landId2Bars[_tokenId][_index];
        return (bar.token, bar.id, bar.resource);
    }

    function getItemMinedBalance(address _itemToken, uint256 _itemId, address _resource) public view returns (uint256) {
        return LibItemBalanceStorage.getStorage().itemMinedBalance[_itemToken][_itemId][_resource];
    }

    function isNotProtect(address _token, uint256 _id) public view returns (bool) {
        return LibProtectPeriodStorage.getStorage().protectPeriod[_token][_id] < now;
    }

    function getLandIdByItem(address _item, uint256 _itemId) public view returns (address, uint256) {
        LibItemStatusStorage.Status memory sts = LibItemStatusStorage.getStorage().itemId2Status[_item][_itemId];
        return (sts.staker, sts.tokenId);
    }

    function getBarMiningStrength(uint256 _landId, address _resource, uint256 _index) public view returns (uint256) {
        return getLandMiningStrength(_landId, _resource).mul(getBarRate(_landId, _resource, _index)).div(RATE_PRECISION);
    }

    function itemId2Status(address _item, uint256 _itemId) public view returns (address, uint256, uint256) {
        LibItemStatusStorage.Status memory sts = LibItemStatusStorage.getStorage().itemId2Status[_item][_itemId];
        return (sts.staker, sts.tokenId, sts.index);
    }

    function itemMinedBalance(address _itemToken, uint256 _itemId, address _resource) public view returns (uint256) {
        return getItemMinedBalance(_itemToken, _itemId, _resource);
    }

    function land2BarRate(uint256 _landId, address _resource, uint256 _index) public view returns (uint256) {
        return getBarRate(_landId, _resource, _index);
    }

    function landId2Bars(uint256 _tokenId, uint256 _index) public view returns (address, address, uint256, address) {
        require(_index < maxAmount(), "Furnace: INDEX_FORBIDDEN.");
        LibBarsStorage.Bar memory bar = LibBarsStorage.getStorage().landId2Bars[_tokenId][_index];
        return (bar.staker, bar.token, bar.id, bar.resource);
    }

    function protectPeriod(address _token, uint256 _id) public view returns (uint256) {
        return LibProtectPeriodStorage.getStorage().protectPeriod[_token][_id];
    }

}
