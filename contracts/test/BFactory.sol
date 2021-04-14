// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

// Builds new KPools, logging their addresses and providing `isKPool(address) -> (bool)`

import "./BPool.sol";

contract BFactory {
    event LOG_NEW_POOL(
        address indexed caller,
        address indexed pool
    );

    event LOG_BLABS(
        address indexed caller,
        address indexed blabs
    );

    mapping(address=>bool) private _isKPool;

    function isKPool(address b)
        external view returns (bool)
    {
        return _isKPool[b];
    }

    function newBPool()
        external
        returns (BPool)
    {
        BPool kpool = new BPool();
        _isKPool[address(kpool)] = true;
        emit LOG_NEW_POOL(msg.sender, address(kpool));
        kpool.setController(msg.sender);
        return kpool;
    }

    address private _blabs;

    constructor() public {
        _blabs = msg.sender;
    }

    function getBLabs()
        external view
        returns (address)
    {
        return _blabs;
    }

    function setBLabs(address b)
        external
    {
        require(msg.sender == _blabs, "ERR_NOT_BLABS");
        emit LOG_BLABS(msg.sender, b);
        _blabs = b;
    }

    function collect(BPool pool)
        external 
    {
        require(msg.sender == _blabs, "ERR_NOT_BLABS");
        uint collected = IERC20(pool).balanceOf(address(this));
        bool xfer = pool.transfer(_blabs, collected);
        require(xfer, "ERR_ERC20_FAILED");
    }
}
