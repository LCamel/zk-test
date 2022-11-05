#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

npm install snarkjs
PATH=`pwd`/node_modules/.bin:$PATH

cat > multiplier2.circom <<EOF
pragma circom 2.0.0;
template Multiplier2() {
    signal input a;
    signal input b;
    signal output c;
    c <== a * b;
}
component main = Multiplier2();
EOF


circom multiplier2.circom --r1cs --wasm --sym --c

cd *_js
cp ../*r1cs .

#snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
#echo "aa" | snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
#snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
cp $SCRIPT_DIR/pot12_final.ptau .

snarkjs groth16 setup multiplier2.r1cs pot12_final.ptau multiplier2_0000.zkey
echo "bb" | snarkjs zkey contribute multiplier2_0000.zkey multiplier2_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey multiplier2_0001.zkey verification_key.json

cat > input.json <<EOF
{"a": "3", "b": "11"}
EOF

node generate_witness.js multiplier2.wasm input.json witness.wtns

snarkjs groth16 prove multiplier2_0001.zkey witness.wtns proof.json public.json

snarkjs groth16 verify verification_key.json public.json proof.json


snarkjs zkey export solidityverifier multiplier2_0001.zkey verifier.sol
snarkjs generatecall
