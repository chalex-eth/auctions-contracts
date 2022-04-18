-include .env 

all: clean remove install update deploy verify

clean  :; forge clean

remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; 
	forge install foundry-rs/forge-std 
	forge install OpenZeppelin/openzeppelin-contracts

update:; forge update

build  :; forge clean && forge build

deploy:
	bash ./deploy.sh

verify:
	bash ./verify.sh