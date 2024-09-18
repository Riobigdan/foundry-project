-include .env

build:; forge build

test:; forge test -vvvv

test-coverage:; forge coverage

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --account Metamask --broadcast --verfiy --slow

help:
	@echo "Usage: make [command]"
	@echo "Commands:"
	@echo "  build: Build the contract"
	@echo "  test: Run the test"
	@echo "  test-coverage: Run the coverage test"
	@echo "  deploy-sepolia: Deploy the contract to sepolia"
