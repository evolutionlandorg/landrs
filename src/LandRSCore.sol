pragma solidity ^0.6.7;

import "zeppelin-solidity/utils/Address.sol";
import "./common/Registry.sol";
import "./common/DSAuth.sol";
import "./common/Mine.sol";

contract LandRSCore is DSAuth, Registry, Mine {

    bytes32 internal constant CONTRACT_LANDRS_APOSTLE = "CONTRACT_LANDRS_APOSTLE";
    bytes32 internal constant CONTRACT_LANDRS_MINE = "CONTRACT_LANDRS_MINE";
    bytes32 internal constant CONTRACT_LANDRS_BAR = "CONTRACT_LANDRS_BAR";


    function setMaxMiners(uint256) external {
        address landRSApostle = registry().addressOf(CONTRACT_LANDRS_APOSTLE);
        Address.functionDelegateCall(landRSApostle, msg.data, "LandRSCore: SetMaxMiner call failed");
    }

    function startMining(uint256,uint256,address) public {
        address landRSApostle = registry().addressOf(CONTRACT_LANDRS_APOSTLE);
        Address.functionDelegateCall(landRSApostle, msg.data, "LandRSCore: StartMining call failed");
    }

    function activityStopped(uint256) external {
        address landRSApostle = registry().addressOf(CONTRACT_LANDRS_APOSTLE);
        Address.functionDelegateCall(landRSApostle, msg.data, "LandRSCore: ActivityStopped call failed");
    }

    function stopMining(uint256) external {
        address landRSApostle = registry().addressOf(CONTRACT_LANDRS_APOSTLE);
        Address.functionDelegateCall(landRSApostle, msg.data, "LandRSCore: StopMining call failed");
    }

    function setMaxAmount(uint256) external {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: SetMaxAmount call failed");
    }

    function divest(uint256,uint256) public {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: Divest call failed");
    }

    function equip(uint256,address,uint256,address,uint256) external {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: Equip call failed");
    }

    function mine(uint256) external {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: Mine call failed");
    }

    function claimLandResource(uint256) public {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: ClaimLandResource call failed");
    }

    function claimItemResource(address,uint256) public {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        Address.functionDelegateCall(landRSMine, msg.data, "ClaimItemResource: StartMining call failed");
    }

    function batchClaimLandResource(uint256[] calldata _landTokenIds) external {
        uint256 length = _landTokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            claimLandResource(_landTokenIds[i]);
        }
    }

    function batchClaimItemResource(address[] calldata _itemTokens, uint256[] calldata _itemIds) external {
        require(_itemTokens.length == _itemIds.length, "Land: INVALID_LENGTH");
        uint256 length = _itemTokens.length;
        for (uint256 i = 0; i < length; i++) {
            claimItemResource(_itemTokens[i], _itemIds[i]);
        }
    }

    function batchStartMining(uint256[] calldata _tokenIds, uint256[] calldata _landTokenIds, address[] calldata _resources) external {
        require(_tokenIds.length == _landTokenIds.length && _landTokenIds.length == _resources.length, "input error");
        uint256 length = _tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            startMining(_tokenIds[i], _landTokenIds[i], _resources[i]);
        }
    }

    function devestAndClaim(address _itemToken, uint256 _tokenId, uint256 _index) external {
        divest(_tokenId, _index);
        claimItemResource(_itemToken, _tokenId);
    }

    /////////////////////////////////////////////////////////////////////////////////////////

    function getReleaseSpeed(uint256,address,uint256) external returns (bytes memory) {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        return Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: getReleaseSpeed call failed");
    }

    function availableItemResources(address,uint256,address[] calldata) external returns (bytes memory) {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        return Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: AvailableItemResources call failed");
    }

    function availableLandResources(uint256,address[] calldata) external returns (bytes memory) {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        return Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: AvailableLandResources call failed");
    }

    function enhanceStrengthRateByIndex(address,uint256,uint256) external returns (bytes memory) {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        return Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: EnhanceStrengthRateByIndex call failed");
    }

    function enhanceStrengthRateOf(address,uint256) external returns (bytes memory) {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        return Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: EnhanceStrengthRateOf call failed");
    }
}
