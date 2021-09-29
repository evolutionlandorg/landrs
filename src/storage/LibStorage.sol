pragma solidity ^0.6.7;

library LibStorage {

    enum StorageId {
        SUPPORTEDINTERFACES,
        AUTHORITY,
        OWNER,
        SINGLETONLOCK,
        REGISTRY,
        RESOURCERELEASESTARTTIME,
        ATTENPERDAY,
        RECOVERATTENPERDAY,
        LAND2RESOURCEMINESTATE,
        MINER2INDEX,
        MAXMINERS,
        ITEMMINEDBALANCE,
        LAND2BARRATE,
        MAXAMOUNT,
        LANDID2BARS,
        ITEMID2STATUS,
        PROTECTPERIOD
    }

    function getStorageSlot(StorageId storageId)
        internal
        pure
        returns (uint256 slot)
    {
        return uint256(storageId);
    }
}
