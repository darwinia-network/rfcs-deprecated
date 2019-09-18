

# NFT multi-chain operations protocol				

###                                                                                                                                                        v 0.1.0





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

当然也有一部分的去中心化交易所实现了ACCS，允许token跨链交换。它们使用了hashed timelock contracts (HTLCs)[6].  HTLCs的优点同它的缺点一样，都很明显。HTLCs可以在不需要信任的情况下实现跨链token的原子交换，这既实现了去中心化，又拓展了单条链上的DEX的功能。它的缺点就是成本太高，并且限制条件很多：(i) 所有参与方都必须保持全过程在线  (ii) 对粉尘交易失效[8]  (iii) 通常锁定时间较长。这样的token跨链交换既昂贵又低效。在实际使用中，HTLCs的使用范例也非常少。

为了实现去信任的、低成本的、高效率的token跨链操作，XClaim团队提出了cross claim方案，基于CBA。并且在XClaim的论文中详述了XClaim是如何完成以下四种操作的：Issue, Transfer, Swap and Redeem.

 XClaim系统中保证经济安全的角色被称为 $vault$,  如果任何人想要把chain $B$ 上的原生token $b$ 跨到 chain $I$ 变成 $i(b)$ ，那么就需要 $vault$ 在chain $I$ 上超额抵押 $i$ 。 在以上四种操作中，如果 $vault$ 存在恶意行为，则罚掉 $vault$ 抵押的 $i$ ，用于补偿跨链发起者。其他细节详见XClaim的论文[9]。

至此，对于Fungible token的跨链，已经得到一个可靠的、可实现的方案。

### B. 尚未解决的问题

XClaim方案中有着一个基本假设，即跨链锁定的chain $B$ 的原生token $b$ 的总价值， 与在 $I$ 上发行出的 $i(b)$ 的总价值相等，在XClaim中被称为*symmetric*, 即 $ |b| = |i(b)|$。这样的假设是的XClaim在NFT的跨链中存在着天然的困境：

- NFT的不可替代性。正因为NFT具有可识别性、不可替代性等特点，使得 $vault$ 在 chain $I$ 上抵押chain $B$ 上的 NFT $nft_b$ 成了一件不可能的事情。
- NFT的价值难以评估。在XClaim中，判断 $vault$ 的抵押是否足额/超额，是通过Oracle $O$ 实现的。这也存在一个潜在的假设：token $b$ 和 token $i$ 可以被正确地评估价值。基于目前繁荣的中心化和去中心化交易所，在提供了良好的流动性的情况下，是可以基本满足该潜在假设的。但是NFT交易所市场尚未成熟，即使中心化交易所也无法比较真实地反应市场对NFT的价格判断。NFT如何定价本身就是一个难题。
- NFT定价不具有连续性和可预测性。即使某个NFT在市场上有了一次成交记录，即有了一个价格，因为NFT被售出的频次远低于FT，即使在市场流动性非常好的情况下，该NFT下一次的成交价格既不连续，也不可预测。

### C. 研究基础

如果以XClaim方案作为跨链的基本方案，那么在这个基础上，只需要解决NFT的定价问题，就可以解决系统的经济安全。

对于NFT的定价问题，目前中心化和去中心化交易所给出的解决方案就是交给市场。根据dapp数据统计网站显示，排名第一的NFT交易所Opensea[10]一天的日活用户仅为42，日交易笔数73. 即使也采用和XClaim相同的喂价方案Oracle, 在这样的市场面前，得到的价格也很难具有代表性。

并且，鉴于NFT的不可替代性，市场定价的方法也存在天然的悖论。即买卖成功才可以定价；但是买卖成功同时也意味着owner的转移。

目前对于NFT的定价问题，还没有成型的方案。



#### C-I. 什么是Harberger Taxes

市场和私有财产是两个通常被放在一起谈论的话题，在现在社会很难想象，如果只单独谈论其中的一点却不提及另一点。然而在十九世纪，很多欧洲的经济学者也是自由论者和平等主张者，那时拥抱市场同时对私有财产持怀疑态度是很正常的事情。

由此，实现一个包含市场但是却没有所有权的系统是完全可行的：在每年的结束，收集物品的价格，在第二年的一开始，物品属于出价更高的人。这样的系统虽然在现实中不可行，但是它有一个极大的优点：实现配置效率。每年，每件物品都属于可以从中获取最大价值的人（因此才愿意出更高的价格）。

Eric Posner 和 Glen Weyl, 《radical market》的作者提出了一个方案Harberger Taxes[11]：1. 所有人都为自己的财产评估一个价格  2. 所有人按评估价的百分比，例如2%进行交税  3. 其他人可以以不小于评估价的价格，随时买走自己的财产。这就强制所有人都必须公平客观地评估物品的价格，评估地过高，自己就要多缴税；评估地过低，其他人就可以获得消费者剩余。



#### C-II. Harberger Taxes在跨链中的应用

我们提议将Harberger Taxes应用于NFT的定价上。不同于将定价问题交给时间和市场，我们提议将定价问题交给跨链发起者自己。

因跨链并不需要涉及到NFT的交易，所以我们只应用Harberger Taxes的卖方估价并交税的部分，并不应用强制交易的部分。

大概的思路为，由跨链发起者为其需要跨链的在chain $B$ 上的NFT $nft_b$ 声明一个价格 $p$ ，并按照一定比例的价格支付跨链手续费；对应地，$vault$ 需要按价格在chain $I$ 上提供等值/超值于$p$ 的抵押 $i$，如果跨链操作正确完成，则跨链手续费将被支付给对应的 $vault$ ；如果存在恶意行为导致跨链失败并且$nft_b$ 的归属者发生错误转移，则抵押的 $i$ 将用于补偿跨链发起者的损失。



### D. 组件定义

这里我们将部分遵从XClaim的声明方式，以保持延续性：

- *Issuing blockchain*, the blockchain $I$, 跨链后的新NFT的发行链
- *backing blockchain*, the blockchain $B$, 跨链前NFT所在的链
- *NFT identifier*, $nft_b^{n}$， 表示在chain $B$ 上的原生的、标识为 $n$ 的NFT，出现在章节II中
- *NFT identifier*, $nft_i^{n'}$， 表示跨链后在chain $I$ 上新增发的、 标识为 $n$ 的NFT，出现在章节II中
- *NFT identifier*,  $nft_b^{x,n}$,  表示在chain $B$ 上，在合约 $x$ 中标识为 $n$ 的NFT，出现在章节III中
- *NFT identifier*,  $nft_i^{x',n'}$,  表示跨链后在chain $I$ 上新增发的、在合约 $x'$ 中标识为 $n'$ 的NFT，出现在章节III中
- *native token on chain $I$*:  $i$
- 抵押token，$i\_col$ , 表示在chain $I$ 上抵押的token

系统参与方：

- **Requester** :  在chain $B$ 上锁定 $nft_b^n$  并且希望在 $I$ 上获得新发行的$nft_i^{n'}$ ；
- **Sender**： 在  $I$ 上拥有$nft_i^{n'}$ 并且可以转移它的所有权给其他人；
- **Receiver**： 在 $I$ 接受并且获取 $nft_i^{n'}$ 的所有权的人；
- **Redeemer**： 在 $I$ 上销毁 $nft_i^{n'}$ ，而后在 $B$ 上释放 $nft_b^n$；
- **vault**： 不需要信任的第三方，保证 *Issue* 和 *Redeem* 时整个系统的经济安全；
- **Issuing Smart Contract (iSC)**：在 $I$ 上完全公开的、负责管理$vault$ 名单并负责发行NFT资产$nft_i$ 的智能合约
- **Locking Smart Contract(loSC)**: 在 $B$ 上完全公开的、负责管理冻结后的NFT资产 $nft_b$ 的智能合约 （出现在章节III）

其中，*Requester, redeemer, vault* 必须在 *chain $I$ 和 chain $B$* 上都有对应的公私钥；*Sender, Receiver*只需要持有在 $I$ 上的公私钥；*iSC* 是在 $I$ 上完全公开的、可审计的智能合约；*loSC*是在 $B$ 上完全公开的、可审计的智能合约。

## II. 简单版 - 双链 (XClaim-Based)

### A. 区块链模型假设

> 为了兼容 XClaim，这里对chain $B$ 和 chain $I$ 的假设和 XClaim一样，并不做更多的假设限制。

基本假设：

-  *backing blockchain*，只有基本的账本功能的区块链，对于NFT跨链，唯一增加的假设就是 *chain $B$* 原生token就支持NFT；

- *Issuing blockchain* , 支持图灵完备的智能合约的区块链；

在这里，我们构造出一个跨链场景：

Alice 在 *chain $B$* 上拥有 $nft_b^n$,  Dave在chain $I$ 上有足够的 $i$,  

1. Alice想在chain $I$ 上发行 $nft_b$ 对应的新NFT，即 $nft_i^{n'}$
2. Alice在拥有$nft_i^{n'}$ 之后，又想把它在chain $I$  上转移给 Bob
3. 或者在某个稍晚的时刻，Alice想从chain $I$ 上把资产赎回到 chain $B$ ，再次获得 $nft_b^n$ 

为了实现以上场景，XClaim-based NFT cross-chain protocol需要实现三种协议：*Issue, Trasnfer, Redeem*. 为了简化模型，我们在此处省略手续费相关部分的细节。

### B. 初步实现方案

#### Protocol: Issue

> Alice (requester) 把  $nft_b^n$ 在 $B$ 上锁定在 $vault$，为了在 $I$ 上创造 $nft_i^{n'}$.

(i) *准备*。Alice 预先声明一个价格 $p$,  确认 iSC 有效并且在 iSC 中寻找有足额/超额抵押的 $vault$.

(ii) *锁定*。Alice 把 $nft_b^n$ 转移给 $vault$，同时声明自己在 $I$ 上的地址；并且支付跨链手续费；

(iii) 



### C. 安全细节阐述



## III. 扩展版 - 多链 (GUID)

### A. 区块链模型假设

### B. 初步实现方案

### C. 安全细节阐述
