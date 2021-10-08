pragma solidity ^0.6.7;

interface IAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) external view returns (bool);
}
