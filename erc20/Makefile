# include .env

build:
	forge build

test:
	forge test

mt:
	forge test -vvv --match-test 

format:
	forge fmt

lint:
	forge lint

clean:
	forge clean

snapshot:
	forge snapshot

deploy:
	forge script script/DeployZepplinToken.s.sol:DeployZeppelinToken --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --slow

anvil:
	anvil -m 'test test test test test test test test test test test junk' --steps-tracing

deploy-anvil:
	forge script script/DeployZepplinToken.s.sol:DeployZeppelinToken --fork-url http://localhost:8545 --broadcast --slow

