pragma solidity ^0.6.7;

import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "zeppelin-solidity/utils/Address.sol";
import "./storage/LibRegisterStorage.sol";

contract LandRSCore is
    LibRegisterStorage
{

    fallback() external payable {
        bytes4 selector = msg.sig;
        if (selector == hex"5ca1bc12" // bytes4(keccak256("startMining(uint256,uint256,address)"))
         || selector == hex"3b714199" // bytes4(keccak256("stopMining(uint256)"))
         || selector == hex"4d474898" // bytes4(keccak256("mine(uint256)"))
         || selector == hex"f23bcebc" // bytes4(keccak256("claimLandResource(uint256)"))
         || selector == hex"0cfacb57" // bytes4(keccak256("claimItemResource(address,uint256)"))

           )
        address registry = LibRegisterStorage.getStorage().registry;
        address landMine = ISettingsRegistry(registry).addressOf(CONTRACT_LAND_MINE);
        return Address.functionDelegateCall(landMine, msg.data, "LandRSCore: StartMining call failed");
    }

    receive() external payable {}
			// "_getMinableBalance(uint256,address,uint256,uint256)": "8c17ac7e",
			// "activityStopped(uint256)": "6086e7f8",
			// "attenPerDay()": "89adbfcd",
			// "authority()": "bf7e214f",
			// "availableItemResources(address,uint256,address[])": "cd4b98cd",
			// "availableLandResources(uint256,address[])": "487f4cf3",
			// "batchClaimLandResource(uint256[])": "341b989c",
			// "batchStartMining(uint256[],uint256[],address[])": "c217cd08",
			// "devestAndClaim(address,uint256,uint256)": "00762b77",
			// "divest(uint256,uint256)": "4696c749",
			// "enhanceStrengthRateByIndex(address,uint256,uint256)": "993ac21a",
			// "enhanceStrengthRateOf(address,uint256)": "33372e46",
			// "equip(uint256,address,uint256,address,uint256)": "8be90ffb",
			// "getBarItem(uint256,uint256)": "09d367f1",
			// "getBarMiningStrength(uint256,address,uint256)": "78bf8a14",
			// "getBarRate(uint256,address,uint256)": "de5d944f",
			// "getBarsMiningStrength(uint256,address)": "023fee2f",
			// "getBarsRate(uint256,address)": "a927f8a0",
			// "getItemMinedBalance(address,uint256,address)": "d7f130e5",
			// "getLandIdByItem(address,uint256)": "5849c0c6",
			// "getLandMinedBalance(uint256,address)": "55efbeca",
			// "getLandMiningStrength(uint256,address)": "e155b997",
			// "getMinerOnLand(uint256,address,uint256)": "7fa64184",
			// "getReleaseSpeed(uint256,address,uint256)": "e822f478",
			// "getTotalMiningStrength(uint256,address)": "67361058",
			// "initializeContract(address,uint256)": "9a4f386c",
			// "isNotProtect(address,uint256)": "fb901549",
			// "itemId2Status(address,uint256)": "cdbcec98",
			// "itemMinedBalance(address,uint256,address)": "fde0cc8b",
			// "land2BarRate(uint256,address,uint256)": "db6816a8",
			// "land2ResourceMineState(uint256)": "a3d2e924",
			// "landId2Bars(uint256,uint256)": "72bd9c45",
			// "landWorkingOn(uint256)": "462c0ba8",
			// "maxAmount()": "5f48f393",
			// "maxMiners()": "db6fccda",
			// "mine(uint256)": "4d474898",
			// "miner2Index(uint256)": "60fca6c2",
			// "owner()": "8da5cb5b",
			// "protectPeriod(address,uint256)": "8be1aafb",
			// "recoverAttenPerDay()": "ea8b35ab",
			// "registry()": "7b103999",
			// "resourceReleaseStartTime()": "05f506d5",
			// "setAuthority(address)": "7a9e5e4b",
			// "setMaxAmount(uint256)": "4fe47f70",
			// "setMaxMiners(uint256)": "a9476eda",
			// "setOwner(address)": "13af4035",
			// "updateMinerStrengthWhenStart(uint256)": "8d57d41a",
			// "updateMinerStrengthWhenStop(uint256)": "06b2539f"
}
