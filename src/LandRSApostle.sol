pragma solidity ^0.6.7;

import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IMinerObject.sol";
import "./interfaces/ILandRSMine.sol";
import "./interfaces/ITokenUse.sol";
import "./interfaces/IERC721.sol";
import "./storage/LibMaxMinersStorage.sol";
import "./storage/LibMineStateStorage.sol";
import "./storage/LibMinerStorage.sol";
import "./common/Registry.sol";
import "./common/DSAuth.sol";
import "./common/Apostle.sol";

contract LandRSApostle is DSAuth, Registry, Apostle {
	event StartMining(uint256 minerTokenId, uint256 landId, address _resource, uint256 strength);
	event StopMining(uint256 minerTokenId, uint256 landId, address _resource, uint256 strength);
    event SetMaxMiner(uint256 maxMiners);

	function setMaxMiners(uint256 _maxMiners) public auth {
		require(_maxMiners > maxMiners(), "Land: INVALID_MAXMINERS");
		LibMaxMinersStorage.getStorage().maxMiners = _maxMiners;
        emit SetMaxMiner(maxMiners());
	}

	// both for own _tokenId or hired one
	function startMining(
		uint256 _tokenId,
		uint256 _landTokenId,
		address _resource
	) public {
		// require the permission from land owner;
		require(
			msg.sender == IERC721(registry().addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_landTokenId),
			"Must be the owner of the land"
		);

		// make sure that _tokenId won't be used repeatedly
		require(landWorkingOn(_tokenId) == 0);
		ITokenUse(registry().addressOf(CONTRACT_TOKEN_USE)).addActivity(_tokenId, msg.sender, 0);
		// update status!
		ILandRSMine(address(this)).mine(_landTokenId);
        LibMineStateStorage.Storage storage stor = LibMineStateStorage.getStorage(_landTokenId);
		uint256 _index = stor.miners[_resource].length;
		stor.totalMiners += 1;

		require(stor.totalMiners <= maxMiners(), "Land: EXCEED_MAXAMOUNT");

		address miner = IInterstellarEncoder(registry().addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectAddress(_tokenId);
		uint256 strength = IMinerObject(miner).strengthOf(_tokenId, _resource, _landTokenId);

		stor.miners[_resource].push(_tokenId);
		stor.totalMinerStrength[_resource] = stor.totalMinerStrength[_resource].add(strength);

		LibMinerStorage.getStorage().miner2Index[_tokenId] = LibMinerStorage.MinerStatus({
			landTokenId: _landTokenId,
			resource: _resource,
			indexInResource: uint64(_index)
		});

		emit StartMining(_tokenId, _landTokenId, _resource, strength);
	}

	// Only trigger from Token Activity.
	function activityStopped(uint256 _tokenId) public auth {
		_stopMining(_tokenId);
	}

	function stopMining(uint256 _tokenId) public {
            address ownership = registry().addressOf(CONTRACT_OBJECT_OWNERSHIP);
            address tokenuse = registry().addressOf(CONTRACT_TOKEN_USE);
            address user = ITokenUse(tokenuse).getTokenUser(_tokenId);
            if (IERC721(ownership).ownerOf(_tokenId) == msg.sender || user == msg.sender) {
                ITokenUse(tokenuse).removeActivity(_tokenId, msg.sender);
            } else {
                // Land owner has right to stop mining
                uint256 landTokenId = landWorkingOn(_tokenId);
                require(msg.sender == IERC721(ownership).ownerOf(landTokenId), "Land: ONLY_LANDER");
                ITokenUse(tokenuse).removeActivity(_tokenId, user);
            }
	}

	function _stopMining(uint256 _tokenId) internal {
		// remove the miner from land2ResourceMineState;
		uint64 minerIndex = getMinerIndexInResource(_tokenId);
		address resource = getMinerResource(_tokenId);
		uint256 landTokenId = landWorkingOn(_tokenId);

		// update status!
		ILandRSMine(address(this)).mine(landTokenId);

        LibMineStateStorage.Storage storage stor = LibMineStateStorage.getStorage(landTokenId);

		uint64 lastMinerIndex = uint64(stor.miners[resource].length.sub(1));
		uint256 lastMiner = stor.miners[resource][lastMinerIndex];

		stor.miners[resource][minerIndex] = lastMiner;
        stor.miners[resource].pop();
		LibMinerStorage.getStorage().miner2Index[lastMiner].indexInResource = minerIndex;
		stor.totalMiners -= 1;

		address miner = IInterstellarEncoder(registry().addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectAddress(_tokenId);
		uint256 strength = IMinerObject(miner).strengthOf(_tokenId, resource, landTokenId);

		// for backward compatibility
		// if strength can fluctuate some time in the future
        uint256 totalMinerStrength = getLandMiningStrength(landTokenId, resource);
		if (totalMinerStrength != 0) {
			if (totalMinerStrength > strength) {
				stor.totalMinerStrength[resource] = totalMinerStrength.sub(strength);
			} else {
				stor.totalMinerStrength[resource] = 0;
			}
		}

		if (stor.totalMiners == 0) {
			stor.totalMinerStrength[resource] = 0;
		}

		delete LibMinerStorage.getStorage().miner2Index[_tokenId];

		emit StopMining(_tokenId, landTokenId, resource, strength);
	}

}
