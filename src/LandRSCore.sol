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

    function startMining(uint256 tokenId, uint256 landTokenId, address resource) public {
        address landRSApostle = registry().addressOf(CONTRACT_LANDRS_APOSTLE);
        Address.functionDelegateCall(landRSApostle, abi.encodeWithSelector(this.startMining.selector, tokenId, landTokenId, resource), "LandRSCore: StartMining call failed");
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

    function divest(uint256 tokenId, uint256 index) public {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        Address.functionDelegateCall(landRSBar, abi.encodeWithSelector(this.divest.selector, tokenId, index), "LandRSCore: Divest call failed");
    }

    function equip(uint256,address,uint256,address,uint256) external {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: Equip call failed");
    }

    function mine(uint256) external {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: Mine call failed");
    }

    function claimLandResource(uint256 landId) public {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        Address.functionDelegateCall(landRSMine, abi.encodeWithSelector(this.claimLandResource.selector, landId), "LandRSCore: ClaimLandResource call failed");
    }

    function claimItemResource(address token, uint256 tokenId) public {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        Address.functionDelegateCall(landRSMine, abi.encodeWithSelector(this.claimItemResource.selector, token, tokenId), "LandRSCore: ClaimItemResource call failed");
    }

    function batchClaimLandResource(uint256[] calldata landTokenIds) external {
        uint256 length = landTokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            claimLandResource(landTokenIds[i]);
        }
    }

    function batchClaimItemResource(address[] calldata itemTokens, uint256[] calldata itemIds) external {
        require(itemTokens.length == itemIds.length, "Land: INVALID_LENGTH");
        uint256 length = itemTokens.length;
        for (uint256 i = 0; i < length; i++) {
            claimItemResource(itemTokens[i], itemIds[i]);
        }
    }

    function batchStartMining(uint256[] calldata tokenIds, uint256[] calldata landTokenIds, address[] calldata resources) external {
        require(tokenIds.length == landTokenIds.length && landTokenIds.length == resources.length, "input error");
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            startMining(tokenIds[i], landTokenIds[i], resources[i]);
        }
    }

    function devestAndClaim(address itemToken, uint256 tokenId, uint256 index) external {
        divest(tokenId, index);
        claimItemResource(itemToken, tokenId);
    }

    /////////////////////////////////////////////////////////////////////////////////////////

    function getReleaseSpeed(uint256,address,uint256) external {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        bytes memory resultData = Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: getReleaseSpeed call failed");
        _returnWithData(resultData);
    }

    function availableItemResources(address,uint256,address[] calldata) external {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        bytes memory resultData = Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: AvailableItemResources call failed");
        _returnWithData(resultData);
    }

    function availableLandResources(uint256,address[] calldata) external {
        address landRSMine = registry().addressOf(CONTRACT_LANDRS_MINE);
        bytes memory resultData = Address.functionDelegateCall(landRSMine, msg.data, "LandRSCore: AvailableLandResources call failed");
        _returnWithData(resultData);
    }

    function enhanceStrengthRateByIndex(address,uint256,uint256) external {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        bytes memory resultData = Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: EnhanceStrengthRateByIndex call failed");

        _returnWithData(resultData);
    }

    function enhanceStrengthRateOf(address,uint256) external {
        address landRSBar = registry().addressOf(CONTRACT_LANDRS_BAR);
        bytes memory resultData = Address.functionDelegateCall(landRSBar, msg.data, "LandRSCore: EnhanceStrengthRateOf call failed");
        _returnWithData(resultData);
    }

    function _returnWithData(bytes memory data) private pure {
        assembly { return(add(data, 32), mload(data)) }
    }
}
