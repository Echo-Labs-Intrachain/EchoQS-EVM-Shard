# EchoQS EVM Shard: The EchoQS EVM Sharding Contract

The backbone of EchoQS is its sharding contract. The sharding contract does not actually process the transaction, rather it handles the data returned by the transaction finalization, as well as internal information about the working shard, like the owner, the address for contact, its holdings, and auxiliary functions. The Sharding Contract is designed to be the reach point for processes and applications wanting to make a call onto a shard, which generally follows this process:

1. An application or end user makes a request through either EchoQS Terminal or an outside application.
2. EchoQS is invoked which checks the requested sharding contract for its address, transaction state, and whether the requested chains are supported.
3. EchoQS receives the sharding data and attempts to make contact with the shard and send the data for processing.
4. Shard processes required data from the provided chain information, then sends its results back to the requester instance.
5. Shard, sends completion information to the Sharding Contract which is updated on the respective chain.

As stated the sharding contract can be configured in many ways, and is extendable. A person can set up their instance of EchoQS to support only specific chains, or be open to any ongoing transaction. As well, the  contract can be configured with new auxiliary functions. Part of this is due to a new feature that we have implemented: Selective Owner Calling. As part of this process, the contract can be configured so that specific functions are only available to OnlyOwner, a Solidity based owning mechanisms pioneered by OpenZepplin. This, in turn means that only the shard contract minter can call specific functions, allowing for more extensive and protected applications use. Keep in mind, all shard functions are exposed via emit events in the contract, and can be accessed by any application that is EchoQS compliant, as long as it is not locked under OnlyOwner.

THIS IS A BETA CONTRACT AND MAY HAVE BUGS. FOR ANY BUGS OR ISSUES PLEASE SEND A REPORT TO: devops@echoqs.org

TODO: Test Chain Checks on AddNewSupportedTokenToEchoShard() and RemoveSupportedTokenFromEchoShard() Respectively.

How to use:

1. Take the contract to your chain of choice through Remix IDE.
2. Compile to Chain and Verify Contract.
3. Use an applicable JSON Client RPC for connection. We Recommend Nethereum for most users if you have access.
4. Write a Function Call to: EchoShardAttemptProcessTransaction(...)
5. Process the Data.

This is a simplified process and a proper Documentation SDK is Being Developed. 

FOR TROUBLESHOOTING AND TECHNICAL INQUIRIES, PLEASE REFER TO THE ECHOQS DISCORD: https://discord.gg/D9zHYtWVYM OR VISIT HTTPS://ECHOQS.ORG
