pragma solidity ^0.6.7;

import "zeppelin-solidity/math/SafeMath.sol";
import "../storage/LibBarRateStorage.sol";
import "../storage/LibMaxAmountStorage.sol";
import "../storage/LibItemBalanceStorage.sol";
import "../storage/LibBarsStorage.sol";
import "./Apostle.sol";

contract ItemBar is Apostle {
	using SafeMath for *;

	// rate precision
	uint128 internal constant RATE_PRECISION = 10**8;

	//0x4655524e4143455f4954454d5f4d494e455f4645450000000000000000000000
	bytes32 internal constant FURNACE_ITEM_MINE_FEE = "FURNACE_ITEM_MINE_FEE";

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
        LibBarsStorage.Storage storage stor = LibBarsStorage.getStorage();
		return (
			stor.landId2Bars[_tokenId][_index].token,
			stor.landId2Bars[_tokenId][_index].id,
			stor.landId2Bars[_tokenId][_index].resource
		);
	}

	function getItemMinedBalance(address _itemToken, uint256 _itemId, address _resource) public view returns (uint256) {
		return LibItemBalanceStorage.getStorage().itemMinedBalance[_itemToken][_itemId][_resource];
	}
}
