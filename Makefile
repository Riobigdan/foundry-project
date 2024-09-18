-include .env

build:; forge build

test:; forge test -vvvv

test-coverage:; forge coverage

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --account Metamask --broadcast --verfiy --slow
