# erc20TokenICO
An ICO smart contract for a fully ERC-20 compliant token

• The ICO will be a Smart Contract that accepts ETH in exchange for our own token named
ARKCoin (ARK);
• The Cryptos token is a fully compliant ERC20 token and will be generated at the ICO time;
• Investors will send ETH to the ICO contract's address and in return, they'll get an amount of
Cryptos;
• There will be a deposit address (EOA account) that automatically receives the ETH sent to
the ICO contract;

●ARK token price in wei is: 1ARK = 0.01Eth = 10**15 wei, 1 Eth = 1000 ARK);
●The minimum investment is 0.01 ETH and the maximum investment is 5 ETH:

●The ICO Hardcap is 300 ETH;
● The ICO will have an admin that specifies when the ICO starts and ends:
●The ICO ends when the Hardcap or the end time is reached (whichever comes first):
The ARK token will be tradable only after a specific time set by the admin:

●In case of an emergency the admin could stop the ICO and could also change the deposit
address in case it gets compromised;
●The ICO can be in one of the following states: beforeStart, running, afterEnd, halted;
● A possibility to burn the tokens that were not sold in the ICO;
● After an investment in the ICO the Invest event will be emitted
● Token Contract Address (Rinkeby Testnet): 0x4abcc547b3d00ce9be2fc0c23771ea9f7e54b2cb
