pragma solidity 0.5.12;

import "truffle/Assert.sol";
import "./support/UserProxy.sol";
import "../../contracts/RestrictedToken.sol";
import "../../contracts/TransferRules.sol";

contract GettersAndSettersTest {
    using Assert for uint256;
    using Assert for bool;

    RestrictedToken public token;
    address public owner;

    function beforeEach() public {
        owner = address(this);
        TransferRules rules = new TransferRules();
        token = new RestrictedToken(
            address(rules),
            owner,
            owner,
            "xyz",
            "Ex Why Zee",
            0,
            100,
            1e6
        );
        token.grantTransferAdmin(owner);
    }

    function testGettersAndSetters() public {
        uint256 number = token.balanceOf(owner);
        number.equal(100, "bad getter value");

        number = token.getMaxBalance(owner);
        number.equal(0, "bad getter value");

        number = token.getLockUntil(owner);
        number.equal(0, "bad getter value");

        number = token.getTransferGroup(owner);
        number.equal(0, "bad getter value");

        Assert.equal(token.getFrozenStatus(owner), false, "default is not frozen");
    }

    function testGetAllowTransferTime() public {
        address alice = address(0x1);
        address bob = address(0x2);
        token.getAllowTransferTime(alice, bob).equal(
            0,
            "default to time 0 for all addresses"
        );

        // allow alice and bob's default group (0) to trade after timestamp 100
        token.setAllowGroupTransfer(0, 0, 100);
        token.getAllowTransferTime(alice, bob).equal(
            100,
            "transfer group timestamp not properly set"
        );
    }
}
