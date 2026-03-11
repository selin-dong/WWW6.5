//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tipjar{
	address public owner;//谁
	uint256 public totalTipsReceived;//总共收到多少小费

	mapping(string => uint256) public conversionRates;//实时汇率
	mapping(address => uint256) public tipper; //每个人给多少

	string[] public supportedCurrencies;//支持的货币
	mapping(string => uint256) public tipsPerCurrency;//每种货币收多少小费

	modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

	function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
		require(_rateToEth > 0, "Conversion rate must be greater than 0");//快速的安全检查
		bool currencyExists = false;//先假设不存在,有点像统计中的0假设

		for (uint i = 0; i < supportedCurrencies.length; i++) {
			(keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))){
				currencyExists = true;
        		break;
			}
		}

		if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth;
}
	constructor() {
    owner = msg.sender;

    addCurrency("USD", 5 * 10**14);
    addCurrency("EUR", 6 * 10**14);
    addCurrency("JPY", 4 * 10**12);
    addCurrency("GBP", 7 * 10**14);//开业当天预置常用货币

	}

	function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
		require(conversionRates[_currencyCode] > 0, "Currency not supported");

		uint256 ethAmount = _amount * conversionRates[_currencyCode];
    	return ethAmount;
	}

	function tipInEth() public payable {
		require(msg.value > 0, "Tip amount must be greater than 0");

    	tipperContributions[msg.sender] += msg.value;
    	totalTipsReceived += msg.value;
    	tipsPerCurrency["ETH"] += msg.value;

	}

	function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
    	require(conversionRates[_currencyCode] > 0, "Currency not supported");
    	require(_amount > 0, "Amount must be greater than 0");

    	uint256 ethAmount = convertToEth(_currencyCode, _amount);
    	require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

    	tipperContributions[msg.sender] += msg.value;
    	totalTipsReceived += msg.value;
    	tipsPerCurrency[_currencyCode] += _amount;
	}

	

	function withdrawTips() public onlyOwner {
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "No tips to withdraw");

    (bool success, ) = payable(owner).call{value: contractBalance}("");//只转账，只返回是否成功
    require(success, "Transfer failed");

    totalTipsReceived = 0;
	}

	function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Invalid address");
    owner = _newOwner;
	}


}

  
