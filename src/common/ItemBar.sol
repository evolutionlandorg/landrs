pragma solidity ^0.6.7;

import "zeppelin-solidity/math/SafeMath.sol";
import "../storage/LibBarRateStorage.sol";
import "../storage/LibMaxAmountStorage.sol";
import "../storage/LibItemBalanceStorage.sol";
import "../storage/LibBarsStorage.sol";
import "../storage/LibProtectPeriodStorage.sol";
import "../storage/LibItemStatusStorage.sol";
import "./Apostle.sol";

contract ItemBar is Apostle {
	using SafeMath for *;

	// rate precision
	uint128 internal constant RATE_PRECISION = 10**8;
	//0x4655524e4143455f4954454d5f4d494e455f4645450000000000000000000000
	bytes32 internal constant FURNACE_ITEM_MINE_FEE = "FURNACE_ITEM_MINE_FEE";
	// 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
	bytes32 internal constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";
	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER = "CONTRACT_METADATA_TELLER";
	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 internal constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";
	// 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_GOLD_ERC20_TOKEN = "CONTRACT_GOLD_ERC20_TOKEN";
	// 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_WOOD_ERC20_TOKEN = "CONTRACT_WOOD_ERC20_TOKEN";
	// 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
	bytes32 internal constant CONTRACT_WATER_ERC20_TOKEN = "CONTRACT_WATER_ERC20_TOKEN";
	// 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_FIRE_ERC20_TOKEN = "CONTRACT_FIRE_ERC20_TOKEN";
	// 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
	bytes32 internal constant CONTRACT_SOIL_ERC20_TOKEN = "CONTRACT_SOIL_ERC20_TOKEN";

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

	function isNotProtect(address _token, uint256 _id)
		public
		view
		returns (bool)
	{
		return LibProtectPeriodStorage.getStorage().protectPeriod[_token][_id] < now;
	}

	function getLandIdByItem(address _item, uint256 _itemId) public view returns (address, uint256) {
        LibItemStatusStorage.Status memory sts = LibItemStatusStorage.getStorage().itemId2Status[_item][_itemId];
		return (sts.staker, sts.tokenId);
	}
}
