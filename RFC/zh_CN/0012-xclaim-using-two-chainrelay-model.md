---
rfc: 12
title: 0012-xclaim-using-two-chainrelay-model
status: Draft
desc: XClaim Using Two Chain Relay Model

---

# XClaim Using Two ChainRelay Model



## I. Abstract

XClaim (Cross Claim) 针对 ACCS 的缺点，提出了通用的、高效低成本的跨链框架，使用了Cryptocurrency-Bakced Assets (CBAs). 

XClaim 虽然某种程度上解决了 ACCS 的缺点，但是也存在其自身的局限性：只针对Fungible Token有效，并且。目前针对NFT的跨链流通还没有通用框架。并且XClaim方案中Vault的抵押物设计还可能存在收益率不足的问题。

本文将介绍如何通过在Backing Blockchain上引入chainRelay的方案，去除Vault角色及其抵押物。



## II. Introduction

对于不同区块链上的token交换，目前虽然中心化交易所可以帮助执行，但是这样的服务需要高度的信任，且易发生主动作恶、单点故障等问题。随着Cosmos、Polkadot这样一批优秀的跨链项目的落地，架构在跨链基础设施之上的去中心化token流通协议/方案也成为重要的研究内容。

在已有的方案中，atomic cross-chain swaps (ACCS) 是最早提出的可行性方案，但由于其跨链效率低、成本高，实际使用场景并不多。随后，XClaim (Cross Claim) 针对 ACCS 的缺点，提出了通用的、高效低成本的跨链框架，使用了Cryptocurrency-Bakced Assets (CBAs). 

XClaim 虽然某种程度上解决了 ACCS 的缺点，但是也存在其自身的局限性：只针对Fungible Token有效，并且。目前针对NFT的跨链流通还没有通用框架。本文以双链互跨为例，通过对Backing Blockchain引入更多假设，即假设Backing Blockchain支持智能合约，提出基于双Chain Relay的改进版通用XClaim方案（同时适用于Fungible Token和NFT）。

改方案将展示Two chainRelay Model的设计思路和过程实现。[XClaim](https://eprint.iacr.org/2018/643.pdf)跨链方案已经可以保证了在大部分场合下的NFT的跨链安全操作，但是依然无法保证通证资产价格产生剧烈波动时，整个系统的鲁棒性和可持续性。

同时，本文还将着重分析chainRelay的实现成本和其改进方案，目前改进思路包括两个方案的探讨，其一，通过批量提交*block headers*，或对*block headers*构建*merkle tree*的方式压缩成本，其二，通过借助零知识证明的技术，将上传*block headers*成本降低，并提高链上验证交易的速度。							



## III. Overview

在这一章节，我们首先回顾和定义一些XClaim中与本文有关的概念，以及系统的模型和参与其中的角色。

### A. Cryptocurrency-backed Assets(CBA)

**Definition.** We define *cryptocurrency-backed assets* (CBAs) as assets deployed on top of a blockchain *I* that are backed by a cryptocurrency on blockchain *B*. We denote assets in *I* as *i*, and cryptocurrency on *B* as *b*. We use *i(b)* to further denote when an asset on *I* is backed by *b*. We describe a CBA through the following fields:

- *issuing blockchain*, the blockchain *I* on which the CBA *i(b)* is issued.

- *backing blockchain*, the blockchain *B* that backs *i(b)* using cryptocurrency *b*.

- *asset value*, the units of the backing cryptocurrency *b* used to generate the asset *i(b)*.

- *asset redeemability*, whether or not *i(b)* can be redeemed on *B* for *b*.

- *asset owner*, the current owner of *i(b)* on *I*.

- *asset fungibility*, whether or not units of *i(b)* are inter-

  changeable.

### B. System Model and Actors

XCLAIM operates between a backing blockchain *B* of cryptocurrency *b* and an issuing blockchain *I* with underlying CBA *i(b)*. To operate CBAs, XCLAIM further differentiates between the following actors in the system:

- CBA Requester. Locks b on B to request i(b) on I.

- CBA Sender. Owns i(b) and transfers ownership to another

  user on I.

- CBA Receiver. Receives and is assigned ownership over

  i(b) on I.

- CBA Redeemer. Destroys i(b) on I to request the corre-

  sponding amount of b on B.

- CBA Backing Smart Constract(bSC). A public smart contract responsible for trust-free locking/releasing *b* as protocol design requires and liable for fulfilling redeem requests of i(b) for b on B, with support of chain relay to honestly follow the instructions from redeem requests from I. *bSC* is registered on *I* so that the issuing contracts on *I* will know the transactions happen to bSC.

- Issuing Smart Contract (iSC). A public smart contract responsible for managing the correct issuing and exchange of i(b) on I. The *iSC* is required to register on *bSC* so that the backing contracts on *B* will know the transactions happen to *iSC*, in this way, *iSC* ensures correct behaviour of the *bSC*, e.g. the release action in redeem protocol.

  To perform these roles in XCLAIM, actors are identified on a blockchain using their public/private key pairs. As a result, the requester, redeemer must maintain key pairs for both blockchains B and I. The sender and receiver only need to maintain key pairs for the issuing blockchain *I*. *iSC* exists as a publicly verifiable smart contract on *I*, and *bSC* exists as a publicly verifiable smart contract on *B*.

### C. 什么是 *chain relay*

XClaim 给出了对 *chain relay* [7]的定义：

> Chain relays: Cross-Chain State Verification. It is capable of interpreting the statte of the backing blockchain B and provide functionality comparable to an SPV or light client[10].

因此，*chain relay* 可以被认为是由包含root of merkle tree的区块头组成。它为 iSC 提供了两种功能： *交易存在证明* 以及 *共识证明*。

- ***交易存在证明***： *chain relay* 存储着区块链的每一个区块头，以及区块头里的root of merkle tree. 在提供merkle tree路径的情况下，这已经足够可以证明一笔交易是否存在于这条链的某个区块中。
- ***共识证明***： 以比特币为例，因为每个节点通常不能即时看到全网的情况，因此经常会发生产生孤块，又在重组中被丢弃的情况。为了避免这种情况带来的攻击/漏洞，*chain relay* 必须要验证给定的区块头是否为完整区块链的一部分，例如被大部分节点认可。对于共识为Proof-of-Work的区块链，*chain relay* 必须：(i) 知道挖矿难度调整策略  (ii) 验证收到的区块头是否在具有最多累计工作量证明的链上。 对于共识为Proof-of-Stake的区块链，*chain relay* 必须：(i) 知道协议要求/staking的阶段，例如epoch  (ii) 验证区块头中验证人签名数量是否满足区块的阈值要求。 

![Chain Relay](./images/chain_relay.svg)

[TODO: 图片来自于网络]

### D. 区块链模型和假设

在目前已经上线的区块链项目中，几乎没有NFT作为链的原生资产的，所有的NFT几乎都是在智能合约内实现的。因此，对原生资产所在的chain $B$, 可以引入全新且合理的假设：

- *Backing blockchain* 和 *Issuing blockchain*:  都支持图灵完备的智能合约

这样我们就可以通过在 $B$ 和 $I$ 上放置独立的智能合约 bSC 和 iSC 来提供更强的技术约束，保证跨链的安全性。

### E. System Goals

1. Support General Tokens
   - Workable for NFT
   - Workable for Fungible Tokens without liquidations on ourside exchanges.
2. Economic Feasible
   - Backing contract does not require to provide a lot of collaterals for the safety of redeem protocol
   - Feasible solutions for to support running low cost chain relay on backing blockchain.
3. Securty Properties(Ignore, refer the section in XClaim paper):
   - Audiability
   - Consitency
   - Redeemability
   - Liveness
   - Atomic Swaps
   - Scale-out
   - Compatiblity



## IV. Backing Contract Solution

**Backing Contract Solution**(two chain relay model)通过在Backing Blockchain上引入一个支持chain relay的智能合约，以实现背书资产*b*的托管锁定和赎回释放功能。因为有了chain relay的支持，所以Backing Contract将可以忠实的执行发行链*I*上的赎回指令，而不需担心资产的安全问题，也不用要求Backing Contract需要质押资产，因为Backing Contract 是可审计的，并且注册在*iSC*中，因此避免了中间人信任风险和单点故障问题。



相较于XClaim原始的方案，我们引入了完全无 $vault$ 质押的跨链方案，通过在backing blockchain上引入chain-relay来保证可赎回性和安全性。*chainRelay* 可以提供区块链的交易存在证明和共识证明，在XClaim的方案中，对chain $B$ 没有任何额外的要求，导致在 chain $B$ 上的安全只能由在 chain $I$ 上抵押 $i\_col$ 的 $vault$ 来提供。通过III-D中对 chain $B$ 引入的新的假设约束，可以在转接桥中实现***bSC + iSC***双向互相验证和互操作。例如，在赎回协议中， chain $B$ 上的资产安全可以非互操作性地实现，降低对 $vault$ 的依赖。

### A. Protocols

本方案提供五个协议：Register, Issue, Transfer, Swap and Redeem.



**Protocol: Register. ** *bSC*需要在*iSC*中注册，*iSC*也需要在*bSC*中注册，这个相互注册过程需要公开可审计的，并通过注册完成之后的关闭外部(中心化的key的)注册权限的方式完成注册。

[WIP]

**Protocol: Issue. **

[WIP]

**Protocol: Transfer. **

[WIP]

**Protocol: Swap. **

[WIP]

**Protocol: Redeem. **

[WIP]



### B. Issue Contract (WIP)

![image-20190918192745871](https://tva1.sinaimg.cn/large/006y8mN6gy1g74nx67ss8j30m60gc76z.jpg)

​                 （图片来自XClaim，待更新 ）

### C. Backing Contract

[WIP]



#### D.  *chain relay* 如何去信任

这里以章节II中的 *Protocol Issue* 为例，当 *requester* 把 $nft_b^n$ 锁定在 $vault$ 时，会产生一笔交易: $lock(vault_address, lock_amount) -> T_l$ ，随后 *requester* 会向 *chain relay* 提交这笔交易$T_l$ ，之后 *chain relay* 会检验 $T_l$ 确实是存在于给定区块的交易中，这个区块也存在于最长链中，那么就证明token已经被安全地锁定了。如果验证通过，会原子地触发 iSC 中的资产发行操作。



## V. Chain Relay Maintenance Cost and Improments

将Backing Blockchain中的Collateral Vault模型改成chain relay方案除了需要Backing Blockchain的智能合约支持，还有一个缺点和需要考虑的地方，就是维护chain relay的成本，尤其是像以太坊这样的燃料费比较贵的区块链网络。

### A. Cost Estimation

[WIP]

### B. Improments using Merkle Tree of Block Headers

[WIP]

### C. Improments using Zero-knowlege Proofs.

[WIP]



## VI. 参考

1. https://github.com/sec-bit/zkPoD-lib