#!/bin/sh

forge init --force --no-commit

cat multiplier2_js/verifier.sol | sed 's/pragma solidity ^0.6.11/pragma solidity ^0.8.13/' > src/verifier.sol

cat > test/verifier.t.sol <<EOF
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/verifier.sol";

contract VerifierTest is Test {
    Verifier verifier = new Verifier();

    function testVerifyProof() public view {
        bool ans = verifier.verifyProof(
$(cat multiplier2_js/call_solidity.txt)
        );
        assert(ans);
    }
}
EOF
cat test/verifier.t.sol

forge test
