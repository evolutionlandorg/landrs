pragma solidity ^0.6.7;

import "../storage/LibAuthStorage.sol";
import '../interfaces/IAuthority.sol';

contract Authority {
    function authority() public view returns (IAuthority) {
        return IAuthority(LibAuthStorage.getStorage().authority);
    }
}
