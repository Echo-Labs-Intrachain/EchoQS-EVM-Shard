/**
 *Submitted for verification at testnet-zkevm.polygonscan.com on 2023-09-28
*/

/**
* ECHO-QS SHARD CONNECTOR - Solidity Contract for interfacing with EchoQS and EchoQS Canary Shards
* (C) 2021-2024, Team Echo
* Version B.00A.1
*
* DO NOT COMPILE DIRECTLY UNLESS SPECIFIED. CONTRACT SHOULD BE COMPILED BY EXTERNAL SHARD SOFTWARE.
* FAILURE TO COMPLY MAY RESULT IN INSTABILLITY AND SHARD FAILURE, AS WELL AS CROSS CHAIN TOKEN LOSS
*
* THIS IS A BETA CONTRACT AND MAY HAVE BUGS. FOR ANY BUGS OR ISSUES PLEASE SEND A REPORT TO: devops@echoqs.org
*
* FOR TROUBLESHOOTING AND TECHNICAL INQUIRIES, PLEASE REFER TO THE ECHOQS DISCORD: https://discord.gg/D9zHYtWVYM
* OR VISIT HTTPS://ECHOQS.ORG
*
*
* TODO: Test Chain Checks on AddNewSupportedTokenToEchoShard() and RemoveSupportedTokenFromEchoShard() Respectively.
*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

/**

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

enum EchoShardTokenizationActionIdentifer{
    TOKEN_TRANSFER_ADDITION,
    TOKEN_TRANSFER_SUBTRACT,
    TOKEN_TRANSFER_CALCULATE_GAS,
    TOKEN_TRANSFER_MOVE_CUSTODY,
    TOKEN_TRANSACTION_INCREMENT,
    TOKEN_SHARD_CONNECTOR_TRANSACTION_INTERNAL,
    TOKEN_SHARD_ADD_CHAIN_SUPPORT,
    TOKEN_SHARD_REMOVE_CHAIN_SUPPORT
}

struct EchoShardTokenizationInfo{
    string EVMChainName;
    string EVMChainSymbol;
    uint256 Value;
    uint Decimals;
    uint256 TransactionCount;
}

contract  EchoShardConnector is Ownable{

    string EchoShardConnectorName;
    string EchoShardHypercubeHash;
    string EchoShardDirectStoreLocation;
    uint256 EchoShardTotalPendingTransactions;
    address EchoShardOwner;
    uint256 EchoShardMainChainNumeric;
    bool EchoShardConnectorIsActive;

    mapping(uint256 => EchoShardTokenizationInfo) EchoShardConnectorTokenizationInfo;

    mapping(uint => string)EchoShardConnectorExposedFunctions;

    event EchoShardConnectorTransactionSuccess(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action);
    event EchoShardConnectorTransactionFailed(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action, uint reasonCode, string reason);
    event EchoShardConnectorEmitNewSupportedChain(address transactor, EchoShardTokenizationInfo info);
    event EchoShardConnectorEmitRemoveSupportedChain(address transactor, uint256 chainID);
    event EchoEmitString(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action, string functionRequested, string retn);
    event EchoEmitUint256(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action, string functionRequested, uint256 retn);
    event EchoEmitUint(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action, string functionRequested, uint retn);
    event EchoEmitAddress(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action, string functionRequested, address retn);
    event EchoEmitBoolean(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action, string functionRequested, bool retn);
    event EchoEmitTokenizationInfo(address transactor, string name, uint256 val, string transactionID, EchoShardTokenizationActionIdentifer action, string functionRequested, EchoShardTokenizationInfo retn);


    constructor(string memory ConnectorName, string memory ShardHash, string memory ShardDirectStoreLocation, bool ShardIsInTestnet){
        EchoShardConnectorName = ConnectorName;
        EchoShardHypercubeHash = ShardHash;
        EchoShardTotalPendingTransactions = 0;
        EchoShardDirectStoreLocation = ShardDirectStoreLocation;
        EchoShardOwner = Ownable.owner();
        EchoShardConnectorIsActive = true;

        //init the first tokenization on the shard
        if(ShardIsInTestnet){
            EchoShardTokenizationInfo memory tMEITTokenizationInfo = EchoShardTokenizationInfo("Echo Ethereum Intrachain Testnet", "tMEIT",0,9,0);
            EchoShardConnectorTokenizationInfo[0x104] = tMEITTokenizationInfo;
            EchoShardMainChainNumeric = 0x104;
        }else{
            EchoShardTokenizationInfo memory MEITTokenizationInfo = EchoShardTokenizationInfo("Echo Ethereum Intrachain Token", "MEIT",0,9,0);
            EchoShardConnectorTokenizationInfo[0x82] = MEITTokenizationInfo;
            EchoShardMainChainNumeric = 0x82;
        }
        //add exposed functions here
        EchoShardConnectorExposedFunctions[0] = "GetEchoShardConnectorName";
        EchoShardConnectorExposedFunctions[1] = "GetEchoShardHypercubeHash";
        EchoShardConnectorExposedFunctions[2] = "GetEchoShardDirectStoreLocation";
        EchoShardConnectorExposedFunctions[3] = "GetEchoShardTotalPendingTransactions";
        EchoShardConnectorExposedFunctions[4] = "GetEchoShardOwner";
        EchoShardConnectorExposedFunctions[5] = "GetEchoShardTokenizationInfo";
        EchoShardConnectorExposedFunctions[6] = "GetEchoShardExposedFunctions";
        EchoShardConnectorExposedFunctions[7] = "GetEchoShardActiveStatus";
        EchoShardConnectorExposedFunctions[8] = "UpdateEchoShardTransactionCount";
        EchoShardConnectorExposedFunctions[9] = "UpdateEchoShardActiveStatus";
    }

    function GetEchoShardConnectorName() public view returns(string memory){
        return EchoShardConnectorName;
    }

    function GetEchoShardHypercubeHash() public view returns(string memory){
        return EchoShardHypercubeHash;
    }

    function GetEchoShardDirectStoreLocation() public view returns(string memory){
        return EchoShardDirectStoreLocation;
    }

    function GetEchoShardTotalPendingTransactions() public view returns(uint256){
        return EchoShardTotalPendingTransactions;
    }

    function GetEchoShardOwner() public view returns(address){
        return EchoShardOwner;
    }

    function GetEchoShardTokenizationInfo(uint256 value) public view returns(EchoShardTokenizationInfo memory){
        return EchoShardConnectorTokenizationInfo[value];
    }

    function GetEchoShardExposedFunctions(uint256 value) public view returns(string memory){
        return EchoShardConnectorExposedFunctions[value];
    }

    function  GetEchoShardActiveStatus() public view returns(bool){
        return EchoShardConnectorIsActive;
    }

    function UpdateEchoShardTransactionCount(uint256 value)public onlyOwner{
        EchoShardTotalPendingTransactions = value;
    }

    function UpdateEchoShardActiveStatus(bool value)public{
        EchoShardConnectorIsActive = value;
    }

    function AddNewSupportedTokenToEchoShard(uint256 EVMChainID, string memory chainName, string memory chainSymbol, uint chainDecimals) public onlyOwner{
        require(msg.sender == EchoShardOwner, "Must be Shard Ownder To process transaction");
        if((bytes(EchoShardConnectorTokenizationInfo[EVMChainID].EVMChainName).length !=0)){
            emit EchoShardConnectorTransactionFailed(EchoShardOwner,
                EchoShardConnectorTokenizationInfo[EVMChainID].EVMChainName,
                0,
                "",
                EchoShardTokenizationActionIdentifer.TOKEN_SHARD_ADD_CHAIN_SUPPORT,
                0x06,
                "Attempted Support Add of Chain Already Supported. Please Check Chain Information And Try Again.");
            revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");

        }else{
            EchoShardTokenizationInfo memory newChain = EchoShardTokenizationInfo(chainName, chainSymbol, 0, chainDecimals, 0);
            EchoShardConnectorTokenizationInfo[EVMChainID] = newChain;
            emit EchoShardConnectorEmitNewSupportedChain(EchoShardOwner, newChain);
        }
    }

    function RemoveSupportedTokenFromEchoShard(uint256 EVMChainID) public onlyOwner{
        if(bytes(EchoShardConnectorTokenizationInfo[EVMChainID].EVMChainName).length == 0){
            emit EchoShardConnectorTransactionFailed(EchoShardOwner,
                EchoShardConnectorTokenizationInfo[EVMChainID].EVMChainName,
                0,
                "",
                EchoShardTokenizationActionIdentifer.TOKEN_SHARD_ADD_CHAIN_SUPPORT,
                0x07,
                "Attempted Support Removal of Chain Already Removed. Please Check Chain Information And Try Again.");
            revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
        }else{
            EchoShardTokenizationInfo memory newChain = EchoShardTokenizationInfo("", "", 0, 0, 0);
            EchoShardConnectorTokenizationInfo[EVMChainID] = newChain;
            emit EchoShardConnectorEmitRemoveSupportedChain(EchoShardOwner, EVMChainID);
        }
    }

    function EchoShardAttemptProcessTransaction(address transactor, uint256 transactedChain, string memory transactionHash, EchoShardTokenizationActionIdentifer action, uint256 value, uint256 param)public{
        if(EchoShardConnectorIsActive == true){
            if(EchoShardTotalPendingTransactions != 0){
                EchoShardTotalPendingTransactions -= 1;
            }
            if(transactor != EchoShardOwner){
                emit EchoShardConnectorTransactionFailed(transactor,
                    EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                    value,
                    transactionHash,
                    action,
                    0x01,
                    "Shard transactor must Be shard owner. If you are attempting to process transaction to shard, send transaction to shard directly. If you are shard owner, contact Echo Support for further instructions.");
                revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
            }
            else{
                if((bytes(EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName).length ==0))
                {
                    emit EchoShardConnectorTransactionFailed(transactor,
                        EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                        value,
                        transactionHash,
                        action,
                        0x02,
                    "Transaction Commited On Non Suported Token. Please contact Echo Support for further instructions.");
                    revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
                }else{
                    if(action == EchoShardTokenizationActionIdentifer.TOKEN_TRANSFER_ADDITION){
                        EchoShardConnectorTokenizationInfo[transactedChain].TransactionCount+=1;
                        EchoShardConnectorTokenizationInfo[transactedChain].Value += value;
                        emit EchoShardConnectorTransactionSuccess(transactor, 
                        EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                        value,
                        transactionHash,
                        action);
                    }
                    else if(action == EchoShardTokenizationActionIdentifer.TOKEN_TRANSFER_SUBTRACT){
                        EchoShardConnectorTokenizationInfo[transactedChain].TransactionCount+=1;
                        if(value > EchoShardConnectorTokenizationInfo[transactedChain].Value){
                            emit EchoShardConnectorTransactionFailed(transactor,
                                EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                                value,
                                transactionHash,
                                action,
                                0x03,
                                "Transaction Commited With Chain Value Underflow. Please contact Echo Support for further instructions.");
                            revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
                        }
                        else{
                            EchoShardConnectorTokenizationInfo[transactedChain].Value -= value;
                            emit EchoShardConnectorTransactionSuccess(transactor, 
                            EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                            value,
                            transactionHash,
                            action);
                        }
                    }
                    else if(action == EchoShardTokenizationActionIdentifer.TOKEN_TRANSFER_CALCULATE_GAS){
                        EchoShardConnectorTokenizationInfo[transactedChain].TransactionCount+=1;
                        emit EchoShardConnectorTransactionSuccess(transactor, 
                            EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                            value,
                            transactionHash,
                            action);
                    }
                    else if(action == EchoShardTokenizationActionIdentifer.TOKEN_TRANSFER_MOVE_CUSTODY){
                        EchoShardConnectorTokenizationInfo[transactedChain].TransactionCount+=1;
                        emit EchoShardConnectorTransactionSuccess(transactor, 
                            EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                            value,
                            transactionHash,
                            action);
                    }
                    else if(action == EchoShardTokenizationActionIdentifer.TOKEN_TRANSACTION_INCREMENT){
                        EchoShardConnectorTokenizationInfo[transactedChain].TransactionCount+=1;
                        emit EchoShardConnectorTransactionSuccess(transactor, 
                            EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                            value,
                            transactionHash,
                            action);
                    }
                    else if(action == EchoShardTokenizationActionIdentifer.TOKEN_SHARD_CONNECTOR_TRANSACTION_INTERNAL){
                        EchoCallInternalFunction(transactor, value, EchoShardMainChainNumeric, transactionHash, action, param);
                    }
                    else{
                        emit EchoShardConnectorTransactionFailed(transactor,
                                EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                                value,
                                transactionHash,
                                action,
                                0x04,
                                "Invalid Operation Requested. Transaction Reverted. Please contact Echo Support for further instructions.");
                        revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
                    }
                }
            }
        }else{
            emit EchoShardConnectorTransactionFailed(transactor,
                EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                value,
                transactionHash,
                action,
                0x05,
                "Operation Not Permitted As Shard Is Offline. Transaction Reverted. If you did not disable the shard, contact Echo Support for further instructions.");
            revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
        }
    }

    function EchoCallInternalFunction(address transactor, uint functionIdentifier, uint256 transactedChain, string memory transactionHash, EchoShardTokenizationActionIdentifer action, uint256 value)public{
        if(EchoShardConnectorIsActive == true){
            if((bytes(EchoShardConnectorExposedFunctions[functionIdentifier]).length ==0))
            {
                emit EchoShardConnectorTransactionFailed(transactor,
                    EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    0x04,
                    "Invalid Operation Requested. Transaction Reverted. Please contact Echo Support for further instructions."
                );
                revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
            }else{
                if(functionIdentifier == 0){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    emit EchoEmitString(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    GetEchoShardConnectorName());
                }
                else if(functionIdentifier == 1){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    emit EchoEmitString(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    GetEchoShardHypercubeHash());
                }
                else if(functionIdentifier == 2){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    emit EchoEmitString(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    GetEchoShardDirectStoreLocation());
                }
                else if(functionIdentifier == 3){
                EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                emit EchoEmitUint256(transactor,
                EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                functionIdentifier,
                transactionHash,
                action,
                EchoShardConnectorExposedFunctions[functionIdentifier],
                GetEchoShardTotalPendingTransactions());
                }
                else if(functionIdentifier == 4){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    emit EchoEmitAddress(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    GetEchoShardOwner());
                }
                else if(functionIdentifier == 5){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    emit EchoEmitTokenizationInfo(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    EchoShardConnectorTokenizationInfo[value]);
                }
                else if(functionIdentifier == 6){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    emit EchoEmitUint256(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    EchoShardTotalPendingTransactions);
                }
                else if(functionIdentifier == 7){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    emit EchoEmitBoolean(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    EchoShardConnectorIsActive);
                }
                else if(functionIdentifier == 8){
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].TransactionCount +=1;
                    UpdateEchoShardTransactionCount(value);
                    emit EchoEmitUint256(transactor,
                    EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                    functionIdentifier,
                    transactionHash,
                    action,
                    EchoShardConnectorExposedFunctions[functionIdentifier],
                    EchoShardTotalPendingTransactions);
                }
                else if(functionIdentifier == 9){
                    if(value == 0){
                        UpdateEchoShardActiveStatus(true);
                        emit EchoEmitBoolean(transactor,
                            EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                            functionIdentifier,
                            transactionHash,
                            action,
                            EchoShardConnectorExposedFunctions[functionIdentifier],
                            EchoShardConnectorIsActive);
                        }
                        else if(value == 1){
                        UpdateEchoShardActiveStatus(false);
                        emit EchoEmitBoolean(transactor,
                            EchoShardConnectorTokenizationInfo[EchoShardMainChainNumeric].EVMChainName,
                            functionIdentifier,
                            transactionHash,
                            action,
                            EchoShardConnectorExposedFunctions[functionIdentifier],
                            EchoShardConnectorIsActive);
                        }
                        else{
                            emit EchoShardConnectorTransactionFailed(transactor,
                                EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                                functionIdentifier,
                                transactionHash,
                                action,
                                0x04,
                                "Invalid Operation Requested. Transaction Reverted. Please contact Echo Support for further instructions.");
                            revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
                        }
                    }
                else{
                    emit EchoShardConnectorTransactionFailed(transactor,
                        EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                        functionIdentifier,
                        transactionHash,
                        action,
                        0x04,
                        "Invalid Operation Requested. Transaction Reverted. Please contact Echo Support for further instructions.");
                    revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
                }
            }
        }else{
            emit EchoShardConnectorTransactionFailed(transactor,
                EchoShardConnectorTokenizationInfo[transactedChain].EVMChainName,
                value,
                transactionHash,
                action,
                0x05,
                "Operation Not Permitted As Shard Is Offline. Transaction Reverted. If you did not disable the shard, contact Echo Support for further instructions.");
            revert("Fatal Error has occured on transaction. Gas May Have Been Consumed. Please View Transaction Emit Data For More Information.");
        }
    }
