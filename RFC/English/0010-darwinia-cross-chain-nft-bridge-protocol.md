---
rfc: 10
title: 0010-darwinia-cross-chain-nft-bridge-protocol
status: Draft
desc: Cross-chain NFT Bridge Protocol
---


# Cross-chain NFT Bridge Protocol

### v 0.3.0



## I. Over view

The Xclaim-based framework provides an idea for token cross-chain, but there are still many problems with NFT, including the Vault collateral design on the Backing Blockchain. This problem can be effectively solved by introducing a chain-Relay contract on the Backing Blockchain. This paper will design a cross-chain Nft solution and standard based on this improved cross-chain bridge solution.

**Keywords**：Blockchain, NFT, cross chain, multi-chain



## II. Background

### A. Research History

The emergence of Bitcoin [1] allows everyone to operate their own assets trustless, as long as they have a private key. The entire Bitcoin system consists of a series of blocks that record their pre-order block hashes, maintaining the same decentralized global “ledger”.

After Bitcoin, with the rapid development of the blockchain, smart contracts are supported by the public chains - Ethereum [2], the public chain of PoS - EOS [3]. The outbreak of these public chains has brought prosperity to the entire token trading market.

The mainstream token trading/exchange method is still via a centralized exchange, and the user's token is managed by exchange as well. Trust and maintenance costs are high and there is a constant threat of hacking.

In order to overcome the drawbacks of centralized exchanges, decentralized exchanges (DEX) began to emerge. Most DEX only support token trading/conversion on a single public chain, such as ERC20[4], ERC721 token[5] on Ethereum. This did achieve decentralization with a limited extent, and reduced the cost of trust (from believing in the organization to believing code); yet the usage scenario is also limited by the Tps and transaction costs of the public chain.

There are also some decentralized exchanges implemented ACCS, allowing tokens to be cross-chain exchanged. They use the hashed timelock contracts (HTLCs) [6].  HTLCs can achieve atomic exchange of cross-chain tokens trust free, which both decentralizes and extends the functionality of DEX on a single chain. Its disadvantage high cost, and with many restrictions: (i) all participants must online during the whole process (ii) invalidation of the dust transaction (iii) lock time is long for most cases. Such  cross-chain token exchange is both expensive and inefficient. In actual use, there are very few examples of the usage of HTLCs.

In order to achieve a trust-free, low-cost, and efficient token cross-chain operation, the XClaim team proposed a cross claim scheme based on CBA. And in XClaim's paper, they explained in detail about how to complete the following four operations: Issue, Transfer, Swap and Redeem.

 The role that ensuring economic security in the XClaim system is called $vault$. If anyone wants to transfer the native token $b$ of chain $B$ into $i(b)$ on chain $I$, then you need $vault$ over-collateralized $i$ on chain $I$. In the above four operations, if $vault$ has malicious behavior, the $i$ that $vault$ mortgaged  is penalized to compensate the cross-chain initiator. For additional details, see XClaim's paper [7].

So far, a reliable and achievable solution of Fungible token cross-chain has been obtained.

### B. Unresolved issues of XClaim framework

There is a basic assumption in the XClaim scheme that the total value of the native token $b$ of chain $B$ locked is equal to the total value of $i(b)$ issued on $I$. In XClaim, it is called symmetric, which is $ |b| = |i(b)|$. The assumption is that XClaim has a natural dilemma for NFT cross-chain:

- The irreplaceability of NFT. Because of the identifiability and irreplaceability of NFT, it is impossible for $vault$ to mortgage NFT $nft_b$ on chain $B$ on chain $I$.
- The value of NFT is difficult to assess. In XClaim, determining whether the $vault$ collateral is full/overdated is achieved through Oracle $O$. So is also a potential assumption that token $b$ and token $i$ can be evaluated correctly. Based on the current prosperous centralization and decentralized exchanges, this potential assumption can be basically met in the case of providing good liquidity. However, the market of the NFT exchange is not yet mature, and even the centralized exchange cannot truly reflect the market's price judgment on the NFT. How NFT pricing itself is a problem.
- NFT pricing is not continuous or predictable. Even if a NFT has a transaction record in the market with a certain price, since the frequency of NFT sold is far less than FT, though market has sufficient liquidity, the next transaction price of the NFT is Not continuous or predictable.

### C. Solution Description

解决以上问题的NFT跨链方案有两种思路，一种是基于XClaim框架并保留桥质押机制的的NFT扩展，通过引入哈伯格机制来解决NFT定价问题，详细的解决方案见[RFC-0011: Using Harberger Tax to find price for XClaim Vault Collaterals](./0011-using-harberger-tax-to-find-price-for-xclaim-vault-collaterals.md). However, this solution still cannot solve the problem of insufficient pledge due to the price change of NFT.

Another idea is to introduce ChainRelay into the Backing Blockchain to offer more protection for the backing assets so that the pledge mechanism is no longer needed. It is called: [RFC-0012: Darwinia Bridge Core: Interoperation in ChainRelay Enabled Blockchains](./0012-darwinia-bridge-core-interoperation-in-chainrelay-enabled-blockchains.md). Detailed introduction will not be described in detail here, and instead this article will focus on designing a cross-chain NFT standard based on this improved cross-chain bridge solution, and proposing a lower cost high extensible function cross-chain protocol for the case of mutual cross among multiple blockchains.



In [RFC-0012](./0012-darwinia-bridge-core-interoperation-in-chainrelay-enabled-blockchains.md) V.A, we introduced the model of Darwinia Bridge Core to optimize the number of chainRelays in the blockchain network topology. This article will be based on the Darwinia Bridge Hub and will be refined for NFT-specific issues.

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8rjjzvj30kb0bfgmc.jpg" alt="chain-relay-framework" style="zoom:80%;" />

## III. NFT in Darwinia Bridge Core

The difficulty of NFT cross-chain operation is that different public chains have their own NFT standards, and even the NFT token ids on different public chains are not equal in length. When NFT crosses different public chains, it will inevitably experience token id. conversion. How to avoid the identifiability of NFT in the process of cross-chain is a proposition worth studying.

When designing NFT flow logic in Bridge Core, we want to solve the following three problems:

- Preserving the cross-chain flow path/history of the NFT without losing the identifiability of the NFT;
- Calculate and verify decoupling with higher processing speed;
- Implement additional functions, such as to complete NFT decomposition, merge, etc. while cross-chaining;



To this end, we chose to introduce some midway parsing state for each NFT that crosses the Bridge Core chain, called UNFO (Unspent NFT Ouput), which will maintain a global ID on the Bridge Core and prove the mapping relationship between the global ID and the NFT external local ID by cross-chain circulation history. UNFO is not necessarily responsible for the NFT's Ownership Management within Bridge Core, but can also be extended by a $lock\_script$, for example by pointing $lock\_script$ to a property management contract. inside Bridge Core.

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8qjwd9j30fe0gh3zg.jpg" alt="0010-framework-of-bridge-core" style="zoom:50%;" />



### A. Component definition

- *Issuing Smart Contract*,  $iSC_N$:  means the asset issuing contract on chain *N*；
- *Backing Smart Contract*,  $bSC_N$ : means the asset lock contract on chain $N$；
- *Verifying Smart Contract*,  $vSC_N$ : means the Validator model in Bridge Core that verify asset issuing contract/model on chain *N* ；
- *Global identifier* ,  $GID$ , The global idendifier for the NFT in Darwinia Bridge Core
- *Unspent Non-Fungible Output* ,  $UNFO$, Intermediate Resolution State for the NFT in Darwinia Bridge Core, aka. unspent NFT output. The idea stems from UTXO, when an UNFO is destroyed, another new UNFO will be generated at the same time.
- *External Backing NFT*,  $nft_B^{x,n}$, means the NFT marked as   $n$  on chain $B$ with contract $x$.
- *Bridge Core Mirror for Backing NFT*, $nft_{BC(unfo_{gid})}^{B,x,n}$,  aka $nft_{BC}^{B, n}$ ，the NFT cross-chained into Bridge Core with midway state, and mirroring with $nft_B^{x,n}$  on chain $B$, which means a corresponding NFT to be issued/locked on chain $B$.  $unfo_{gid}$ means the UNFO midway state of NFT inside Bridge Core.
- *External Issueing NFT*,  $nft_I^{x',n'}$,  means the NFT issued on chain $I$ after cross-chain, with contract  $x'$,  marked as $n'$,
- *Bridge Core Mirror for Issuing NFT*,$nft_{BC(unfo_{gid})}^{I,x',n'}$, aka $nft_{BC}^{I, n'}$ ，means the NFT cross-chain into Bridge Core with midway state, and mirroring with $nft_I^{x',n'}$ on chain $I$, and suggesting a NFT on chain $I$ is to be issued/locked.  $unfo_{gid}$ means the the UNFO of NFT inside Bridge Core with midway state.
- *Locking Transaction* ,  $T_{B}^{lock}$,  the transaction lock NFT in  $bSC_B$ on chain *B*
- *Redeem Transaction* ,  $T_I^{redeem}$， the transaction lock NFT in $bSC_I$ on chain *I*
- *Extrinsic Issue*,  $EX_{issue}$ , the issure transaction in Bridge Core
- *Extrinsic redeem*,  $EX_{redeem}$ , the redeem transaction in Bridge Core.

Participants:

- *validator*,  the participant  that maintin Bridge Core；

### B. UNFO Realization and effect

#### B.I UNFO data structure

```rust
struct UNFO {
  pub local_id, // chain_id + smart_cotnract_id + token_id
  pub global_id,
  pub phase, // current phase
  pub lock_script, // e.g. ownership or state management
}
```

- **local_id**：Indicates that the UNFO corresponds to the *token_id* of *smart_contract_id* on an external blockchain *chain_id*
- **global_id**：indicates this UNFO has Globally unique identifier within all blockchain it crossed.
- **phase**：indicates the stage of cross-chain of the UNFO. Eg:
  - 1: the correspond NFT on blockchain *chain_id* of the UNFO was looked, the cross-chain process is in midway state
  - 2: the correspond Nft of the Unfo on blockchain *chain_id*has been issued/to be issued；cross-chain process has been finished/to be finished.
- **lock_script**: For more complex logic, fine-grained control scripts that maintain UNFO's scalability. Lock_script expresses the owner of this NFT. When the NFT is circulating within the Bridge Core, the lock_script may point to an ownership contract. When the NFT is locked in the backing contract, the lock_script may point to to the redeem contract of backing contract.



#### B.II. UNFO Conversion

We chose to use the UNFO model as a storage/state flow unit. The UNFO model is a design idea similar to the UTXO model.

The destruction of one UNFO means the creation of another, if we trace the history of UNFO's destruction and creation, we can trace back the entire cross-chain history of an NFT, which helps to achieve the NFT's identifiability to a certain extent.

Each UNFO can only be destroyed once, which makes it unnecessary to verify before the calculation, thus improving the processing speed;

Just like Bitcoin's UTXO, there can be more than one Input and Output. This feature allows the NFT to perform some extended functions during the process of cross-chaining. such as NFT splitting and merging,

NFT has always been more useful than FT. For example, in games, the NFT as a prop is required to be detachable, synthesizable, and scalable. For this reason, many NFT standards, such as ERC721, ERC721X and ERC1155, have been extended and so on. The more standards, the more difficult it is to be widely used.

If some of the common requirements can be implemented during cross-chain process, the number and redundancy of standards can be effectively reduced, and to a certain extent, it is more conducive to achieve a unified standard.



When an UNFO is produced, it must satisfy:

- Provide a lock record for the corresponding NFT of *backing blockchain*;
- Another UFNO destroyed
  - Condition: The GID of the destroyed and produced UNFO must be the same

<img src="https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8skd28j30hj06z0sz.jpg" alt="0010-UNFO-transform" style="zoom:50%;" />

#### B.III. UNFO-based NFT mapping and resolution services

The token parsing module is a module embedded in the NFT cross-chain protocol for recording and parsing the global state of current token within the scope of *Issuing chain* or its connected relay chain, and normalized into a parsing format to provide token parsing query and certification service for the cross-chain network.

During the transition of the NFT from chain B to chain I, Bridge Core assigns a GID to each NFT and expresses the midway state and its transfer process as UNFO, including GID, (External Chain ID, External Contact Address)., External Token ID), lock_script and other information.

These UNFO record collections are grouped into a resolution table. Analysis table can provide NFT certificate resolution services for cross-chain protocols (e.g redeem) or NFT resolution services for external systems.

| UNFO | GID     | Externl Chain ID | External Contact Address | External Token ID | Lock_Script                      | Active Status |
| ---- | ------- | ---------------- | ------------------------ | ----------------- | -------------------------------- | ------------- |
| 1    | GID0001 | Ethereum         | A_ERC721                 | 12                | script_issuing_burn_or_relay | False         |
| 2    | GID0001 | Tron             | B_TRC721                 | ?                 | script_backing_redeem          | True          |
| 3    | GID0002 | EOS              | C_dGoods                 | 2.5.4             | script_issuing_burn_or_relay | False         |
| 4    | GID0002 | EOS              | C_dGoods                 | 2.5.4             | script_ownership_contract      | True          |
| 5    | GID0003 | Bridge Core      | None                     | None              | script_ownership_contract      | True          |
| 6    | GID0004 | ETC              | ETC_ERC721               | 23                | script_issuing_burn_or_relay | False         |
| 7    | GID0004 | Ethereum         | D_ERC1155                | 13                | script_backing_redeem          | False         |

GID0001: This NFT is cross-chain transfered from (Ethereum, A_ERC721, 12) to (Tron, B_TRC721, ?) trough Bridge Core, Currently it is active on Tron.

GID0002: This NFT is cross-chain transfered from (EOS, C_dGoods, 2.5.4) to an account Bridge Core,the script_ownership_contract is linking to an ownership managemetn contract on Bridge Core.

GID0003: This NFT is originally created on Bridge Core, it is recorded as UNFO because the golobal identifier is generated in the UNFO module, the script_ownership_contract is linking to an ownership managemetn contract on Bridge Core.

GID0004: This NFT is cross-chain transfered from (ETC, ETC_ERC721, 23) to (Ethereum, D_ERC1155, ?) trough Bridge Core, and then redeem reversely back. The 7th UNFO's External Local ID is unknow before redeem, but when redeeming, it will be updated to reveal it's value.
<center>
  Figure: UNFO Set Table Sample
</center> 备注:

1. External Token ID有可能是未知状态，用"?"表示，之所以会出现这种情况，是因为在issue过程中, 目标发行链上生成的External Token ID 不会通知和反馈给Bridge Core，没有相关的交易证明信息，UNFO也就只好设置该值为未知。但是，当后面某些新的赎回交易发生时，发起者发送给Bridge Core的赎回交易有可能会包含GID和External Token ID，此时可以通过这个交易证明，更新原来未知的External Token ID值为已知值。
2. 为了保持良好的一致性，在NFT通过Bridge Core跨链流转的生命周期内，希望保持External Chain ID和 (External Contact Address, External Token ID) 的映射关系保持不变，此时可以通过上面提到的解析服务，至历史UNFO记录里面查询相应的External Token ID，以保持一致性。

### C. 初步实现方案

场景同章节II中的描述。依然需要实现三种 protocol：*Issue, Transfer, Redeem*. 同样为了简化模型，这里将不会讨论手续费相关细节。

#### Protocol: Issue

(i) ***锁定***。*requester* 将 chain $B$上的NFT资产 $nft_B^{n,x}$ 锁定在 $bSC_B$ 中，同时声明目的地公链 chain *I* 以及自己在chain $I$ 上的地址；这一步将产生交易$T_B^{lock}$

(ii) ***Bridge Core上发行***。 *requester*  将锁定交易 $T_B^{lock}$ 提交至 Bridge Core, 对应的chain relay验证通过后，即 触发 $vSC_B$ , 在 $vSC_B$ 中：

- 产生新的$GID$ 和 $nft_{BC}^{B,n}$ , 记录 $GID$ 和 $nft_{BC}^{B,n}$ 二者之间的关系，
- 并触发$vSC_I$

在 $vSC_I$ 中：

-  销毁  $nft_{BC}^{B,n}$，发行 $nft_{BC}^{I,?}$， $issue\_{ex}(\ GID,\ address\_on\_I) \rightarrow EX_{issue}$

(iii) ***发行***。*requester* 将 $EX_{issue}$ 提交至 chain $I$ , 经过chain $I$ 上的chain relay 验证通过后，即会在$iSC_I$ 中增发新的NFT: $nft_I^{x', n'}$， 并记录 $GID$ 和 $nft_I^{x', n'}$的关系， 且将所有权交给 *requester* 在chain *I* 上的地址

注: 对于外部区块链上的$iSC$来说，在发行时，也需要在外部区块链上，将全局ID和本地ID的映射记录下来，因为后面redeem的时候，需要使用这个映射关系来完成redeem.

<img src="https://tva1.sinaimg.cn/large/006y8mN6gy1g7sznhszi8j30pz0elabd.jpg" alt="chain-relay-framework-1" style="zoom:50%;" />

#### Protocol: Transfer

(i) ***转移***。*sender* 在 $I$ 上把 $nft_I^{x',n'}$ 在  $iSC_I$ 中，把所有权转移给 *receiver*，参考ERC721.

(ii) ***见证***。当 $nft_I^{x',n'}$ 在  $iSC_I$ 中的所有权发生了转移时，$iSC_I$ 和 $bSC_I$ 都应当觉察。此时，当 *sender* 再想把 $nft_I^{x',n'}$ 赎回时需要先将其锁定在 $bSC_I$ 中，此时 $bSC_I$ 将不会允许该操作成功。

#### Protocol: Redeem

(i) ***锁定***。 *redeemer* 将 chain $I$ 上的NFT资产 $nft_I^{x', n'}$ 锁定在 $bSC_I$ 后 (如果有对应的GID，锁定时需声明 $GID$)，同时声明目的地公链chain $B$ 以及自己在 chain $B$ 上的地址；$bSC_I$ 会原子地 在 $iSC_I$ 中确认 $GUID$ 的正确性。这一步将产生交易$T_I^{redeem}$。$lock\_I(nft\_id\_on\_I,\ GID,\ address\_on\_B) \rightarrow T_I^{redeem}$

(ii) ***Bridge Core上解锁***。 *redeemer* 将 $T_I^{redeem}$ 提交至 $vSC_I$ 并在chain relay中验证通过后，会在 $vSC_I$ 中：

- 记录 $GID$ 和 $nft_I^{x', n'}$ 的对应关系，
- 判断目的地公链并触发相应的 $vSC_B$ ,

在 $vSC_B$ 中,

- 通过 $GID$检索，销毁 $nft_{BC}^{I,n'}$ ，产生 $nft_{BC}^{B, n}$ ，$ redeem\_ex(\ GID,\ nft\_id\_on\_B,\ address\_on\_I) \rightarrow EX_{issue}$

以上过程均在一次Extrinsic内触发，将会产生一笔Extrinsic id，记录为 $EX_{redeem}$

(iii) ***解锁***。 *redeemer* 将 $EX_{redeem}$ 提交给 chain $B$ ， 经过$iSC_B$ 验证通过后，在 $iSC_B$ 中会记录 $GUID$ 和 $nft_B^{x,n}$ 的对应关系， 同时会原子地触发 $bSC_B$ 中的方法，将 $nft_B^{x,n}$ 还给指定的地址。

<img src="https://tva1.sinaimg.cn/large/006y8mN6gy1g7szni9t0lj30r70elgn2.jpg" alt="chain-relay-framework-2" style="zoom:50%;" />

### D. Algorithms

##### Protocol: Issue

<img src="https://tva1.sinaimg.cn/large/006y8mN6gy1g7sznio88rj30uc0j0aca.jpg" alt="image-20191010113808729" style="zoom:50%;" />

解释：

###### *requester* 相关的操作：

- **lockB**($nft_B^{x,n}$, cond):   发生在chain $B$ 内。将$nft_B^{x,n}$ 锁定在 $bSC_B$ 中，并声明 *requester* 在 chain $I$ 上的地址，这个操作对应交易 $T_B^{lock}$

- **verifyBOp**(lockB, $T_B^{lock}$, $\Delta_{lock}$) $\rightarrow T$ :    发生在Bridge Core内。*requester*将 $T_B^{lock}$ 提交至 Bridge Core中的 $vSC_B$ 进行验证，如果 $T_B^{lock}$ 真实地在 chain $B$ 上发生过并且满足最小需要延时 $\Delta_{lock}$，即返回结果T(True)，否则返回F(False).

  如果结果为T，则在 $vSC_B$ 中自动触发 newGid($nft_B^{x,n}$)，会产生新的GID，以及 $nft_B^{x,n}$ 在 Bridge Core内的镜像 $nft_{BC}^{B,n}$ ，并建立GID和 $nft_{BC}^{B,n}$ 的对应关系

- **verifyBCOp**(trigger, $EX_{issue}$, $\Delta_{trigger}$) $\rightarrow T$ :  发生在 chain $I$ 内。*requester* 将 $EX_{issue}$ 提交至chain $I$ 的 $iSC_I$ 内，如果$iSC_I$ 验证 $EX_{issue}$ 的真实性即返回T，否则返回F。验证通过后，即通过调用issue方法，发行 $nft_I^{x',n'}$ 到 *requester* 在 chain $I$ 的地址上。

###### *validator* 相关操作：

- **issueTransform**($vSC_I,\ pk_I^{requester},\ GID$ ): *validator* 会自动触发 $vSC_I$ 中的方法， 将 $nft_{BC}^{B,n}$ 销毁并产生 $nft_{BC}^{I,?}$ 表示在chain $I$ 上即将新增发的nft的镜像（这里之所以用$?$ 因为此时chain $I$ 上的nft还未被增发，因此无法获取其token id），并建立 GID和 $nft_{BC}^{I,?}$ 对应关系。这次操作将产生 $EX_{issue}$.



##### Protocol: Transfer

![image-20190927191635665](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8pswk9j3120050aac.jpg)

解释：

在 chain $I$ 上 *sender* 调用 $iSC_I$ 中的 transfer方法，将 $nft_I^{x',n'}$ 发送给 *receiver*



##### Protocol: Redeem

<img src="https://tva1.sinaimg.cn/large/006y8mN6gy1g7sznhfdu6j314w0q0n0c.jpg" alt="image-20191010114326817" style="zoom:50%;" />

解释：

###### *redeemer* 相关操作：

- **burn**( $nft_I^{x',n'}$, $GID$, $pk_B^{redeemer}$ ) : 发生在 chain $I$ 上。 *redeemer* 触发$bSC_I$ 的方法，将 $nft_I^{x',n'}$ 销毁，但保留销毁记录，$bSC_I$ 可以原子地检验 $GID$ 和 $nft_I^{x',n'}$ 对应关系。该操作将会产生交易 $T_I^{redeem}$
- **verifyIOp**(burn,  $T_I^{redeem}$,  $\Delta_{redeem}$) : 发生在 Bridge Core内。用户将 $T_I^{redeem}$ 提交至 $vSC_I$ 中，如果 $T_I^{redeem}$ 真实地在 chain $I$ 上发生过并且满足最小需要延时 $\Delta_{redeem}$，即会根据 $GID$ 找到 对应的 $nft_{BC}^{I,?}$ 并根据自动补全成 $nft_{BC}^{I,n'}$
- **verifyBCOp**(trigger, $EX_{redeem}$, $\Delta_{trigger}$) $\rightarrow T$ :  发生在 chain $B$ 内。*redeemer* 将 $EX_{redeem}$ 提交至chain $B$ 的 $iSC_B$ 内，如果$iSC_B$ 验证 $EX_{redeem}$ 的真实性即返回T，否则返回F。验证通过后，即通过调用issue方法，即释放 $nft_B^{x,n}$ 到 *redeemer* 在 chain $B$ 的地址上。

###### *validator* 相关操作：

- **burnTransform**($vSC_B,\ GID,\ nft_{BC}^{x,n},\ pk_B^{redeemer}$ ): *validator* 自动触发 $vSC_B$ 中的方法， 将 $nft_{BC}^{I,n'}$ 销毁同时产生 $nft_{BC}^{B,n}$, 表示在chain $B$ 上即将释放的nft的镜像。这次操作将产生 $EX_{redeem}$.



##

## IV. Cross-chain NFT Standards

跨链环境下，NFT会出现在不同的区块链网络中，并且其可用状态可能不断变化，因此类似原来单链网络内的标准和方案(例如，Ethereum ERC20)，已经无法满足跨链NFT标准的需要。

跨链NFT标准面临的识别性和解析问题，需要新的解决方案和标准来解决。因此我们引入一个基于通证跨链证明的解析系统来解决通证跨链时的定位和解析需求，通过通证解析系统和域内唯一标识，我们可以存在与不同域的通证之间的关联关系映射起来，并标识他们之间的相同与不同。

### A. 设计范围

- 全局唯一标识和外部本地标识规范

  为了将不同标准的通证标识符进行规范化，以提供识别和解析方法，与现有的标准进行很好的协调和对接，并满足社区基础设施建设的标准需求。识别标识分为全局唯一标识和外部本地标识。

- NFT解析系统

- NFT所有权管理

- Inter-parachain NFT Transfers

  通过引入一个关联的SPREE模块来帮助在不同的平行链之间进行跨链转账。

### B. 标准方案

基于跨链NFT协议的设计和方案基础，我们设计并提议了一个跨链NFT的标准提案，详细设计放在了 [RFC-0013 Cross-chain NFT Standards](./0013-darwinia-cross-chain-nft-standards.md)。



## 参考

[1] https://bitcoin.org/bitcoin.pdf

[2] https://github.com/ethereum/wiki/wiki/White-Paper

[3] https://github.com/EOSIO/Documentation/blob/master/TechnicalWhitePaper.md

[4] https://eips.ethereum.org/EIPS/eip-20

[5] https://eips.ethereum.org/EIPS/eip-721

[6] https://en.bitcoin.it/wiki/Hashed_Timelock_Contracts

[7] https://eprint.iacr.org/2018/643.pdf

[8] https://opensea.io/

[9] https://vitalik.ca/general/2018/04/20/radical_markets.html

[10] https://github.com/ethereum/wiki/wiki/Light-client-protocol

[11] https://elixir-europe.org/platforms/interoperability

[12] https://github.com/AlphaWallet/TokenScript

[13] https://github.com/darwinia-network/rfcs/blob/v0.1.0/zh_CN/0005-interstella-asset-encoding.md

[14] https://onlinelibrary.wiley.com/doi/pdf/10.1087/20120404

[15] https://wiki.polkadot.network/en/latest/polkadot/learn/spree/

[16] https://en.wikipedia.org/wiki/Unique_identifier

[17] https://en.wikipedia.org/wiki/Identifiers.org

[18] https://schema.org/

[19] https://medium.com/drep-family/cross-chains-a-bridge-connecting-reputation-value-in-silo-b65729cb9cd9

[20] https://github.com/paritytech/parity-bridge

[21] https://vitalik.ca/general/2018/04/20/radical_markets.html

[22] https://talk.darwinia.network/topics/99

