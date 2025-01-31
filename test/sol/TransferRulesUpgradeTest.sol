pragma solidity 0.5.12;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../../contracts/RestrictedToken.sol";
import "../../contracts/TransferRules.sol";
import "../../contracts/ITransferRules.sol";

import "./support/UserProxy.sol";

contract TransferRulesUpgrade is ITransferRules {
    function detectTransferRestriction(
        address _token,
        address from,
        address to,
        uint256 value
    ) public view returns (uint8) {
        RestrictedToken token = RestrictedToken(_token);
        if (from == to && value > 0) return token.decimals(); // prove we are using all the arguments
        return 17; // grab an arbitrary value from the injected token contract
    }

    function messageForTransferRestriction(uint8 restrictionCode)
        public
        view
        returns (string memory)
    {
        if(restrictionCode >= 0) return "HELLO UPGRADE";
        return "HELLO 0 UPGRADE";
    }

    function checkSuccess(uint8 restrictionCode) public view returns (bool) {
        return restrictionCode == 0;
    }
}

contract TransferRulesUpgradeTest {
    RestrictedToken token;
    address owner;
    address receiver;

    function beforeEach() public {
        owner = address(this);
        receiver = address(0x1);
        uint8 decimalsWeWillPassToTransferRules = 6;
        TransferRules rules = new TransferRules();
        token = new RestrictedToken(
            address(rules),
            owner,
            owner,
            "xyz",
            "Ex Why Zee",
            decimalsWeWillPassToTransferRules,
            100,
            1e6
        );

        token.grantTransferAdmin(owner);
        token.setMaxBalance(receiver, 100);
        token.setAllowGroupTransfer(0, 0, 1); // don't restrict default group transfers
    }

    function testReplaceTransferRules() public {
        uint8 code = token.detectTransferRestriction(owner, receiver, 1);
        Assert.equal(
            uint256(code),
            0,
            "initial TransferRules should return code 0"
        );

        // upgrade the TransferRules
        TransferRulesUpgrade nextRules = new TransferRulesUpgrade();
        token.upgradeTransferRules(nextRules);

        code = token.detectTransferRestriction(owner, owner, 1);
        Assert.equal(
            uint256(code),
            6,
            "custom code should be returned after setting new TransferRules"
        );

        Assert.equal(
            token.messageForTransferRestriction(6),
            "HELLO UPGRADE",
            "should return the new transfer restriction messages"
        );
    }
}
