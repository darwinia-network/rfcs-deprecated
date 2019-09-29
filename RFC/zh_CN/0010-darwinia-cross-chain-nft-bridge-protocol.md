---
rfc: 10
title: 0010-darwinia-cross-chain-nft-bridge-protocol
status: Draft
desc: Cross-chain NFT Bridge Protocol
---


# Cross-chain NFT Bridge Protocol			

###  v 0.2.0



## 0. 概述

对于不同区块链上的token交换，目前虽然中心化交易所可以帮助执行，但是这样的服务需要高度的信任，且易发生主动作恶、单点故障等问题。随着Cosmos、Polkadot这样一批优秀的跨链项目的落地，架构在跨链基础设施之上的去中心化token流通协议/方案也成为重要的研究内容。

在已有的方案中，atomic cross-chain swaps (ACCS) 是最早提出的可行性方案，但由于其跨链效率低、成本高，实际使用场景并不多。随后，XClaim (Cross Claim) 针对 ACCS 的缺点，提出了通用的、高效低成本的跨链框架，使用了Cryptocurrency-Bakced Assets (CBAs). 

XClaim 虽然某种程度上解决了 ACCS 的缺点，但是也存在其自身的局限性：只针对Fungible Token有效，并且。目前针对NFT的跨链流通还没有通用框架。本文提出了基于XClaim的适用NFT跨链的扩展协议（以双链互跨为例），并且在多链互跨的情况下，提出了更低成本、功能根据扩展性的跨链协议。

**关键词**：Blockchain, NFT, cross chain, multi-chain



## I. 背景

### A. 研究历史

比特币[1]的出现，允许每个人只要拥有私钥，就可以不依赖任何信任地操作自己的资产。整个比特币系统，由一系列记录着自己前序区块hash的区块构成，共同维护着同一份去中心化的全球“账本”。

比特币的出现之后，紧接着的就是区块链的飞速发展，出现了支持智能合约的公链——以太坊[2]，PoS的公链——EOS[3]等。这些公链的爆发，带来了整个token交易市场的繁荣。

主流的token交易/交换方式仍然是中心化交易所，用户的token由中心化交易所代为管理。信任和维护成本很高，并且还需要面临源源不断的黑客攻击的威胁。

为了克服中心化交易所的弊端，去中心化交易所 (DEX) 开始涌现。绝大部分去中心化交易所只支持在一条链上进行链内的token交易/转换，比如以太坊上的ERC20[4], ERC721 token[5]. 这一定程度上实现了去中心化，降低了信任成本（从相信机构变成了相信代码），但是使用场景十分有限，并且还要受限于公链的tps和交易费用。

当然也有一部分的去中心化交易所实现了ACCS，允许token跨链交换。它们使用了hashed timelock contracts (HTLCs)[6].  HTLCs的优点同它的缺点一样，都很明显。HTLCs可以在不需要信任的情况下实现跨链token的原子交换，这既实现了去中心化，又拓展了单条链上的DEX的功能。它的缺点就是成本太高，并且限制条件很多：(i) 所有参与方都必须保持全过程在线  (ii) 对粉尘交易失效  (iii) 通常锁定时间较长。这样的token跨链交换既昂贵又低效。在实际使用中，HTLCs的使用范例也非常少。

为了实现去信任的、低成本的、高效率的token跨链操作，XClaim团队提出了cross claim方案，基于CBA。并且在XClaim的论文中详述了XClaim是如何完成以下四种操作的：Issue, Transfer, Swap and Redeem.

 XClaim系统中保证经济安全的角色被称为 $vault$,  如果任何人想要把chain $B$ 上的原生token $b$ 跨到 chain $I$ 变成 $i(b)$ ，那么就需要 $vault$ 在chain $I$ 上超额抵押 $i$ 。 在以上四种操作中，如果 $vault$ 存在恶意行为，则罚掉 $vault$ 抵押的 $i$ ，用于补偿跨链发起者。其他细节详见XClaim的论文[7]。

至此，对于Fungible token的跨链，已经得到一个可靠的、可实现的方案。

### B. 尚未解决的问题

XClaim方案中有着一个基本假设，即跨链锁定的chain $B$ 的原生token $b$ 的总价值， 与在 $I$ 上发行出的 $i(b)$ 的总价值相等，在XClaim中被称为*symmetric*, 即 $ |b| = |i(b)|$。这样的假设是的XClaim在NFT的跨链中存在着天然的困境：

- NFT的不可替代性。正因为NFT具有可识别性、不可替代性等特点，使得 $vault$ 在 chain $I$ 上抵押chain $B$ 上的 NFT $nft_b$ 成了一件不可能的事情。
- NFT的价值难以评估。在XClaim中，判断 $vault$ 的抵押是否足额/超额，是通过Oracle $O$ 实现的。这也存在一个潜在的假设：token $b$ 和 token $i$ 可以被正确地评估价值。基于目前繁荣的中心化和去中心化交易所，在提供了良好的流动性的情况下，是可以基本满足该潜在假设的。但是NFT交易所市场尚未成熟，即使中心化交易所也无法比较真实地反应市场对NFT的价格判断。NFT如何定价本身就是一个难题。
- NFT定价不具有连续性和可预测性。即使某个NFT在市场上有了一次成交记录，即有了一个价格，因为NFT被售出的频次远低于FT，即使在市场流动性非常好的情况下，该NFT下一次的成交价格既不连续，也不可预测。

### C. Solution Description

解决以上问题的NFT跨链方案有两种思路，一种是基于基于XClaim框架并保留桥质押机制的的NFT扩展，通过引入哈伯格机制来解决NFT定价问题，详细的解决方案见[RFC-0011](./0011-darwinia-xclaim-based-nft-solution-using-harberger-tax.md). 但这个方案仍然无法很好的解决由于NFT价格变化太大，导致的质押物不足问题。

另一个思路是通过在Backing Blockchain映入chainRelay的方案，对背书的资产做更多的保护，使得质押成本降低，简称为 *Non-vault* NFT multi-chain operations protocol.



## II. *Non-vault* NFT multi-chain operations protocol

本章节将展示NFT multi-chain operations protocol的设计思路和过程实现。在章节II中，XClaimed-based跨链方案已经可以保证了在大部分场合下的NFT的跨链安全操作，但是依然无法保证当NFT价格产生剧烈波动时，整个系统的鲁棒性和可持续性。

所以我们引入了完全无 $vault$ 的跨链方案，通过引入技术安全性：

- ***bSC + iSC***: 在章节II中，对chain $B$ 没有任何额外的要求，导致在 chain $B$ 上的安全只能由在 chain $I$ 上抵押 $i\_col$ 的 $vault$ 来提供。在III-A中将详述对 chain $B$ 引入的新的假设约束。一旦 chain $B$ 上的资产安全可以非互操作性地实现，将降低对 $vault$ 的依赖。

- ***multi chain relay***: *chain relay* 可以提供区块链的区块和交易证明，它在XClaim扩展方案中，也被应用来减低对 $vault$ 的信任依赖。在章节III-B中，将介绍 *multi chain relay* 如何在保证安全的基础上，进一步地减少对 $vault$ 的依赖。

### A. 区块链模型假设

在目前已经上线的区块链项目中，几乎没有NFT作为链的原生资产的，所有的NFT几乎都是在智能合约内实现的。因此，对原生资产所在的chain $B$, 可以引入全新且合理的假设：

- *backing blockchain* 和 *Issuing blockchain*:  都支持图灵完备的智能合约

这样我们就可以通过在 $B$ 和 $I$ 上放置独立的智能合约 bSC 和 iSC 来提供更强的技术约束，保证跨链的安全性。

### B. Chain Relay

#### B-I. 什么是 *chain relay*

XClaim 给出了对 *chain relay* [7]的定义：

> Chain relays: Cross-Chain State Verification. It is capable of interpreting the statte of the backing blockchain B and provide functionality comparable to an SPV or light client[10].

因此，*chain relay* 可以被认为是由包含root of merkle tree的区块头组成。它为 iSC 提供了两种功能： *交易存在证明* 以及 *共识证明*。

- ***交易存在证明***： *chain relay* 存储着区块链的每一个区块头，以及区块头里的root of merkle tree. 在提供merkle tree路径的情况下，这已经足够可以证明一笔交易是否存在于这条链的某个区块中。
- ***共识证明***： 以比特币为例，因为每个节点通常不能即时看到全网的情况，因此经常会发生产生孤块，又在重组中被丢弃的情况。为了避免这种情况带来的攻击/漏洞，*chain relay* 必须要验证给定的区块头是否为完整区块链的一部分，例如被大部分节点认可。对于共识为Proof-of-Work的区块链，*chain relay* 必须：(i) 知道挖矿难度调整策略  (ii) 验证收到的区块头是否在具有最多累计工作量证明的链上。 对于共识为Proof-of-Stake的区块链，*chain relay* 必须：(i) 知道协议要求/staking的阶段，例如epoch  (ii) 验证区块头中验证人签名数量是否满足区块的阈值要求。 

![image-20190918192745871](https://tva1.sinaimg.cn/large/006y8mN6gy1g74nx67ss8j30m60gc76z.jpg)

​																						（图片来自XClaim，待更新 ）

#### B-II.  *chain relay* 如何去信任

这里以章节II中的 *Protocol Issue* 为例，当 *requester* 把 $nft_b^n$ 锁定在 $vault$ 时，会产生一笔交易: $lock(vault_address, lock_amount) -> T_l$ ，随后 *requester* 会向 *chain relay* 提交这笔交易$T_l$ ，之后 *chain relay* 会检验 $T_l$ 确实是存在于给定区块的交易中，这个区块也存在于最长链中，那么就证明token已经被安全地锁定了。如果验证通过，会原子地触发 iSC 中的资产发行操作。



#### B-III. *multi chain relay* 架构

在两条公链中跨链转移token，s需要在chain $I$ 维护 *chain relay* 的成本是很高的，例如以太坊上每笔交易需要gas。如果把两条公链之间的跨链行为扩展到任意 $n$ 公链的话，那么每条链上都需要单独维护 $n-1$ 个 iSC，成本将成指数级增长。为了降低系统的维护成本，考虑在基于substrate的平行链上实现跨链的核心功能。

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

- *witness*,  维护 Bridge Core 的参与方；

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



### F. Implementation

#### E-I. Specification

##### Protocol: Issue

![image-20190927184316820](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8t97jjj318k0jidig.jpg)

解释：

###### *requester* 相关的操作：

- **lockB**($nft_B^{x,n}$, cond):   发生在chain $B$ 内。将$nft_B^{x,n}$ 锁定在 $bSC_B$ 中，并声明 *requester* 在 chain $I$ 上的地址，这个操作对应交易 $T_B^{lock}$

- **verifyBOp**(lockB, $T_B^{lock}$, $\Delta_{lock}$) $\rightarrow T$ :    发生在Bridge Core内。*requester*将 $T_B^{lock}$ 提交至 Bridge Core中的 $vSC_B$ 进行验证，如果 $T_B^{lock}$ 真实地在 chain $B$ 上发生过并且满足最小需要延时 $\Delta_{lock}$，即返回结果T(True)，否则返回F(False).  

  如果结果为T，则在 $vSC_B$ 中自动触发 newGid($nft_B^{x,n}$)，会产生新的GID，以及 $nft_B^{x,n}$ 在 Bridge Core内的镜像 $nft_{BC}^{B,n}$ 

- **verifyBCOp**(trigger, $EX_{issue}$, $\Delta_{trigger}$) $\rightarrow T$ :  发生在 chain $I$ 内。*requester* 将 $EX_{issue}$ 提交至chain $I$ 的 $iSC_I$ 内，如果$iSC_I$ 验证 $EX_{issue}$ 的真实性即返回T，否则返回F。验证通过后，即通过调用issue方法，发行 $nft_I^{x',n'}$ 到 *requester* 在 chain $I$ 的地址上。

###### *witness* 相关操作：

- **trigger**($vSC_I,\ pk_I^{requester},\ GID$ ): *witness* 触发 $vSC_I$ 中的方法， 将 $nft_{BC}^{B,n}$ 销毁并产生 $nft_{BC}^{I,?}$, 表示在chain $I$ 上即将新增发的nft的镜像（这里之所以用$?$ 因为此时chain $I$ 上的nft还未被增发，因此无法获取其token id）。这次操作将产生 $EX_{issue}$.



##### Protocol: Transfer

![image-20190927191635665](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8pswk9j3120050aac.jpg)

解释：

在 chain $I$ 上 *sender* 调用 $iSC_I$ 中的 transfer方法，将 $nft_I^{x',n'}$ 发送给 *receiver*



##### Protocol: Redeem

![image-20190927192023177](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8s2dq8j30ze0hqmzn.jpg)

解释：

###### *redeemer* 相关操作：

- **lockI**( $nft_I^{x',n'}$, $GID$, $pk_B^{redeemer}$ ) : 发生在 chain $I$ 上。 *redeemer* 将 $nft_I^{x',n'}$ 锁定在 $bSC_I$ 中，$bSC_I$ 可以原子地检验 $GID$ 和 $nft_I^{x',n'}$ 对应关系。该操作将会产生交易 $T_I^{redeemer}$
- **verifyIOp**(lockI, $T_I^{redeemer}$, $\Delta_{redeem}$) : 发生在 Bridge Core内。用户将 $T_I^{redeem}$ 提交至 $vSC_I$ 中，如果 $T_I^{redeem}$ 真实地在 chain $I$ 上发生过并且满足最小需要延时 $\Delta_{redeem}$，即会根据 $GID$ 找到 对应的 $nft_{BC}^{I,?}$ 并根据自动补全成 $nft_{BC}^{I,n'}$ 
- **verifyBCOp**(trigger, $EX_{redeem}$, $\Delta_{trigger}$) $\rightarrow T$ :  发生在 chain $B$ 内。*redeemer* 将 $EX_{redeem}$ 提交至chain $B$ 的 $iSC_B$ 内，如果$iSC_B$ 验证 $EX_{redeem}$ 的真实性即返回T，否则返回F。验证通过后，即通过调用issue方法，即释放 $nft_B^{x,n}$ 到 *redeemer* 在 chain $B$ 的地址上。

###### *witness* 相关操作：

- **trigger**($vSC_B,\ GID,\ nft_{BC}^{x,n},\ pk_B^{redeemer}$ ): *witness* 触发 $vSC_B$ 中的方法， 将 $nft_{BC}^{I,n'}$ 转换成 $nft_{BC}^{B,n}$, 表示在chain $B$ 上即将释放的nft的镜像。这次操作将产生 $EX_{redeem}$.



#### E-II. UNFO 

在 Bridge Core 内的 中间状态的NFT在上文中被标记为 $nft_{BC}^{X,n}$ ，表示在对应 chain $X$ 中有一个即将被发行/已锁定的 NFT. 

在 Bridge Core 内这些 中间态的NFT被标记为 UNFO (Unspent Non-Fungible Output). 该想法源于UTXO，当一个UNFO被销毁时，意味着同时会产生一个新的UNFO.



UNFO的结构：

```rust
struct UNFO {
  pub local_id, // chain_id + smart_cotnract_id + token_id
  pub global_id,
  pub lock_script, // e.g. to check if it is locked or unlocked
}
```

当一个UNFO产生时，一定要满足：

- 提供 *backing blockchain* 的 对应NFT 的锁定记录；
- 另一个UNFO被销毁
  -  条件：销毁和产生的UNFO的GID必须相同

![0010-UNFO-transform](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8skd28j30hj06z0sz.jpg)





#### E-II. Bridge Core 内部结构



![0010-framework-of-bridge-core](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8qjwd9j30fe0gh3zg.jpg)



#### E-III. Protocols with UNFO

##### Protocol: Issue

![0010-multi-chain-relay-issue](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8q3raej30pz0eljsj.jpg)



##### Protocol: Redeem

![0010-multi-chain-relay-redeem](https://tva1.sinaimg.cn/large/006y8mN6ly1g7fe8r31plj30r70elabi.jpg)

### F. Open Concern: NFT Specific Design and Standards

NFT跨链操作的难点在于，不同的公链有着自己的NFT标准，甚至不同公链上的NFT的token id连长度都是不相等的，NFT在跨到不同公链时，必然会经历token id的转换。如何在跨链的过程中不丢失NFT的可识别性，是一个值得研究的命题。

[WIP](https://github.com/darwinia-network/rfcs/blob/master/RFC/zh_CN/0011-darwinia-cross-chain-nft-design-and-standards.md)


## III. Cross-chain NFT Design想要解决的问题

在设计Bridge Core内的NFT流转逻辑时，我们想解决以下三个问题：

- 保留NFT的跨链流转路径/历史，不损失NFT的可识别性；
- 计算和验证解耦，拥有更高的处理速度；
- 实现额外功能，例如NFT在跨链的同时完成分解、合并等操作；

为此，我们选择使用扩展的UTXO模型作为存储/状态 的流转单元，在这里我们称它为UNFO (Unspent Non-Fungible token Output).



### A. UNFO Design

我们将UNFO设计成更加通用的UTXO，其结构如下：

```rust
pub struct UNFO {
    pub type: chainId,
    pub value: Vec<u8>, // token id on chainId
    pub lock: Script, // condition
}
```

在UNFO里，会标识进入Bridge Core之前，原生NFT的chainId和token id, 分别放在 type 和 value 里；lock表达的是这个NFT的所有者是谁，即使得lock脚本执行成功的人；而cond_script里放着UNFO转换的一些条件限制，例如某个NFT在同一个chainID上不允许有两个不同的token id， 可以理解成智能合约。

这样，当一个UNFO的销毁，意味着另一个UNFO的创建，如果我们追溯UNFO的销毁创造历史，就可以回溯某个NFT的全部跨链历史，这一定程度上帮助实现了NFT的可识别性；

每个UNFO只能被销毁一次，这使得计算前不一定要先验证，从而提高了处理速度；

正如比特币的UTXO一样，Input和Output都可以有多个，这样的特点使得NFT在跨链的过程中，可以同时完成一些扩展功能，例如NFT的拆分和合并。

一直一来，NFT都比FT有用更多的操作种类，例如在游戏中，作为道具的NFT要求可拆解、可合成、可升级等，为此扩展出了很多NFT标准，例如ERC721, ERC1155, ERC721X等。标准越多，越难被广泛使用。

如果其中的一些通用需求可以在跨链同时实现，可以有效地减少标准的数量和冗余度，一定程度上更有利于实现一个统一的标准。



### B. 兼容其他跨链设施

因为NFT对可识别性的高要求，使得在跨链时，使用不同跨链设施可能会造成意想不到的后果。而Fungible Token则只要保证价值对称、资产安全即可。

可以想象以下场景：

> nft(A, X, 1) 表示在A链上、合约X中标识为1的NFT

Alice在跨链桥M中，将nft(A, X, 1) 变为 nft(B, Y, 2) ；又通过跨链桥N，将nft(B, Y, 2) 变为 nft(C, Z, 3)。之后，当Alice想继续使用跨链桥M将C链上的nft 跨链去 A链的话，跨链桥M会将 nft(C, Z, 3) 识别为新的token，很可能在跨回A链时，将不再是nft(A, X, 1)，而是nft(A, X, 5). NFT就丢失了自己的可识别性，或者是用户就丢失了自己的资产。

为了尽可能减少丢失NFT可识别性对用户造成的潜在资产损失，用户可以获取到Bridge Core上某个NFT当前的UNFO，之后，用户先使用其他跨链设施将NFT跨到UNFO中type记录的对应链之后，再使用Bridge Core 进行后续的跨链操作。

这样，至少在当前系统内，NFT可保证可识别性不被破坏。

在补充章节IV中，我们还将探索其他的兼容方案，例如NFT解析模块。



### C. 补充讨论： NFT解析模块

为了方便的标记一个物品或者一个资产，我们会用一个唯一的标识来标记它，不同的物品具有不同的标识。我们先拿物理空间里面的物品举例，在理想情况下，所有的物品都应该在同一个时空里面，这样大家都能观察的到，并且方便做区分和标识。但是现实情况是，不同的物品可能存在于不同的时空里面，并且观察者也不一定能看到每一个物品。同样的情况，在虚拟资产世界，因为存在不同的账本或称区块链网络(简称域)，不同的物品在同一个域里面因为有不同的标识，可以容易的区分和定位，但是该域里面的观察者无法识别和解析来自外部域的物品标识。

目前现有的很多通证标准的设计，都主要是针对域内资产进行标识设计，没有将不同域内的资产复用考虑进来，这样导致在对非同质资产进行复用时，单独的Token ID无法标识唯一的资产，还需要带上很多域信息，实现起来十分复杂。

跨链技术可以极大的帮助通证在更广泛的区块链网络中实现互联互通，但是同时，也给开发者和用户带来了一些认知和使用门槛，其中就包括通证可识别性的问题。

因为目前的通证标准，例如ERC20或ERC721，只记录的其在某个特定链上的所有权信息，没有考虑到通证有可能会分布在两个区块链网络。当通证同时分布在两个区块链网络时，我们需要一套识别和解析系统帮助用户和通证应用来解析和查询当前的通证状态。当我们给出一个NFT的Token ID时，我们无法确定它目前所在区块链网络是哪个，其所有者是谁，因为当NFT发生跨链转移后，在其中一个区块链网络上该通证处于活跃状态，而其他则处于不可用状态，比如锁定状态。在没有通证解析系统的情况下，链外操作无法确定该NFT在哪条链上时处于活跃状态。

跨链环境下，Token面临的识别性和解析问题，需要新的解决方案和标准来解决。因此我们引入一个基于通证跨链证明的解析系统来解决通证跨链时的定位和解析需求，通过通证解析系统和域内唯一标识，我们可以存在与不同域的通证之间的关联关系映射起来，并标识他们之间的相同与不同。



### D. 设计思路

通证解析模块是NFT cross-chain协议内嵌的一个模块，用于在 *Issuing chain* 或者其连接的中继链上记录和解析当前通证在中继链范围内的全局状态，并规范化处理成解析格式的方式，来为跨链网络提供通证解析查询和证明服务。

#### 其他跨链共享数据

目前通证标准主要的设计是针对所有权信息进行记录，但是并没有对通证的跨链转账，使用权，类型，生产商等信息进行记录，使得通证合约对通证的描述并不全面，也没有提供可扩展的方法来增加其他的信息。

设计通证解析系统的一个额外好处是，因为可以把中继链看做一个共享的模块(共享存储和共享运行时SPREE)。我们引入Token解析合约(脚本)来记录和更新Token的协议、跨链、权利和其他信息。

对于Polkadot架构，可以通过接入SPREE模块，在解析合约内定义约束条件，例如全局的通证总量，发行规则，并部署至SPREE模块，可以实现中继网络管辖范围的验证和可信互操作。



### E. 通证解析查询消息规范

更多关于SPREE模块的介绍，参考 https://wiki.polkadot.network/en/latest/polkadot/learn/spree



### F. 通证跨链消息收集

当我们讨论跨链时，一般需要分成两种情况：

#### F-I. Cross parachain(同构区块链/平行链)

当在平行链之间进行跨链时，例如在Polkadot网络中，因为有共享安全，ICMP等设计，因此将通证解析系统放在中继链上时最合适的，因为通证跨平行链的消息会流经中继链，中继链可以通过在消息中继模块之外，嵌入一个收集模块，将通证跨链消息规范化统一收集之后，提供给通证解析服务。

#### F -II. Cross major chain (异构链，e.g Ethereum <--> Bitocin, Ethereum <-->TRON, Ethereum <--> Polkadot)

在这种跨链模式下，通证跨链一般通过跨链转接桥的方案进行跨链，例如ACCS(HTLCs), XClaim, Parity Bridge(Mainet/Sidechain)。跨链消息及相关证明并未流经通证解析服务所在的中继链，而是通过设计收集人激励机制，通过收集人主动收集这些通证跨链证明。从这个角度上将，通证解析服务的链设计成中继链没有优势。

但是通证解析系统设计在中继链的一个[可能的好处](https://github.com/darwinia-network/rfcs/issues/15)是，可以在跨链消息收集协议规范化之后，外部的通证跨链转接桥协议可以通过嵌入通证解析系统收集协议的方式，支持通证解析系统，以达到更好的可靠性和完整性和解析性。

##### F-III. 异构链跨链转接桥解决方案XClaim的集成

对于基于XClaim技术搭建的跨链转接桥，其Token的跨链是通过在对手链上构建超额抵押的对称CBA来实现的。虽然严格意义上讲，CBA不等同于原通证，但是从用户视角看其效果非常接近。

[WIP]对于这类异构链之间跨链通证的支持仍有希望通过通证解析系统来描述和解析其跨链转接桥过程，只需跟中继链和平行链模式的跨链通证类型稍作区分，便可帮助开发者和用户理解其跨链通证(CBA)和原有通证的区别。

因为需要喂价机制，XClaim解决方案比较适合流动性好的同质Token，但对于价格发现低效的NFT来说，就[不那么友好](https://github.com/darwinia-network/rfcs/issues/16)了。

NFT的跨链转接桥方案目前缺乏相关的研究，比较务实的方案可能是由Token创建者指定信任账号作为跨链证明提交者，并结合质押以降低风险。这个方案带来一定程度中心化，但目前也没有更好的办法。



### G. 全局唯一标识

To harmonise existing practice in identifier assignment and resolution, to support resources in implementing community standards and to promote the creation of identifier services.

通证解析系统分配的TOKEN ID将可以作为该Token在跨链网络中的全局Token标识(Base Token ID)。

对于同质Token来说，因为没有通证的索引，只有数量的概念，解析通证ID可以作为全局通证ID。

对于非同质Token来说，将可以使用解析通证ID加上一个Token内索引得到的编码[解析通证ID+Token_Index]作为全局唯一标识。



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

