-include .env

build:; forge build

test:; forge test -vvvv

test-coverage:; forge coverage

sepolia:
	forge script script/Interactions.s.sol:FundSubscription --rpc-url $(SEPOLIA_RPC_URL) --account Meta --broadcast --verify --slow

help:
	@echo "Usage: make [command]"
	@echo "Commands:"
	@echo "  build: Build the contract"
	@echo "  test: Run the test"
	@echo "  test-coverage: Run the coverage test"
	@echo "  deploy-sepolia: Deploy the contract to sepolia"
