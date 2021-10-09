pragma solidity ^0.6.7;

import './Owner.sol';
import './Authority.sol';

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is Owner, Authority, DSAuthEvents {

    function setOwner(address owner_)
        public
        auth
    {
        LibSlot2Storage.getStorage().owner = owner_;
        emit LogSetOwner(owner());
    }

    function setAuthority(address authority_)
        public
        auth
    {
        LibAuthStorage.getStorage().authority = authority_;
        emit LogSetAuthority(address(authority()));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == owner()) {
            return true;
        } else if (authority() == IAuthority(0)) {
            return false;
        } else {
            return authority().canCall(src, address(this), sig);
        }
    }
}
