// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Interface for the Factory contract, which handles index fund contract creation.
interface IFactory {
    /**
     * @notice Returns the address of the token used for purchases (e.g., USDT).
     * @return The address of the purchase token contract.
     */
    function purchaseToken() external view returns (address);
}

// Interface for the decentralized exchange (DEX) router used for asset swaps.
interface dexRouter {
    /**
     * @notice Swaps a specific amount of one token for another.
     * @param receiver The address receiving the output tokens.
     * @param amountIn The amount of the input token to swap.
     * @param tokenIn The ERC20 token being swapped.
     * @param tokenOut The ERC20 token to receive from the swap.
     */
    function swapExactTokens(
        address receiver,
        uint256 amountIn,
        IERC20 tokenIn,
        IERC20 tokenOut
    ) external;

    function getPoolPrice(
        address tokenIn
    ) external view returns(uint256);
}

/**
 * @title IndexFund
 * @notice This contract represents an index fund and includes functionality for sending and receiving tokens,
 *         interacting with a Dex, and managing ERC20 tokens.
 * @dev Inherits from the TokenSender, TokenReceiver, ERC20 contracts.
 */
contract IndexFund is ERC20 {

    /**
     * @notice The Rceived event.
     * @dev This event is emitted anytime the contract receives native coins.
     */
    event Received(address sender, uint amount);

    /**
     * @notice Indicates whether the initial minting of tokens has been performed.
     */
    bool public initialMint;

    /**
     * @notice The address of the contract owner.
     */
    address public owner;

    /**
     * @notice The total number of owners in the index fund.
     */
    uint256 public owners;

    /**
     * @notice The address of the factory contract associated with this index fund.
     */
    address public factoryAddress;

    /**
     * @notice Address of the decentralized exchange (DEX) router used for asset swaps.
     * @dev This address points to the contract responsible for handling token swaps on a DEX.
     */
    address public dexRouterAddress;

    /**
     * @notice Indicates whether the contract has been initialized.
     */
    bool public initialized;

    /**
     * @notice An array of addresses representing the underlying asset contracts in the index.
     */
    address[] public assetContracts;

    /**
     * @notice An array representing the allocation ratios of the underlying assets in the index.
     * @dev Each value corresponds to the respective asset in the `assetContracts` array.
     */
    uint[] public assetRatio;

    /**
     * @notice Initializes the IndexFund contract with the provided parameters.
     * @param _name The name of the Index ERC20 token.
     * @param _symbol The symbol of the Index ERC20 token.
     * @param _owner The address of the contract owner.
     * @param _dexRouterAddress The address of the integrated Dex router contract.
     * @param _factoryAddress The address of the protocol factory contract.
     * @dev The constructor also initializes the inherited ERC20, and TokenBase contracts.
     *      - The `owner` is set to the provided `_owner` address.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _owner,
        address _dexRouterAddress,
        address _factoryAddress
    ) ERC20(_name, _symbol) {
        owner = _owner;
        factoryAddress = _factoryAddress;
        dexRouterAddress = _dexRouterAddress;
    }

    /**
     * @notice Handles recption of native coin to the smart contract.
     * @dev Native coins can be sent to the contract to offset the 
     * wormhole crosschain operations.
     */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @notice Initializes the index with the specified assets, their ratios, and corresponding chain IDs.
     * @param _assetContracts An array of addresses representing the underlying asset contracts.
     * @param _assetRatio An array of ratios corresponding to each underlying asset in the index.
     * @dev This function can only be called by the factory contract. It ensures that the index can only be initialized once.
     *      - Sets the `assetContracts`, `assetRatio`, `assetChains`, `chainId`, and `routerAddress` state variables.
     *      - Marks the contract as initialized to prevent re-initialization.
     * The caller must be the factory contract (`factoryAddress`).
     * The contract must not have been initialized before.
     * The function is payable in order for the creator to drop off some gas for cross-chain operations.
     * When deployed and initailized from the factory contract, some gas is dropped off by default.
     */
    function initializeIndex(
        address[] memory _assetContracts,
        uint[] memory _assetRatio
    ) public payable {
        require(msg.sender == factoryAddress, "This function can only be called through the factory contract");
        require(initialized == false, "The contract has been initialized already");
        assetContracts = _assetContracts;
        assetRatio = _assetRatio;
        initialized = true;
    }

    /**
     * @notice Allows users to invest in the index fund by purchasing underlying assets according to their specified ratios.
     * @param amount The amount of the purchase token to invest in the fund.
     * @dev This function handles both local and cross-chain asset purchases:
     *      - Assets are bought directly.
     *      - It calculates the appropriate amount to allocate to each asset based on their ratios.
     *      - After investment, if the caller has not previously minted tokens, they will receive an initial supply. Otherwise, they receive newly minted tokens based on the investment.
     */
    function investFund(uint amount) public {
        address purchaseToken = IFactory(factoryAddress).purchaseToken();
        IERC20(purchaseToken).transferFrom(msg.sender, address(this), amount);

        // Calculate the total ratio sum
        uint sum = 0;
        for (uint i = 0; i < assetRatio.length; i++) {
            sum += assetRatio[i];
        }
        
        // Calculate the unit amount
        uint unit = amount / sum;
        
        // Calculate the amount to be bought for each token
        uint[] memory tokenAmounts = new uint[](assetRatio.length);
        for (uint i = 0; i < assetRatio.length; i++) {
            tokenAmounts[i] = unit * assetRatio[i];
        }

        for (uint16 i = 0; i < assetContracts.length; i++) {
            IERC20(purchaseToken).approve(dexRouterAddress, tokenAmounts[i]);
            dexRouter(dexRouterAddress).swapExactTokens(address(this), tokenAmounts[i], IERC20(purchaseToken), IERC20(assetContracts[i]));
        }
        
        if (balanceOf(msg.sender) == 0) {
            owners += 1;
        }

        // Mint tokens to the user
        if (initialMint == false) {
            _mint(msg.sender, (10000 * (10 ** 8)));
            initialMint = true;
        } else {
            uint256 _price = price();
            uint256 amount_ = amount / (10 ** 6);
            uint256 _amount = amount_ * (10 ** 18);
            uint256 mintAmount = (_amount / _price) * (10 ** 18);
            _mint(msg.sender, mintAmount);
        }
    }

    /**
     * @notice Allows users to redeem their tokens for the underlying stablecoins.
     * @param amount The amount of tokens to be redeemed.
     * @dev This function handles both local and cross-chain redemptions:
     *      - Local assets are sold directly, and the proceeds are sent to the user.
     *      - Cross-chain assets are redeemed using the `crossChainRedeem` function of the router.
     *      - The user's tokens are burned after the redemption process.
     * The user must have a balance of tokens equal to or greater than the specified `amount`.
     */
    function Redeem(uint amount) public payable {
        require(amount <= balanceOf(msg.sender), "You do not have enough tokens");

        // run through assetContracts in a loop
        for (uint i = 0; i < assetContracts.length; i++) {
            uint256 tokenSellAmount = (amount * IERC20(assetContracts[i]).balanceOf(address(this))) / totalSupply();
            address purchaseToken = IFactory(factoryAddress).purchaseToken();

            IERC20(assetContracts[i]).approve(dexRouterAddress, tokenSellAmount);
            dexRouter(dexRouterAddress).swapExactTokens(address(this), tokenSellAmount, IERC20(assetContracts[i]), IERC20(purchaseToken));
        }

        // Burn tokens                                                                                                                                                                                                                                                                                                                                                                                                          
        _burn(msg.sender, amount);
        
        if (balanceOf(msg.sender) == 0) {
            owners -= 1;
        }
    }

    /**
     * @notice Handles the sremoval and addition of assets in an index.
     * @param oldAssetAddress The address of asset to be replaced in the index.
     * @param newAssetAddress The address of the new asset to be included in the index.
     * @dev This function:
     *      - Ensures that only the owner of the index contract can call it.
     *      - Sells off all the tokens of the asset being replaced that are held in the index smart contract.
     *      - Buys the new asset tokens using the proceeds from the previous sale.
     * The caller must be the router contract, as enforced by the `require` statement.
     */
    function replaceAsset(address oldAssetAddress, address newAssetAddress) public {
        require(msg.sender == owner, "only contract owner can call this function");
        address purchaseToken = IFactory(factoryAddress).purchaseToken();
        // sell off old token
        uint256 oldAmount = IERC20(oldAssetAddress).balanceOf(address(this));
        IERC20(oldAssetAddress).approve(dexRouterAddress, oldAmount);
        dexRouter(dexRouterAddress).swapExactTokens(address(this), oldAmount, IERC20(oldAssetAddress), IERC20(purchaseToken));
        // buy the new token
        uint256 newAmount = IERC20(purchaseToken).balanceOf(address(this));
        IERC20(purchaseToken).approve(dexRouterAddress, newAmount);
        dexRouter(dexRouterAddress).swapExactTokens(address(this), oldAmount, IERC20(purchaseToken), IERC20(newAssetAddress));
    }

    function price() public view returns(uint256 _price) {
        uint256 totalValue = 0;
        for (uint i = 0; i < assetContracts.length; i++) {
            uint256 tokenBalance = IERC20(assetContracts[i]).balanceOf(address(this));
            uint256 tokenPrice = dexRouter(dexRouterAddress).getPoolPrice(assetContracts[i]);
            uint256 tokenValue = (tokenBalance * tokenPrice) / (10 ** 18);
            totalValue = totalValue + tokenValue;
        }

        uint256 supply = totalSupply();
        _price = totalValue / supply;
    }
}