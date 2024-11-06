// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IndexFund.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title IndexFactory
 * @notice This contract serves as a factory for deploying index fund contracts. It provides functionality to
 *         create and manage index funds.
 * @dev The IndexFactory contract itself is owned and managed by a single owner using the Ownable pattern.
 */
contract IndexFactory {

    // the deployer of the index
    address public owner;

    /**
     * @notice Address of the ERC20 token used as the purchase or payment token within the index fund or related operations.
     */
    address _purchaseToken;

    address dexRouterAddress;

    /**
     * @notice Event emitted when the contract receives ETH. Logs the sender's address and the received amount.
     * @param sender The address that sent the ETH.
     * @param amount The amount of ETH received.
     */
    event Received(address sender, uint amount);

    /**
     * @notice A special function to handle ETH transfers sent directly to the contract.
     *         Emits the Received event when ETH is received.
     */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @notice Utilizing OpenZeppelin's Counters library for managing counters, which includes functions like increment, decrement, and reset.
     */
    using Counters for Counters.Counter; // OpenZeppelin Counter

    /**
     * @notice Counter for tracking the number of index funds created.
     */
    Counters.Counter public _indexCount;

    /**
     * @notice Event emitted when a new index is created.
     * @param deployer The address of the user who created the index.
     * @param indexAddress The address of the deployed index contract.
     * @param name The name of the index fund.
     */
    event IndexCreated(address deployer, address indexAddress, string name);

    /**
     * @notice Mapping to store the address of each index contract based on its unique ID.
     * @dev The key is a unique identifier for each index, and the value is the address of the deployed index contract.
     */
    mapping(uint256 => address) public indicies;

    /**
     * @notice Array of supported blockchain networks where index funds can be deployed.
     * @dev Each element in the array is a `Chain` struct, storing the chain ID and corresponding factory address.
     */
    // Chain[] public chains;

    /**
     * @notice Constructor for initializing the IndexFactory contract with necessary addresses and configurations.
     * @param purchaseToken_ The address of the ERC20 token to be used as the primary purchase or payment token within the index funds.
     * @dev The constructor sets the contract owner using the Ownable pattern. It also initializes several key addresses and parameters 
     *      related to cross-chain communication, token management, and index fund operations.
     */
    constructor(
        address purchaseToken_,
        address _dexRouterAddress
    ) {
        _purchaseToken = purchaseToken_;
        owner = msg.sender;
        dexRouterAddress = _dexRouterAddress;
    }

    /**
     * @notice Creates a new index fund by deploying an index contract and initiating cross-chain deployments.
     * @param _name The name of the index fund.
     * @param _symbol The symbol representing the index fund (e.g., a ticker).
     * @param _assetContracts An array of addresses for the ERC20 contracts that make up the assets of the fund.
     * @param _assetRatio An array of ratios defining the allocation of each asset in the fund.
     * @dev The function deploys the index fund on the current chain.
     *      An `IndexCreated` event is emitted once the index is successfully created.
     */
    function createIndex(
        string memory _name, 
        string memory _symbol,
        address[] memory _assetContracts, 
        uint[] memory _assetRatio
    ) external payable {
        address indexAddress = deployIndex(_name, _symbol, msg.sender, _assetContracts, _assetRatio);
        emit IndexCreated(msg.sender, indexAddress, _name);
    }

    /**
     * @notice Deploys a new index fund contract and initializes it with the provided assets and configurations.
     * @param _name The name of the index fund.
     * @param _symbol The symbol representing the index fund (e.g., a ticker).
     * @param _owner The address of the owner/creator of the index fund.
     * @param _assetContracts An array of addresses for the ERC20 contracts that make up the assets of the fund.
     * @param _assetRatio An array of ratios defining the allocation of each asset in the fund.
     * @dev This function is marked as `internal` and can only be called within the contract. It initializes the index fund using the
     *      provided details and stores it in the `indicies` mapping. An `IndexDeployed` event is emitted once the index is successfully deployed.
     */
    function deployIndex(
        string memory _name, 
        string memory _symbol, 
        address _owner, 
        address[] memory _assetContracts, 
        uint[] memory _assetRatio
    ) internal returns(address indexAddress) {
        IndexFund newIndex = new IndexFund(_name, _symbol, _owner, dexRouterAddress, address(this));
        newIndex.initializeIndex(_assetContracts, _assetRatio);
        indicies[_indexCount.current()] = address(newIndex);
        _indexCount.increment();
        indexAddress = address(newIndex);
    }

    /**
     * @notice Returns the address of the primary purchase token used within the index funds.
     * @return The address of the ERC20 token used for purchases.
     * @dev This function provides a getter for the `_purchaseToken` variable.
     */
    function purchaseToken() external view returns(address) {
        return _purchaseToken;
    }

}