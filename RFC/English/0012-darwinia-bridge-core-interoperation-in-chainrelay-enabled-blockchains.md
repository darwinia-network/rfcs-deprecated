---
Rfc: 12
Title: 0012-darwinia-bridge-core-interoperation-in-chainrelay-enabled-blockchains
Status: Draft
Desc: Darwinia Bridge Core - Interoperation in ChainRelay Enabled Blockchains

---

# Darwinia Bridge Core: Interoperation in ChainRelay Enabled Blockchains



## I. Abstract

XClaim (Cross Claim) proposes a universal, efficient and low-cost cross-chain framework for the shortcomings of ACCS, using Cryptocurrency-Bakced Assets (CBAs). 

Although XClaim solves the shortcomings of ACCS to some extent, it also has its own limitations: it is only valid for Fungible Token, and. There is currently no general framework for cross-chain circulation of NFT. And Vault's collateral design in the XClaim solution may also have a problem of insufficient yield.

This article describes how to remove the Vault role and its collateral by introducing a chainRelay on the Backing Blockchain.



## II. Introduction

For the token exchange on different blockchains, although centralized exchanges can help to implement, such services require a high degree of trust, and are prone to problems such as main actions and single points of failure. With the advent of a number of excellent cross-chain projects such as Cosmos and Polkadot, decentralized token circulation protocols/schemes that are architected on cross-chain infrastructure have also become important research content.

In the existing scheme, atomic cross-chain swaps (ACCS) is the first feasible solution, but due to its low cross-chain efficiency and high cost, there are not many practical scenarios. Subsequently, XClaim (Cross Claim) proposed a general, efficient and low-cost cross-chain framework for the shortcomings of ACCS, using Cryptocurrency-Bakced Assets (CBAs).

Although XClaim solves the shortcomings of ACCS to some extent, it also has its own limitations: it is only valid for Fungible Token, and. There is currently no general framework for cross-chain circulation of NFT. In this paper, the dual-chain cross-over is taken as an example. By introducing more assumptions to the Backing Blockchain, that is, the Backing Blockchain supports smart contracts, an improved universal XClaim solution based on dual Chain Relay (both for Fungible Token and NFT) is proposed.

The change plan will show the design ideas and process realization of the Two chainRelay Model. [XClaim] (https://eprint.iacr.org/2018/643.pdf) cross-chain solution can guarantee the cross-chain security operation of NFT in most occasions, but still can not guarantee the sharp price of the certificate assets Robustness and sustainability of the entire system when fluctuating.

At the same time, this article will also focus on the implementation cost of chainRelay and its improvement program. The current improvement ideas include two solutions. First, by submitting *block headers* in batches, or by constructing *merkle tree* for *block headers*. Compression costs, second, by using zero-knowledge proof techniques, reduce the cost of uploading *block headers* and increase the speed of verification transactions on the chain.							



## III. Overview

In this chapter, we first review and define some of the concepts in XClaim that are relevant to this article, as well as the models of the system and the roles involved.

### A. Cryptocurrency-backed Assets (CBA)

**Definition.** We define *cryptocurrency-backed assets* (CBAs) as assets deployed on top of a blockchain *I* that are backed by a cryptocurrency on blockchain *B*. We refer assets in *I* as *i *, and cryptocurrency on *B* as *b*. We use *i(b)* to further said when an asset on *I* is backed by *b*. We describe a CBA through the following fields:

- *issuing blockchain*, the blockchain *I* on which the CBA *i(b)* is issued.

- *backing blockchain*, the blockchain *B* that backs *i(b)* using cryptocurrency *b*.

- *asset value*, the units of the backing cryptocurrency *b* used to generate the asset *i(b)*.

- *asset redeemability*, whether or not *i(b)* can be redeemed on *B* for *b*.

- *asset owner*, the current owner of *i(b)* on *I*.

- *asset fungibility*, whether or not units of *i(b)* are inter-

  Changeable.

### B. System Model and Actors

XCLAIM operates between a backing blockchain *B* of cryptocurrency *b* and an issuing blockchain *I* with underlying CBA *i(b)*. To operate CBAs, XCLAIM further differentiates between the following actors in the system:

- CBA Requester. Locks b on B to request i(b) on I.

- CBA Sender. Owns i(b) and transfers ownership to another

  User on I.

- CBA Receiver. Receives and is assigned ownership over

  i(b) on I.

- CBA Redeemer. Destroys i(b) on I to request the corre-

  Sponding amount of b on B.

- CBA Backing Smart Constract(bSC). A public smart contract responsible for trust-free locking/releasing *b* as protocol design requires and liable for fulfilling redeem requests of i(b) for b on B, with support of chain relay to Honestly follow the instructions from redeem requests from I. *bSC* is registered on *I* so that the issuing contracts on *I* will know the transactions happen to bSC.

- Issuing Smart Contract (iSC). A public smart contract responsible for managing the correct issuing and exchange of i(b) on I. The *iSC* is required to register on *bSC* so ​​that the backing contracts on *B* will Know the transactions happen to *iSC*, in this way, *iSC* assurance correct behaviour of the *bSC*, eg the release action in redeem protocol.

  To perform these roles in XCLAIM, actors are identified on a blockchain using their public/private key pairs. As a result, the requester, redeemer must maintain key pairs for both blockchains B and I. The sender and receiver only need to maintain key pairs For the issuing blockchain *I*. *iSC* exists as a publicly verifiable smart contract on *I*, and *bSC* exists as a publicly verifiable smart contract on *B*.

### C. What is *chain relay*

XClaim gives the definition of *chain relay* [7]:

> Chain relays: Cross-Chain State Verification. It is capable of interpreting the statte of the backing blockchain B and provide functionality comparable to an SPV or light client [10].

Therefore, *chain relay* can be thought of as consisting of a block header containing the root of merkle tree. It provides two functions for iSC: * Proof of transaction existence* and *Consensus proof*.

- *** Proof of transaction existence ***: *chain relay* stores each block header of the blockchain and the root of merkle tree in the block header. In the case of providing the merkle tree path, this is sufficient to prove Whether a transaction exists in a certain block of this chain.
- *** Consensus Proof ***: Take Bitcoin as an example. Because each node usually cannot see the whole network in real time, it often happens that a lone block is generated and discarded in reorganization. To avoid attacks/vulnerabilities caused by this situation, *chain relay* must verify that a given block header is part of a complete blockchain, for example, recognized by most nodes. For blockchains with a consensus Proof-of-Work, *chain relay* must: (i) know the mining difficulty adjustment strategy (ii) verify that the received block header is on the chain with the most cumulative workload proof. For blockchains with a consensus Proof-of-Stake, *chain relay* must: (i) know the phase of the protocol request/staking, eg epoch (ii) verify that the number of certifier signatures in the block header meets the block threshold requirements .

![Chain Relay](./images/chain_relay.svg)

[TODO: Image from the web]

### D. Blockchain model and assumptions

In the blockchain project that is currently online, there is almost no NFT as the original asset of the chain, and all NFTs are almost realized in smart contracts. Therefore, a new and reasonable assumption can be introduced for the chain $B$ where the native asset is located:

- *Backing blockchain* and *Issuing blockchain*: Both support Turing-complete smart contracts

In this way, we can provide stronger technical constraints by placing separate smart contracts bSC and iSC on $B$ and $I$ to ensure cross-chain security.

### E. System Goals

1. Support General Tokens
   - Workable for NFT
   - Workable for Fungible Tokens without liquidations on ourside exchanges.
2. Economic Feasible
   - Backing contract does not require to provide a lot of collaterals for the safety of redeem protocol
   - Feasible solutions for to support running low cost chain relay on backing blockchain.
3. Securty Properties (Ignore, refer the section in XClaim paper):
   - Audiability
   - Consitency
   - Redeemability
   - Liveness
   - Atomic Swaps
   - Scale-out
   - Compatiblity



## IV. Backing Contract Solution

**Backing Contract Solution** (two chain relay model) implements the lock-in and redemption release function of the endorsement asset *b* by introducing a smart contract that supports chain relay on the Backing Blockchain. With the support of chain relay, Backing Contract will be able to faithfully execute the redemption order on the release chain *I* without worrying about asset security issues, and does not require Backing Contract to pledge assets because Backing Contract is Audited and registered in *iSC*, thus avoiding the risk of intermediaries trust and single point of failure.



Compared to XClaim's original solution, we introduced a cross-chain solution with no $vault$ pledge, which guarantees redemption and security by introducing chain-relay on the backing blockchain. *chainRelay* can provide proof of transaction and proof of consensus for the blockchain. In XClaim's scheme, there is no additional requirement for chain $B$, resulting in security on chain $B$ only by chain $I$ Offer $vault$ on mortgage $i\_col$. ***bSC + iSC*** bidirectional mutual authentication and interoperability can be implemented in the transit bridge through the new hypothesis constraints introduced in chain $B$ in III-D. For example, in a redemption agreement, asset security on chain $B$ can be implemented non-interoperably, reducing the dependency on $vault$.

### A. Protocols

This program provides five agreements: Register, Issue, Transfer, Swap and Redeem.



**Protocol: Register. ** *bSC* needs to be registered in *iSC*, *iSC* also needs to be registered in *bSC*, this mutual registration process needs to be publicly auditable and closed externally after registration is completed ( The registration of the centralized key) registration is completed.

[WIP]

**Protocol: Issue. **

[WIP]

**Protocol: Transfer. **

[WIP]

**Protocol: Swap. **

[WIP]

**Protocol: Redeem. **

[WIP]

![Solution Protocols](./images/xclaim_new_protocol_overview.png)

Fig High-level overview of the Register, Issue, Swap and Redeem Protocol.

### B. Issue Contract 

Thanks to the Backing Contract and the elimination of the part that only needs to pledged assets, the new Issuing Contract has been greatly simplified compared to the original XClaim solution.

![Issuing Contract](./images/issuing_contract.png)

### C. Backing Contract

The Backing Contract is used to replace the Vault part of the original XClaim, and adds the smart contract and chain relay support. By introducing the chain relay in the Backing Blockchain, when the redemption occurs, the Backing Contract can listen to the destruction action on the Issuing Blockchain, and Perform transaction verification and confirm the corresponding endorsement asset release action.

![Backing Contract](./images/backing_contract.png)



#### D. *chain relay* How to trust

Here is an example of *Protocol Issue* in Section IV.A. When *requester* locks $b$ to $bSC$, a transaction is generated: $lock(backing_contract_address, lock_amount) -> T_l$ , then backing The chain relay's *witness* will submit the transaction $T_l$ to *chain relay*, after which *chain relay* will verify that $T_l$ is indeed present in the transaction for the given block (transaction proof), this block It also exists in the longest chain and has good finality (consensus proof), then it proves that the endorsement asset &&b has been safely locked. If the verification passes, the asset issuance operation in *iSC* is triggered atomically.



## V. Darwinia Bridge Core - Chain Relay Topology Optimization

To transfer tokens across two chains in a chain, the cost of maintaining *chain relay* in chain $I$ is very high, for example, every transaction on Ethereum requires gas. If you extend the cross-chain behavior between the two public chains to any $n$ public chain, then each strand needs to maintain $n-1$ iSC separately, which will require $C_n^2$ chain relay in total. contract. In order to reduce the maintenance cost of the system, consider implementing the core functions of the cross-chain on the parallel chain based on the substrate.

### A. *Darwinia Bridge Core* Architecture

Then the architecture of the entire system is as follows:

![chain-relay-framework](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8rjjzvj30kb0bfgmc.jpg)

In the figure, **Bridge Core** is the core module that contains the cross-chain and the chain relay on the parallel chain; **vSC** is the distribution module of the corresponding chain of **Bridge Core**. Different from the previous cross-chain solution, in the architecture of the above figure, all the tokens of the chain need to first enter the **Bridge Core**, and then convert to the iSC corresponding to the destination public link in the **Bridge Core** Finally, the corresponding assets are issued on the corresponding public chain, and the entire cross-chain operation is completed.

### B. Overview

[WIP]

## VI. Chain Relay Maintenance Cost and Improments

Changing the Collateral Vault model in the Backing Blockchain to the chain relay solution In addition to the Smart Contract support of the Backing Blockchain, there is a disadvantage and a place to consider, which is to maintain the cost of the chain relay, especially for fuel costs like Ethereum. Blockchain network.

### A. Cost Estimation

[WIP]

### B. Improments using Merkle Mountain Ranges



[WIP, Merkle Mountain Range]

### C. Improments using Zero-knowlege Proofs

[WIP]



## VI. Reference

1. https://github.com/sec-bit/zkPoD-lib
2. https://github.com/mimblewimble/grin/blob/master/doc/mmr.md
3. https://github.com/ipfs/specs/tree/master/merkledag
4. https://hackernoon.com/ipfs-and-merkle-forest-a6b7f15f3537