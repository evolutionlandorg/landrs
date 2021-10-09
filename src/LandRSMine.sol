pragma solidity ^0.6.7;

import "./interfaces/ILandBase.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IMintableERC20.sol";
import "./interfaces/IERC721.sol";
import "./storage/LibMineStateStorage.sol";
import "./storage/LibItemBalanceStorage.sol";
import "./common/Mine.sol";
import "./common/Registry.sol";

contract LandRSMine is Registry, Mine {
	event LandResourceClaimed(
		address owner,
		uint256 landId,
		uint256 goldBalance,
		uint256 woodBalance,
		uint256 waterBalance,
		uint256 fireBalance,
		uint256 soilBalance
	);
	event ItemResourceClaimed(
		address owner,
		address itemToken,
		uint256 itemTokenId,
		uint256 goldBalance,
		uint256 woodBalance,
		uint256 waterBalance,
		uint256 fireBalance,
		uint256 soilBalance
	);

	// For every seconds, the speed will decrease by current speed multiplying (DENOMINATOR_in_seconds - seconds) / DENOMINATOR_in_seconds
	// resource will decrease 1/10000 every day.
	uint256 internal constant DENOMINATOR = 10000;
	uint256 internal constant TOTAL_SECONDS = DENOMINATOR * (1 days);
	bytes32 internal constant CONTRACT_INTERSTELLAR_ENCODER = "CONTRACT_INTERSTELLAR_ENCODER";
	bytes32 internal constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";
	bytes32 internal constant CONTRACT_GOLD_ERC20_TOKEN = "CONTRACT_GOLD_ERC20_TOKEN";
	bytes32 internal constant CONTRACT_WOOD_ERC20_TOKEN = "CONTRACT_WOOD_ERC20_TOKEN";
	bytes32 internal constant CONTRACT_WATER_ERC20_TOKEN = "CONTRACT_WATER_ERC20_TOKEN";
	bytes32 internal constant CONTRACT_FIRE_ERC20_TOKEN = "CONTRACT_FIRE_ERC20_TOKEN";
	bytes32 internal constant CONTRACT_SOIL_ERC20_TOKEN = "CONTRACT_SOIL_ERC20_TOKEN";
	bytes32 internal constant FURNACE_ITEM_MINE_FEE = "FURNACE_ITEM_MINE_FEE";
	bytes32 internal constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	// get amount of speed uint at this moment
	function _getReleaseSpeedInSeconds(uint256 _tokenId, uint256 _time) internal view returns (uint256 currentSpeed) {
		require(_time >= resourceReleaseStartTime(), "Should after release time");
		require(_time >= getLandMineStateLastUpdateTime(_tokenId), "Should after release last update time");

		// after 10000 days from start
		// the resource release speed decreases to 0
		if (TOTAL_SECONDS < _time - resourceReleaseStartTime()) {
			return 0;
		}

		// max amount of speed unit of _tokenId for now
		// suppose that speed_uint = 1 in this function
		uint256 availableSpeedInSeconds = TOTAL_SECONDS.sub(_time - resourceReleaseStartTime());
		return availableSpeedInSeconds;
	}

	// For every seconds, the speed will decrease by current speed multiplying (DENOMINATOR_in_seconds - seconds) / DENOMINATOR_in_seconds.
	// resource will decrease 1/10000 every day.
	// `minableBalance` is an area of a trapezoid.
	// The reason for dividing by `1 days` twice is that the definition of `getResourceRate` is the number of mines that can be mined per day.
	function _getMinableBalance(uint256 _tokenId, address _resource, uint256 _currentTime, uint256 _lastUpdateTime) internal view returns (uint256 minableBalance) {
		uint256 speed_in_current_period =
			ILandBase(registry().addressOf(CONTRACT_LAND_BASE))
				.getResourceRate(_tokenId, _resource)
				.mul(
				_getReleaseSpeedInSeconds(
					_tokenId,
					((_currentTime + _lastUpdateTime) / 2)
				)
			)
				.mul(1 ether)
				.div(1 days)
				.div(TOTAL_SECONDS);

		// calculate the area of trapezoid
		minableBalance = speed_in_current_period.mul(_currentTime - _lastUpdateTime);
	}

	function _getMaxMineBalance(
		uint256 _tokenId,
		address _resource,
		uint256 _currentTime,
		uint256 _lastUpdateTime
	) internal view returns (uint256) {
		// totalMinerStrength is in wei
		return
			getTotalMiningStrength(_tokenId, _resource)
				.mul(_currentTime - _lastUpdateTime)
				.div(1 days);
	}

	function _mineAllResource(
		uint256 _landTokenId,
		address _gold,
		address _wood,
		address _water,
		address _fire,
		address _soil
	) internal {
		require(
			IInterstellarEncoder(registry().addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectClass(_landTokenId) == 1,
			"Token must be land."
		);

		_mineResource(_landTokenId, _gold);
		_mineResource(_landTokenId, _wood);
		_mineResource(_landTokenId, _water);
		_mineResource(_landTokenId, _fire);
		_mineResource(_landTokenId, _soil);

        LibMineStateStorage.Storage storage stor = LibMineStateStorage.getStorage(_landTokenId);
        stor.lastUpdateTime = uint128(block.timestamp);
	}

	function _distribution(
		uint256 _landId,
		address _resource,
		uint256 minedBalance,
		uint256 barsRate
	) internal returns (uint256) {
		uint256 landBalance =
			minedBalance.mul(RATE_PRECISION).div(barsRate.add(RATE_PRECISION));
		uint256 barsBalance = minedBalance.sub(landBalance);
		for (uint256 i = 0; i < maxAmount(); i++) {
			(address itemToken, uint256 itemId, address resouce) =
				getBarItem(_landId, i);
			if (itemToken != address(0) && resouce == _resource) {
				uint256 barBalance =
					barsBalance.mul(getBarRate(_landId, _resource, i)).div(barsRate);
				(barBalance, landBalance) = _payFee(barBalance, landBalance);
				LibItemBalanceStorage.getStorage().itemMinedBalance[itemToken][itemId][_resource] = getItemMinedBalance(itemToken, itemId, _resource).add( barBalance);
			}
		}
		return landBalance;
	}

	function _payFee(uint256 barBalance, uint256 landBalance)
		internal
		view
		returns (uint256, uint256)
	{
		uint256 fee = barBalance.mul(registry().uintOf(FURNACE_ITEM_MINE_FEE)).div(RATE_PRECISION);
		barBalance = barBalance.sub(fee);
		landBalance = landBalance.add(fee);
		return (barBalance, landBalance);
	}

	function _mineResource(uint256 _landId, address _resource) internal {
		// the longest seconds to zero speed.
		if (getLandMiningStrength(_landId, _resource) == 0) {
			return;
		}
		uint256 minedBalance = _calculateMinedBalance(_landId, _resource, now);
		if (minedBalance == 0) {
			return;
		}

		uint256 barsRate = getBarsRate(_landId, _resource);
		uint256 landBalance = minedBalance;
		if (barsRate > 0) {
			// V5 yeild distribution
			landBalance = _distribution(
				_landId,
				_resource,
				minedBalance,
				barsRate
			);
		}

        LibMineStateStorage.getStorage(_landId).mintedBalance[_resource] = getLandMinedBalance(_landId, _resource).add(landBalance);
	}

	function _calculateMinedBalance(
		uint256 _landTokenId,
		address _resourceToken,
		uint256 _currentTime
	) internal view returns (uint256) {
		uint256 currentTime = _currentTime;

		uint256 minedBalance;
		uint256 minableBalance;
		if (currentTime > (resourceReleaseStartTime() + TOTAL_SECONDS)) {
			currentTime = (resourceReleaseStartTime() + TOTAL_SECONDS);
		}

		uint256 lastUpdateTime = getLandMineStateLastUpdateTime(_landTokenId);
		require(currentTime >= lastUpdateTime, "Land: INVALID_TIMESTAMP");

		if (lastUpdateTime >= (resourceReleaseStartTime() + TOTAL_SECONDS)) {
			minedBalance = 0;
			minableBalance = 0;
		} else {
			minedBalance = _getMaxMineBalance(
				_landTokenId,
				_resourceToken,
				currentTime,
				lastUpdateTime
			);
			minableBalance = _getMinableBalance(
				_landTokenId,
				_resourceToken,
				currentTime,
				lastUpdateTime
			);
		}

		if (minedBalance > minableBalance) {
			minedBalance = minableBalance;
		}

		return minedBalance;
	}

	function getReleaseSpeed(uint256 _tokenId, address _resource, uint256 _time) public view returns (uint256 currentSpeed) {
		return
			ILandBase(registry().addressOf(CONTRACT_LAND_BASE))
				.getResourceRate(_tokenId, _resource)
				.mul(_getReleaseSpeedInSeconds(_tokenId, _time))
				.mul(1 ether)
				.div(TOTAL_SECONDS);
	}

	function mine(uint256 _landTokenId) public {
		_mineAllResource(
			_landTokenId,
			registry().addressOf(CONTRACT_GOLD_ERC20_TOKEN),
			registry().addressOf(CONTRACT_WOOD_ERC20_TOKEN),
			registry().addressOf(CONTRACT_WATER_ERC20_TOKEN),
			registry().addressOf(CONTRACT_FIRE_ERC20_TOKEN),
			registry().addressOf(CONTRACT_SOIL_ERC20_TOKEN)
		);
	}

	function claimLandResource(uint256 _landId) public {
		require(
			msg.sender == IERC721(registry().addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_landId),
			"Land: ONLY_LANDER"
		);

		address gold = registry().addressOf(CONTRACT_GOLD_ERC20_TOKEN);
		address wood = registry().addressOf(CONTRACT_WOOD_ERC20_TOKEN);
		address water = registry().addressOf(CONTRACT_WATER_ERC20_TOKEN);
		address fire = registry().addressOf(CONTRACT_FIRE_ERC20_TOKEN);
		address soil = registry().addressOf(CONTRACT_SOIL_ERC20_TOKEN);
		_mineAllResource(_landId, gold, wood, water, fire, soil);

		uint256 goldBalance = _claimLandResource(_landId, gold);
		uint256 woodBalance = _claimLandResource(_landId, wood);
		uint256 waterBalance = _claimLandResource(_landId, water);
		uint256 fireBalance = _claimLandResource(_landId, fire);
		uint256 soilBalance = _claimLandResource(_landId, soil);

		emit LandResourceClaimed(
			msg.sender,
			_landId,
			goldBalance,
			woodBalance,
			waterBalance,
			fireBalance,
			soilBalance
		);
	}

	function _claimLandResource(uint256 _landId, address _resource) internal returns (uint256) {
		uint256 balance = getLandMinedBalance(_landId, _resource);
		if (balance > 0) {
			IMintableERC20(_resource).mint(msg.sender, balance);
            LibMineStateStorage.Storage storage stor = LibMineStateStorage.getStorage(_landId);
			stor.mintedBalance[_resource] = 0;
			return balance;
		} else {
			return 0;
		}
	}

	function availableLandResources(
		uint256 _landId,
		address[] memory _resources
	) public view returns (uint256[] memory) {
		uint256[] memory availables = new uint256[](_resources.length);
		for (uint256 i = 0; i < _resources.length; i++) {
			uint256 mined = _calculateMinedBalance(_landId, _resources[i], now);
			(uint256 available, ) =
				_calculateResources(
					address(0),
					0,
					_landId,
					_resources[i],
					mined
				);
			availables[i] = available.add(getLandMinedBalance(_landId, _resources[i]));
		}
		return availables;
	}

	function _calculateResources(
		address _itemToken,
		uint256 _itemId,
		uint256 _landId,
		address _resource,
		uint256 _minedBalance
	) internal view returns (uint256 landBalance, uint256 barResource) {
		uint256 barsRate = getBarsRate(_landId, _resource);
		// V5 yeild distribution
		landBalance = _minedBalance.mul(RATE_PRECISION).div(barsRate.add(RATE_PRECISION));
		if (barsRate > 0) {
			uint256 barsBalance = _minedBalance.sub(landBalance);
			for (uint256 i = 0; i < maxAmount(); i++) {
				uint256 barBalance = barsBalance.mul(getBarRate(_landId, _resource, i)).div(barsRate);
				(barBalance, landBalance) = _payFee(barBalance, landBalance);
				(address itemToken, uint256 itemId, ) = getBarItem(_landId, i);
				if (_itemId == itemId && _itemToken == itemToken) {
					barResource = barResource.add(barBalance);
				}
			}
		}
	}

	function claimItemResource(address _itemToken, uint256 _itemId) public {
		(address staker, uint256 landId) = getLandIdByItem(_itemToken, _itemId);
		if (staker == address(0) && landId == 0) {
			require(
				IERC721(_itemToken).ownerOf(_itemId) == msg.sender,
				"Land: ONLY_ITEM_OWNER"
			);
		} else {
			require(staker == msg.sender, "Land: ONLY_ITEM_STAKER");
			mine(landId);
		}

		address gold = registry().addressOf(CONTRACT_GOLD_ERC20_TOKEN);
		address wood = registry().addressOf(CONTRACT_WOOD_ERC20_TOKEN);
		address water = registry().addressOf(CONTRACT_WATER_ERC20_TOKEN);
		address fire = registry().addressOf(CONTRACT_FIRE_ERC20_TOKEN);
		address soil = registry().addressOf(CONTRACT_SOIL_ERC20_TOKEN);
		uint256 goldBalance = _claimItemResource(_itemToken, _itemId, gold);
		uint256 woodBalance = _claimItemResource(_itemToken, _itemId, wood);
		uint256 waterBalance = _claimItemResource(_itemToken, _itemId, water);
		uint256 fireBalance = _claimItemResource(_itemToken, _itemId, fire);
		uint256 soilBalance = _claimItemResource(_itemToken, _itemId, soil);

		emit ItemResourceClaimed(
			msg.sender,
			_itemToken,
			_itemId,
			goldBalance,
			woodBalance,
			waterBalance,
			fireBalance,
			soilBalance
		);
	}

	function _claimItemResource(address _itemToken, uint256 _itemId, address _resource) internal returns (uint256) {
		uint256 balance = getItemMinedBalance(_itemToken, _itemId, _resource);
		if (balance > 0) {
			IMintableERC20(_resource).mint(msg.sender, balance);
			LibItemBalanceStorage.getStorage().itemMinedBalance[_itemToken][_itemId][_resource] = 0;
			return balance;
		} else {
			return 0;
		}
	}

	function availableItemResources(address _itemToken, uint256 _itemId, address[] memory _resources) public view returns (uint256[] memory) {
		uint256[] memory availables = new uint256[](_resources.length);
		for (uint256 i = 0; i < _resources.length; i++) {
			(address staker, uint256 landId) = getLandIdByItem(_itemToken, _itemId);
			uint256 available = 0;
			if (staker != address(0) && landId != 0) {
				uint256 mined = _calculateMinedBalance(landId, _resources[i], now);
				(, uint256 availableItem) =
					_calculateResources(
						_itemToken,
						_itemId,
						landId,
						_resources[i],
						mined
					);
				available = available.add(availableItem);
			}
			available = available.add(getItemMinedBalance(_itemToken, _itemId, _resources[i]));
			availables[i] = available;
		}
		return availables;
	}
}
