---
rfc: 10
title: 0010-darwinia-cross-chain-nft-bridge-protocol
status: Draft
desc: Cross-chain NFT Bridge Protocol
---


# Cross-chain NFT Bridge Protocol			

###  v 0.2.2



## I. 概述

基于XClaim的框架给通证跨链提供了一个思路，但是对于NFT仍有很多问题，其中主要包括Backing Blockchain上 Vault抵押物设计的问题。通过在Backing Blockchain上引入chain-Relay合约可以有效的解决这个问题，本文将基于这个改进的跨链转接桥方案，设计跨链NFT的方案和标准。

**关键词**：Blockchain, NFT, cross chain, multi-chain



## II. 背景

### A. 研究历史

比特币[1]的出现，允许每个人只要拥有私钥，就可以不依赖任何信任地操作自己的资产。整个比特币系统，由一系列记录着自己前序区块hash的区块构成，共同维护着同一份去中心化的全球“账本”。

比特币的出现之后，紧接着的就是区块链的飞速发展，出现了支持智能合约的公链——以太坊[2]，PoS的公链——EOS[3]等。这些公链的爆发，带来了整个token交易市场的繁荣。

主流的token交易/交换方式仍然是中心化交易所，用户的token由中心化交易所代为管理。信任和维护成本很高，并且还需要面临源源不断的黑客攻击的威胁。

为了克服中心化交易所的弊端，去中心化交易所 (DEX) 开始涌现。绝大部分去中心化交易所只支持在一条链上进行链内的token交易/转换，比如以太坊上的ERC20[4], ERC721 token[5]. 这一定程度上实现了去中心化，降低了信任成本（从相信机构变成了相信代码），但是使用场景十分有限，并且还要受限于公链的tps和交易费用。

当然也有一部分的去中心化交易所实现了ACCS，允许token跨链交换。它们使用了hashed timelock contracts (HTLCs)[6].  HTLCs的优点同它的缺点一样，都很明显。HTLCs可以在不需要信任的情况下实现跨链token的原子交换，这既实现了去中心化，又拓展了单条链上的DEX的功能。它的缺点就是成本太高，并且限制条件很多：(i) 所有参与方都必须保持全过程在线  (ii) 对粉尘交易失效  (iii) 通常锁定时间较长。这样的token跨链交换既昂贵又低效。在实际使用中，HTLCs的使用范例也非常少。

为了实现去信任的、低成本的、高效率的token跨链操作，XClaim团队提出了cross claim方案，基于CBA。并且在XClaim的论文中详述了XClaim是如何完成以下四种操作的：Issue, Transfer, Swap and Redeem.

 XClaim系统中保证经济安全的角色被称为 $vault$,  如果任何人想要把chain $B$ 上的原生token $b$ 跨到 chain $I$ 变成 $i(b)$ ，那么就需要 $vault$ 在chain $I$ 上超额抵押 $i$ 。 在赎回操作中，如果 $vault$ 存在恶意行为，则罚掉 $vault$ 抵押的 $i$ ，用于赎回操作发起者。其他细节详见XClaim的论文[7]。

至此，对于流动性较好的Fungible token的跨链，已经得到一个可靠的、可实现的方案。

### B. 尚未解决的问题

XClaim方案中有着一个基本假设，即跨链锁定的chain $B$ 的原生token $b$ 的总价值， 与在 $I$ 上发行出的 $i(b)$ 的总价值相等，在XClaim中被称为*symmetric*, 即 $ |b| = |i(b)|$。这样的假设是的XClaim在NFT的跨链中存在着天然的困境：

- NFT的不可替代性。正因为NFT具有可识别性、不可替代性等特点，使得 $vault$ 在 chain $I$ 上抵押chain $B$ 上的 NFT $nft_b$ 成了一件不可能的事情。
- NFT的价值难以评估。在XClaim中，判断 $vault$ 的抵押是否足额/超额，是通过Oracle $O$ 实现的。这也存在一个潜在的假设：token $b$ 和 token $i$ 可以被正确地评估价值。基于目前繁荣的中心化和去中心化交易所，在提供了良好的流动性的情况下，是可以基本满足该潜在假设的。但是NFT交易所市场尚未成熟，即使中心化交易所也无法比较真实地反应市场对NFT的价格判断。NFT如何定价本身就是一个难题。
- NFT定价不具有连续性和可预测性。即使某个NFT在市场上有了一次成交记录，即有了一个价格，因为NFT被售出的频次远低于FT，即使在市场流动性非常好的情况下，该NFT下一次的成交价格既不连续，也不可预测。

### C. Solution Description

解决以上问题的NFT跨链方案有两种思路，一种是基于基于XClaim框架并保留桥质押机制的的NFT扩展，通过引入哈伯格机制来解决NFT定价问题，详细的解决方案见[RFC-0011: Using Harberger Tax to find price for XClaim Vault Collaterals](./0011-using-harberger-tax-to-find-price-for-xclaim-vault-collaterals.md). 但这个方案仍然无法很好的解决由于NFT价格变化太大，导致的质押物不足问题。

另一个思路是通过在Backing Blockchain引入chainRelay的方案，对背书的资产做更多的保护，使得不再需要质押机制，简称为[RFC-0012: XClaim using two chainRelay model](./0012-xclaim-using-two-chainrelay-model.md)，详细的介绍将不在本文进行详细介绍，本文将着重基于这个改进的跨链转接桥方案，设计一个跨链的NFT标准，并且在多链互跨的情况下，提出了更低成本、功能具备扩展性的跨链协议。

## III. Bridge Core - Chain Relay Hub

在两条公链中跨链转移token，需要在chain $I$ 维护 *chain relay* 的成本是很高的，例如以太坊上每笔交易需要gas。如果把两条公链之间的跨链行为扩展到任意 $n$ 公链的话，那么每条链上都需要单独维护 $n-1$ 个 iSC，总共将需要$C_n^2$个chain relay合约。为了降低系统的维护成本，考虑在基于substrate的平行链上实现跨链的核心功能。

#### B. *Chain Relay Hub* 架构

那么整个系统的架构如下：

![chain-relay-framework](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8rjjzvj30kb0bfgmc.jpg)

图中 **Bridge Core** 即为基于Substrate 的 parachain；**vSC** 为 **Bridge Core** 的对应链的资产的发行模块。和以前的跨链方案不同的是，在上图的架构中，所有链的token需要先跨入**Bridge Core**, 而后在 **Bridge Core** 内部转换到目的公链对应的iSC 中，最后再在对应公链上发行对应的资产，整个跨链操作即完成。



### C. 组件定义

- *Issuing Smart Contract*,  $iSC_N$:  表示在 chain *N* 上的资产发行合约；
- *Backing Smart Contract*,  $bSC_N$ : 表示在 chain $N$ 上的资产锁定合约；
- *Verifying Smart Contract*,  $vSC_N$ : 表示在Bridge Core上负责验证 chain *N* 上交易的资产发行合约/模块；
- *NFT identifier*,  $nft_B^{x,n}$,  表示在chain $B$ 上，在合约 $x$ 中标识为 $n$ 的NFT
  - *NFT identifier in Bridge Core*, $nft_{BC}^{B, n}$ ，表示在Bridge Core，并且和 chain $B$ 上的 $nft_B^{x,n}$ 互为镜像
- *NFT identifier*,  $nft_I^{x',n'}$,  表示跨链后在chain $I$ 上新增发的、在合约 $x'$ 中标识为 $n'$ 的NFT
  - *NFT identifier in Bridge Core*, $nft_{BC}^{I, n'}$ ，表示在Bridge Core，并且和 chain $I$ 上的 $nft_I^{x',n'}$ 互为镜像
- *Locking Transaction* ,  $T_{B}^{lock}$,  在 chain *B* 上把 NFT 锁定在 $bSC_B$ 中的交易
- *Redeem Transaction* ,  $T_I^{redeem}$， 在chain *I* 上把 NFT 锁定在 $bSC_I$ 中的交易
- *Extrinsic Issue*,  $EX_{issue}$ , Bridge Core上的 issue 的交易 
- *Extrinsic redeem*,  $EX_{redeem}$ , Bridge Core上的 redeem 的交易 
- *Global NFT identifier*,  $GID$

参与方：

- *validator*,  维护 Bridge Core 的参与方；

### D. 初步实现方案

场景同章节II中的描述。依然需要实现三种 protocol：*Issue, Transfer, Redeem*. 同样为了简化模型，这里将不会讨论手续费相关细节。

#### Protocol: Issue

(i) ***锁定***。*requester* 将 chain $B$上的NFT资产 $nft_B^{n,x}$ 锁定在 $bSC_B$ 中，同时声明目的地公链 chain *I* 以及自己在chain $I$ 上的地址；这一步将产生交易$T_B^{lock}$

(ii) ***Bridge Core上发行***。 *requester*  将锁定交易 $T_B^{lock}$ 提交至 Bridge Core, 对应的chain relay验证通过后，即 触发 $vSC_B$ , 在 $vSC_B$ 中：

- 产生新的$GID$ 和 $nft_{BC}^{B,n}$ , 记录 $GID$ 和 $nft_{BC}^{B,n}$ 二者之间的关系，
- 并触发$vSC_I$ 

在 $vSC_I$ 中：

-  销毁  $nft_{BC}^{B,n}$，发行 $nft_{BC}^{I,?}$， $issue\_{ex}(\ GID,\ address\_on\_I) \rightarrow EX_{issue}$

(iii) ***发行***。*requester* 将 $EX_{issue}$ 提交至 chain $I$ , 经过chain $I$ 上的chain relay 验证通过后，即会在$iSC_I$ 中增发新的NFT: $nft_I^{x', n'}$， 并记录 $GID$ 和 $nft_I^{x', n'}$的关系， 且将所有权交给 *requester* 在chain *I* 上的地址

#### Protocol: Transfer

(i) ***转移***。*sender* 在 $I$ 上把 $nft_I^{x',n'}$ 在  $iSC_I$ 中，把所有权转移给 *receiver*，参考ERC721.

(ii) ***见证***。当 $nft_I^{x',n'}$ 在  $iSC_I$ 中的所有权发生了转移时，$iSC_I$ 和 $bSC_I$ 都应当觉察。此时，当 *sender* 再想把 $nft_I^{x',n'}$ 赎回时需要先将其锁定在 $bSC_I$ 中，此时 $bSC_I$ 将不会允许该操作成功。

#### Protocol: Redeem

(i) ***锁定***。 *redeemer* 将 chain $I$ 上的NFT资产 $nft_I^{x', n'}$ 锁定在 $bSC_I$ 后 (如果有对应的GID，锁定时需声明 $GID$)，同时声明目的地公链chain $B$ 以及自己在 chain $B$ 上的地址；$bSC_I$ 会原子地 在 $iSC_I$ 中确认 $GUID$ 的正确性。这一步将产生交易$T_I^{redeem}$。$lock\_I(nft\_id\_on\_I,\ GID,\ address\_on\_B) \rightarrow T_I^{redeem}$ 

(ii) ***Bridge Core上解锁***。 *redeemer* 将 $T_I^{redeem}$ 提交至 $vSC_I$ 并在chain relay中验证通过后，会在 $vSC_I$ 中：

- 记录 $GUID$ 和 $nft_I^{x', n'}$ 的对应关系，
- 判断目的地公链并触发相应的 $vSC_B$ ,

在 $vSC_B$ 中, 

- 通过 $GID$检索，销毁 $nft_{BC}^{I,n'}$ ，产生 $nft_{BC}^{B, n}$ ，$ redeem\_ex(\ GID,\ nft\_id\_on\_B,\ address\_on\_I) \rightarrow EX_{issue}$

以上过程均在一次Extrinsic内触发，将会产生一笔Extrinsic id，记录为 $EX_{redeem}$

(iii) ***解锁***。 *redeemer* 将 $EX_{redeem}$ 提交给 chain $B$ ， 经过$iSC_B$ 验证通过后，在 $iSC_B$ 中会记录 $GUID$ 和 $nft_B^{x,n}$ 的对应关系， 同时会原子地触发 $bSC_B$ 中的方法，将 $nft_B^{x,n}$ 还给指定的地址。 



### E. Implementation

#### E-I. Specification

##### Protocol: Issue

![image-20191010113808729](https://tva1.sinaimg.cn/large/006y8mN6gy1g7sznio88rj30uc0j0aca.jpg)

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

![image-20191010114326817](https://tva1.sinaimg.cn/large/006y8mN6gy1g7sznhfdu6j314w0q0n0c.jpg)

解释：

###### *redeemer* 相关操作：

- **burn**( $nft_I^{x',n'}$, $GID$, $pk_B^{redeemer}$ ) : 发生在 chain $I$ 上。 *redeemer* 触发$bSC_I$ 的方法，将 $nft_I^{x',n'}$ 销毁，但保留销毁记录，$bSC_I$ 可以原子地检验 $GID$ 和 $nft_I^{x',n'}$ 对应关系。该操作将会产生交易 $T_I^{redeem}$ 
- **verifyIOp**(burn,  $T_I^{redeem}$,  $\Delta_{redeem}$) : 发生在 Bridge Core内。用户将 $T_I^{redeem}$ 提交至 $vSC_I$ 中，如果 $T_I^{redeem}$ 真实地在 chain $I$ 上发生过并且满足最小需要延时 $\Delta_{redeem}$，即会根据 $GID$ 找到 对应的 $nft_{BC}^{I,?}$ 并根据自动补全成 $nft_{BC}^{I,n'}$ 
- **verifyBCOp**(trigger, $EX_{redeem}$, $\Delta_{trigger}$) $\rightarrow T$ :  发生在 chain $B$ 内。*redeemer* 将 $EX_{redeem}$ 提交至chain $B$ 的 $iSC_B$ 内，如果$iSC_B$ 验证 $EX_{redeem}$ 的真实性即返回T，否则返回F。验证通过后，即通过调用issue方法，即释放 $nft_B^{x,n}$ 到 *redeemer* 在 chain $B$ 的地址上。

###### *validator* 相关操作：

- **burnTransform**($vSC_B,\ GID,\ nft_{BC}^{x,n},\ pk_B^{redeemer}$ ): *validator* 自动触发 $vSC_B$ 中的方法， 将 $nft_{BC}^{I,n'}$ 销毁同时产生 $nft_{BC}^{B,n}$, 表示在chain $B$ 上即将释放的nft的镜像。这次操作将产生 $EX_{redeem}$.



### F. NFT in Bridge Core

NFT跨链操作的难点在于，不同的公链有着自己的NFT标准，甚至不同公链上的NFT的token id连长度都是不相等的，NFT在跨到不同公链时，必然会经历token id的转换。如何在跨链的过程中不丢失NFT的可识别性，是一个值得研究的命题。

在设计Bridge Core内的NFT流转逻辑时，我们想解决以下三个问题：

- 保留NFT的跨链流转路径/历史，不损失NFT的可识别性；
- 计算和验证解耦，拥有更高的处理速度；
- 实现额外功能，例如NFT在跨链的同时完成分解、合并等操作；

为此，我们选择使用扩展的UTXO模型作为存储/状态 的流转单元，在这里我们称它为UNFO (Unspent Non-Fungible token Output).

在 Bridge Core 内的 中间状态的NFT在上文中被标记为 $nft_{BC}^{X,n}$ ，表示在对应 chain $X$ 中有一个即将被发行/已锁定的 NFT. 

在 Bridge Core 内这些 中间态的NFT被标记为 UNFO (Unspent Non-Fungible Output). 该想法源于UTXO，当一个UNFO被销毁时，意味着同时会产生一个新的UNFO.

#### F-I. UNFO structure

UNFO的结构：

```rust
struct UNFO {
  pub local_id, // chain_id + smart_cotnract_id + token_id
  pub global_id,
  pub phase, // current phase
  pub lock_script, // e.g. ownership or state management
}
```

- **local_id**：表示该UNFO对应着某个外部区块链 *chain_id* 上某个 *smart_contract_id* 里的 *token_id*
- **global_id**：表示该UNFO在Bridge Core和所有被夸的区块链范围内的全局唯一标识
- **phase**：表示该UNFO在跨链过程中所处的阶段。比如：
  - 1: 该UNFO对应区块链 *chain_id* 上的NFT被锁定/销毁；跨链过程处于中间状态；
  - 2: 该UNFO对应区块链 *chain_id* 上的NFT待发行/已发行；跨链过程即将完成/已完成
- **lock_script**：用于更加复杂逻辑、细粒度的控制脚本，保持UNFO的可扩展性



#### F-II. UNFO的转换

当一个UNFO的销毁，意味着另一个UNFO的创建，如果我们追溯UNFO的销毁创造历史，就可以回溯某个NFT的全部跨链历史，这一定程度上帮助实现了NFT的可识别性；

每个UNFO只能被销毁一次，这使得计算前不一定要先验证，从而提高了处理速度；

正如比特币的UTXO一样，Input和Output都可以有多个，这样的特点使得NFT在跨链的过程中，可以同时完成一些扩展功能，例如NFT的拆分和合并。

一直一来，NFT都比FT有用更多的操作种类，例如在游戏中，作为道具的NFT要求可拆解、可合成、可升级等，为此扩展出了很多NFT标准，例如ERC721, ERC1155, ERC721X等。标准越多，越难被广泛使用。

如果其中的一些通用需求可以在跨链同时实现，可以有效地减少标准的数量和冗余度，一定程度上更有利于实现一个统一的标准。



当一个UNFO产生时，一定要满足：

- 提供 *backing blockchain* 的 对应NFT 的锁定记录；
- 另一个UNFO被销毁
  - 条件：销毁和产生的UNFO的GID必须相同

![0010-UNFO-transform](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8skd28j30hj06z0sz.jpg)





### F-III. Bridge Core 内部结构



![0010-framework-of-bridge-core](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8qjwd9j30fe0gh3zg.jpg)





### F-IV. Protocols with UNFO

##### Protocol: Issue

![chain-relay-framework (https://tva1.sinaimg.cn/large/006y8mN6gy1g7sznhszi8j30pz0elabd.jpg)](/Users/hammer/Downloads/chain-relay-framework (1).jpg)



##### Protocol: Redeem

![chain-relay-framework (https://tva1.sinaimg.cn/large/006y8mN6gy1g7szni9t0lj30r70elgn2.jpg)](/Users/hammer/Downloads/chain-relay-framework (2).jpg)



## 

## IV. Cross-chain NFT Standards

为了方便的标记一个物品或者一个资产，我们会用一个唯一的标识来标记它，不同的物品具有不同的标识。我们先拿物理空间里面的物品举例，在理想情况下，所有的物品都应该在同一个时空里面，这样大家都能观察的到，并且方便做区分和标识。但是现实情况是，不同的物品可能存在于不同的时空里面，并且观察者也不一定能看到每一个物品。同样的情况，在虚拟资产世界，因为存在不同的账本或称区块链网络(简称域)，不同的物品在同一个域里面因为有不同的标识，可以容易的区分和定位，但是该域里面的观察者无法识别和解析来自外部域的物品标识。

目前现有的很多通证标准的设计，都主要是针对域内资产进行标识设计，没有将不同域内的资产复用考虑进来，这样导致在对非同质资产进行复用时，单独的Token ID无法标识唯一的资产，还需要带上很多域信息，实现起来十分复杂。

跨链技术可以极大的帮助通证在更广泛的区块链网络中实现互联互通，但是同时，也给开发者和用户带来了一些认知和使用门槛，其中就包括通证可识别性的问题。

因为目前的通证标准，例如ERC20或ERC721，只记录的其在某个特定链上的所有权信息，没有考虑到通证有可能会分布在两个区块链网络。当通证同时分布在两个区块链网络时，我们需要一套识别和解析系统帮助用户和通证应用来解析和查询当前的通证状态。当我们给出一个NFT的Token ID时，我们无法确定它目前所在区块链网络是哪个，其所有者是谁，因为当NFT发生跨链转移后，在其中一个区块链网络上该通证处于活跃状态，而其他则处于不可用状态，比如锁定状态。在没有通证解析系统的情况下，链外操作无法确定该NFT在哪条链上时处于活跃状态。

跨链环境下，Token面临的识别性和解析问题，需要新的解决方案和标准来解决。因此我们引入一个基于通证跨链证明的解析系统来解决通证跨链时的定位和解析需求，通过通证解析系统和域内唯一标识，我们可以存在与不同域的通证之间的关联关系映射起来，并标识他们之间的相同与不同。



### A. 全局唯一标识

为了将不同标准的通证标识符进行规范化，以提供识别和解析方法，与现有的标准进行很好的协调和对接，并满足社区基础设施建设的标准需求。（To harmonise existing practice in identifier assignment and resolution, to support resources in implementing community standards and to promote the creation of identifier services.) 跨链系统将为每一个跨链后的通证分配一个全局ID(global_id)，

### B. 本地通证解析方式

通证解析模块是NFT cross-chain协议内嵌的一个模块，用于在 *Issuing chain* 或者其连接的中继链上记录和解析当前通证在中继链范围内的全局状态，并规范化处理成解析格式的方式，来为跨链网络提供通证解析查询和证明服务。

在UNFO里，会标识进入Bridge Core之前，原生NFT的chainId和token id, 分别放在 type 和 value 里；lock表达的是这个NFT的所有者是谁，当该NFT在Bridge Core之内流转时，该lock_script指向的可能是某个ownership contract，当NFT被锁定在backing contract里面时，lock_script指向的可能是backing contract的redeem合约。

![image-20191008134135795](/Users/denny/Library/Application Support/typora-user-images/image-20191008134135795.png)

[TODO: Remove GUID in this ownership contract]



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

