pragma solidity ^0.6.7;

import "./storage/LibMineStateStorage.sol";
import "./storage/LibItemBalanceStorage.sol";
import "./common/Mine.sol";

contract LandRSMine is Mine {

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
		uint256 availableSpeedInSeconds =
			TOTAL_SECONDS.sub(_time - resourceReleaseStartTime());
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
			IInterstellarEncoder(
				registry().addressOf(CONTRACT_INTERSTELLAR_ENCODER)
			)
				.getObjectClass(_landTokenId) == 1,
			"Token must be land."
		);

		_mineResource(_landTokenId, _gold);
		_mineResource(_landTokenId, _wood);
		_mineResource(_landTokenId, _water);
		_mineResource(_landTokenId, _fire);
		_mineResource(_landTokenId, _soil);

        LibMineStateStorage.Storage storage stor = LibOwnableStorage.getStorage();
        stor.land2ResourceMineState[_landTokenId].lastUpdateTime = uint128(now);
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
		for (uint256 i = 0; i < maxAmount; i++) {
			(address itemToken, uint256 itemId, address resouce) =
				getBarItem(_landId, i);
			if (itemToken != address(0) && resouce == _resource) {
				uint256 barBalance =
					barsBalance.mul(getBarRate(_landId, _resource, i)).div(
						barsRate
					);
				(barBalance, landBalance) = _payFee(barBalance, landBalance);
				LibItemBalanceStorage.getStorage().itemMinedBalance[itemToken][itemId][
					_resource
				] = getItemMinedBalance(itemToken, itemId, _resource).add(
					barBalance
				);
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

        LibMineStateStorage.getStorage().land2ResourceMineState[_landId].mintedBalance[_resource] = getLandMinedBalance(_landId, _resource).add(landBalance);
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

	// both for own _tokenId or hired one
	function startMining(
		uint256 _tokenId,
		uint256 _landTokenId,
		address _resource
	) public {
		// require the permission from land owner;
		require(
			msg.sender ==
				ERC721(registry().addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(
					_landTokenId
				),
			"Must be the owner of the land"
		);

		// make sure that _tokenId won't be used repeatedly
		require(landWorkingOn(_tokenId) == 0);

		ITokenUse(registry().addressOf(CONTRACT_TOKEN_USE)).addActivity(
			_tokenId,
			msg.sender,
			0
		);

		// update status!
		mine(_landTokenId);

		uint256 _index =
			land2ResourceMineState[_landTokenId].miners[_resource].length;

		land2ResourceMineState[_landTokenId].totalMiners += 1;

		require(
			land2ResourceMineState[_landTokenId].totalMiners <= maxMiners,
			"Land: EXCEED_MAXAMOUNT"
		);

		address miner =
			IInterstellarEncoder(
				registry().addressOf(CONTRACT_INTERSTELLAR_ENCODER)
			)
				.getObjectAddress(_tokenId);
		uint256 strength =
			IMinerObject(miner).strengthOf(_tokenId, _resource, _landTokenId);

		land2ResourceMineState[_landTokenId].miners[_resource].push(_tokenId);
		land2ResourceMineState[_landTokenId].totalMinerStrength[_resource] = land2ResourceMineState[_landTokenId].totalMinerStrength[_resource].add(strength);

		miner2Index[_tokenId] = MinerStatus({
			landTokenId: _landTokenId,
			resource: _resource,
			indexInResource: uint64(_index)
		});

		emit StartMining(_tokenId, _landTokenId, _resource, strength);
	}
}