all    :; source .env && dapp --use solc:0.6.7 build
flat   :; source .env && dapp --use solc:0.6.7 flat
clean  :; dapp clean
test   :; dapp test
deploy :; dapp create Landrs

.PHONY: all flat clean test deploy
