pragma solidity ^0.6.7;

import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IMetaDataTeller.sol";
import "./interfaces/ILandRSMine.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/IERC721.sol";
import "./storage/LibItemStatusStorage.sol";
import "./storage/LibMaxAmountStorage.sol";
import "./storage/LibBarRateStorage.sol";
import "./storage/LibBarsStorage.sol";
import "./common/ItemBar.sol";
import "./common/Registry.sol";
import "./common/DSAuth.sol";

contract LandRSBar is DSAuth, Registry, ItemBar {
    event Equip(uint256 indexed tokenId, address resource, uint256 index, address staker, address token, uint256 id);
    event Divest(uint256 indexed tokenId, address resource, uint256 index, address staker, address token, uint256 id);
    event StartBarMining(uint256 barIndex, uint256 landId, address resource, uint256 rate);
    event StopBarMining(uint256 barIndex, uint256 landId, address rate);
    event SetMaxLandBar(uint256 maxAmount);

    bytes32 internal constant CONTRACT_INTERSTELLAR_ENCODER = "CONTRACT_INTERSTELLAR_ENCODER";
    bytes32 internal constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";
    bytes32 internal constant CONTRACT_METADATA_TELLER = "CONTRACT_METADATA_TELLER";
    bytes32 internal constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";
    bytes32 internal constant FURNACE_ITEM_MINE_FEE = "FURNACE_ITEM_MINE_FEE";
    bytes32 internal constant UINT_ITEMBAR_PROTECT_PERIOD = "UINT_ITEMBAR_PROTECT_PERIOD";

    function setMaxAmount(uint256 _maxAmount) public auth {
        require(_maxAmount > maxAmount(), "Furnace: INVALID_MAXAMOUNT");
        LibMaxAmountStorage.getStorage().maxAmount = _maxAmount;
        emit SetMaxLandBar(maxAmount());
    }

    /**
     * @dev Equip function, A NFT can equip to EVO Bar (LandBar or ApostleBar).
     * @param _tokenId  Token Id which to be quiped.
     * @param _resource Which resouce appply to.
     * @param _index    Index of the Bar.
     * @param _token    Token address which to quip.
     * @param _id       Token Id which to quip.
     */
    function equip(
        uint256 _tokenId,
        address _resource,
        uint256 _index,
        address _token,
        uint256 _id
    ) public {
        _equip(_tokenId, _resource, _index, _token, _id);
    }

    function _equip(
        uint256 _tokenId,
        address _resource,
        uint256 _index,
        address _token,
        uint256 _id
    ) internal {
        beforeEquip(_tokenId, _resource);
        IMetaDataTeller teller = IMetaDataTeller(registry().addressOf(CONTRACT_METADATA_TELLER));
        uint256 resourceId = ILandBase(registry().addressOf(CONTRACT_LAND_BASE)).resourceToken2RateAttrId(_resource);
        require(resourceId > 0 && resourceId < 6, "Furnace: INVALID_RESOURCE");
        require(IInterstellarEncoder(registry().addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectClass(_tokenId) == 1, "Furnace: ONLY_LAND");
        require(IERC721(registry().addressOf(CONTRACT_OBJECT_OWNERSHIP)).exists(_tokenId), "Furnace: NOT_EXIST");
        (uint16 objClassExt, uint16 class, uint16 grade) = teller.getMetaData(_token, _id);
        require(objClassExt > 0, "Furnace: PERMISSION");
        require(_index < maxAmount(), "Furnace: INDEX_FORBIDDEN");
        LibBarsStorage.Bar storage bar = LibBarsStorage.getStorage().landId2Bars[_tokenId][_index];
        if (bar.token != address(0)) {
            require(isNotProtect(bar.token, bar.id), "Furnace: PROTECT_PERIOD");
            (, uint16 originClass, uint16 originGrade) = teller.getMetaData(bar.token, bar.id);
            require(
                class > originClass ||
                (class == originClass && grade > originGrade) ||
                IERC721(registry().addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender,
                "Furnace: FORBIDDEN"
            );
            //TODO:: safe transfer
            IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
            delete LibItemStatusStorage.getStorage().itemId2Status[bar.staker][bar.id];
            // emit Divest(
            //     _tokenId,
            //     bar.resource,
            //     _index,
            //     bar.staker,
            //     bar.token,
            //     bar.id
            // );
        }
        IERC721(_token).transferFrom(msg.sender, address(this), _id);
        bar.staker = msg.sender;
        bar.token = _token;
        bar.id = _id;
        bar.resource = _resource;
        LibItemStatusStorage.getStorage().itemId2Status[bar.token][bar.id] = LibItemStatusStorage.Status({
            staker: bar.staker,
            tokenId: _tokenId,
            index: _index
        });
        if (isNotProtect(bar.token, bar.id)) {
            LibProtectPeriodStorage.getStorage().protectPeriod[bar.token][bar.id] = _calculateProtectPeriod(class).add(now);
        }
        afterEquiped(_index, _tokenId, _resource);
        emit Equip(_tokenId, _resource, _index, bar.staker, bar.token, bar.id);
    }

    function _calculateProtectPeriod(
        uint16 _class
    ) internal view returns (uint256) {
        uint256 baseProtectPeriod = registry().uintOf(UINT_ITEMBAR_PROTECT_PERIOD);
        return uint256(_class).mul(baseProtectPeriod);
    }

    function beforeEquip(uint256 _landTokenId, address _resource) internal {
        if (getLandMiningStrength(_landTokenId, _resource) > 0) {
            ILandRSMine(address(this)).mine(_landTokenId);
        }
    }

    function afterEquiped(uint256 _index, uint256 _landTokenId, address _resource) internal {
        _startBarMining(_index, _landTokenId, _resource);
    }

    function _startBarMining(uint256 _index, uint256 _landId, address _resource) internal {
        uint256 rate = _getBarRateByIndex(_landId, _resource, _index);
        LibBarRateStorage.getStorage().land2BarRate[_landId][_resource][_index] = rate;
        emit StartBarMining(_index, _landId, _resource, rate);
    }

    function _getBarRateByIndex(uint256 _landId, address _resource, uint256 _index) internal view returns (uint256) {
        return enhanceStrengthRateByIndex(_resource, _landId, _index);
    }

    function _stopBarMinig(uint256 _index, uint256 _landId, address _resource) internal {
        delete LibBarRateStorage.getStorage().land2BarRate[_landId][_resource][_index];
        emit StopBarMining(_index, _landId, _resource);
    }

    function afterDivested(
        uint256 _index,
        uint256 _landTokenId,
        address _resource
    ) internal {
        if (getLandMiningStrength(_landTokenId, _resource) > 0) {
            ILandRSMine(address(this)).mine(_landTokenId);
        }
        _stopBarMinig(_index, _landTokenId, _resource);
    }

    /**
     * @dev Divest function, A NFT can Divest from EVO Bar (LandBar or ApostleBar).
     * @param _tokenId Token Id which to be unquiped.
     * @param _index   Index of the Bar.
     */
    function divest(uint256 _tokenId, uint256 _index) public {
        _divest(_tokenId, _index);
    }

    function _divest(uint256 _tokenId, uint256 _index) internal {
        LibBarsStorage.Bar memory bar = LibBarsStorage.getStorage().landId2Bars[_tokenId][_index];
        require(bar.token != address(0), "Furnace: EMPTY");
        require(bar.staker == msg.sender, "Furnace: FORBIDDEN");
        IERC721(bar.token).transferFrom(address(this), bar.staker, bar.id);
        afterDivested(_index, _tokenId, bar.resource);
        //clean
        delete LibItemStatusStorage.getStorage().itemId2Status[bar.token][bar.id];
        delete LibBarsStorage.getStorage().landId2Bars[_tokenId][_index];
        emit Divest(
            _tokenId,
            bar.resource,
            _index,
            bar.staker,
            bar.token,
            bar.id
        );
    }

    function enhanceStrengthRateByIndex(address _resource, uint256 _tokenId, uint256 _index) public view returns (uint256) {
        LibBarsStorage.Bar memory bar = LibBarsStorage.getStorage().landId2Bars[_tokenId][_index];
        if (bar.token == address(0)) {
            return 0;
        }
        IMetaDataTeller teller = IMetaDataTeller(registry().addressOf(CONTRACT_METADATA_TELLER));
        uint256 resourceId = ILandBase(registry().addressOf(CONTRACT_LAND_BASE)).resourceToken2RateAttrId(_resource);
        return teller.getRate(bar.token, bar.id, resourceId);
    }

    function enhanceStrengthRateOf(address _resource, uint256 _tokenId) external view returns (uint256) {
        uint256 rate;
        for (uint256 i = 0; i < maxAmount(); i++) {
            rate = rate.add(enhanceStrengthRateByIndex(_resource, _tokenId, i));
        }
        return rate;
    }
}
