-include .env 

all: clean install update deploy verify

clean  :; forge clean

install :; 
	forge install foundry-rs/forge-std 
	forge install OpenZeppelin/openzeppelin-contracts

update:; forge update

build  :; forge clean && forge build

deploy:
	bash ./deploy.sh

verify:
	bash ./verify.sh