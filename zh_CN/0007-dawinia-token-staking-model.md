- 功能描述: 达尔文通证和Staking模型(Darwinia AppChain)
- 开始时间: 2019-05-23
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary
这边设计稿介绍达尔文网络的通证和Staking模型。

# 通证模型

## 通证RING

RING是达尔文网络的原生资产。RING可以作为交易的燃料费，可以通过锁定获得KTON。燃料费包括交易费用，合约执行费用，网络带宽费用，存储费用等等。
通过锁定RING获得的KTON是达尔文网络的Staking和治理凭证。氪石持有者和氪石Staking锁定者将可以获得网络收入和Staking收益。氪石只能通过锁定RING获得，最早通过锁定RING获得氪石的设计出现在进化星球古灵阁银行，相关的介绍可以参考古灵阁氪石模型[5]。
RING在达尔文网路主网上线时的初始供应量(INITIAL_SUPPLY)为20亿，之后将会通过出块奖励将新发行的RING分发给出块验证人和Nominator(Staking参与者)。
在达尔文主网上线后，该年的出块奖励总上限(MAX_BLOCK_REWARD_YEAR)调整一次，每年的块奖励最大上限为剩余可发行供应量的20%，实际的通胀率将会跟RING和KTON的锁定率挂钩，将会远远小于20%，预期为剩余可发行供应量的4%-10%。


```剩余可发行总量 = 硬顶总量(HARD_CAP) - 当前供应量(CURRENT_SUPPLY)```

```该年出块奖励总上限 = 剩余可发行总量 × 1/5```

```下一年的供应量 = 上一年的供应量 + 该年实际出块奖励总和```

RING的硬顶总量为100亿。
根据每年的出块奖励上限，和出块间隔时间(单位：秒)，可以算出这一年的每个块的出块奖励上线(MAX_BLOCK_REWARD)

```每个块的块奖励上限 = 该年出块奖励总上限 × 出块间隔时间 ÷ 每年总秒数(即365乘24乘3600)```

最终每个块的出块奖励实际数量跟RING锁定率和氪石锁定率有线性比例关系：

```RING锁定率 = 当前未到期且锁定状态的RING总和 ÷ RING当前总量```

```氪石锁定率 = 当前质押锁定状态的KTON总和 ÷ KTON当前总量```

在Solo模式下(区别于Polkadot连接模式下，见Staking章节)，每个块的实际出块奖励为(X, Y为系统参数，X+Y <= 100)：

```每个块的实际块奖励 = 块奖励上限 × ( X% ×F(氪石锁定率) + Y% × F(RING锁定率) + (100-X-Y)%)```

备注: X, Y为系统参数，满足X+Y <= 100。X%，Y%和 (100-X-Y)% 的意义分别表示分配给验证人，氪石持有者，Treasury的奖励比例，其中验证人的部分已包含Nominator和Collator。F(锁定率)表示与锁定率线性的相关的函数，具体尚在研究之中，简化情况下可以理解为”F(锁定率)=锁定率”。

实际网络运行过程中，锁定率是不断变化的，这里我们举几个简化且理想化的情况举例子，例如锁定率都为20%，35%，50%，65%时，相应供应量的增长曲线为：

![Plot[4^(5 + x) 5^(9 - x), {x, 0, 25}]](./images/0007-darwinia-token-3.jpeg)

## 通证KTON(氪石)
虚拟银行是进化星球上的一个奇怪的去中心化银行，通过智能合约实现，任何人可以选择将一定数量的RING存放至虚拟银行，并承诺锁定N个月不会取出，虚拟银行将会根据RING的数量和承诺锁定的月数，在存入时就发行一定数量的氪石利息，并奖励给承诺RING锁定的客户。

英文名: Darwinia Kryptonite

缩写Symbol: KTON

精度: 18

发行: 通过定存操作发行

销毁: 通过提前撤销罚款

锁定: 达尔文网络验证者Staking或者达尔文网络并行链Staking

氪石的设计源于对权益工作量证明的一种新的理解，即基于你未来承诺持有RING多长时间来衡量你的工作量。

### 虚拟银行RING定存业务
氪石利息的计算方式为按月复利，鼓励长期承诺投入。具体公式如下：

```
R(N, X, S) = [(1 + C)^(N/12) - 1] * X * S    { N: from 1 to 36 }
```


C*X是每个RING年化氪石回报率参数(暂定为C = 0.2，X = 5，每万份一年定期可以获得一个氪石，C后面可以由系统调节)，那么锁定N月，S个RING的氪石利息R计算方式为

[![coffee-starcoin-Page-1](https://imgland.oss-cn-hangzhou.aliyuncs.com/photo/2018/a4204a47-8412-4d8e-9367-82a98cc8f3e4.jpg?x-oss-process=image/resize,w_640)](https://www.wolframalpha.com/input/?i=%5B1.2%5E(N%2F12)+-+1%5D+*+5+from+1+to+36)


氪石利息是虚拟银行在锁定发生时根据该公式发行出来的。

### 虚拟银行RING定存提前撤销业务

如果用户反悔，想放弃承诺，提前取出RING，则需要支付氪石罚款，才能取出锁定的RING.

罚款的氪石金额F的计算方式如下:
假设锁定的月数为N，解锁时剩余的月数为M(包含所在月份)

```
F(N, X, S) = [R(N, X, S) - R(N-M, X, S)] * (罚款倍数)   , 暂定罚款倍数为3
```

罚款的氪石将会被虚拟银行销毁。


# 动机和目的
[motivation]: #motivation

- 设计RING通证和KTON通证，分别代表达尔文网络的支付手段和权益(和投票)手段
- 跨链和公链需要通证激励来保证网络安全性，以及防止Spam攻击。
- 需要设计Staking模型，来保证网络来Solo模式和波卡连接模式的安全性。


# Staking模型设计解释
[guide-level-explanation]: #guide-level-explanation

达尔文网络将会把全部收入作为激励分发给Staking的参与者。

达尔文网络的收入来源大体分为两种：

- 出块奖励(BLOCK_REWARD)，每年的块奖励上限随时间会减少，通胀率将会随着时间快速收缩和降低。
- 达尔文网络交易手续费(NETWORK_FEE)，包括开发者使用达尔文网络的跨链服务，达尔文网络平行链的接入费用，以及相关应用比如进化星球自主选择分配给达尔文网络的收入。

因为Polkadot网络采用共享池安全的模型，所以处于Polkadot 连接模式时，平行链的安全性将由由中继链的验证人来保证，达尔文网络在此情况下不需要负责验证，只需要负责Collator即可。

因此，达尔文网络的 Staking 在这两种模式下的安全激励也会有很大不同，具体如下。Solo 模式收入分配

验证人和 KTON 持有者将会按照一个比例来分享进化星球的收入， KTON 持有者可以同时把自己的 KTON 投票给验证人，获取验证人部分的 Staking 激励。(Y为系统参数，将会通过KTON投票的治理机制来设定)

```angular2
（锁定 KTON，全部 KTON, Treasury）= 

[ (块奖励上限 ×氪石锁定率 + NETWORK_FEE)×X% ,  (块奖励上限 ×RING锁定率 + NETWORK_FEE)×Y%), (块奖励上限 + NETWORK_FEE) × (100-X-Y)% ]
```

Polkadot 连接模式收入分配

当达尔文网络打算连接至Polkadot网络时，根据Polkadot Parachain Auction[4]的模型，达尔文中继链将需要锁定足够多的DOTs来参与Parachain Slots竞价，是否胜出只与锁定的DOTs多少有关，取决于当时的市场情况。为了获得足够的竞争力，达尔文网络将设计一种众筹锁定竞价机制，以激励达尔文社区参与者帮助竞价。
众筹锁定竞价

Polkadot的Parachain Slot拍卖竞价允许任何类型的抽象账户参与竞价，包括普通地址账户，智能合约账户，平行链账户。这种广泛的抽象账户支持为参与竞价者提供了灵活性，可以设计各种去中心化的竞价模型。达尔文网络将为Polka连接模式设计一种通过众筹锁定DOT来参与Parachain Slots竞价的方式，众筹者不需要将DOT所有权进行转移，只需要将DOT锁定并提供锁定凭证，同时开放一定的投票或者竞价权限供达尔文中继链使用。参与竞价锁定的DOTs是安全的，因为整个过程是通过智能合约(或中继链)完成的，没有任何人可以控制这部分锁定的资产。

当达尔文网络切换至Polkadot连接模式时，达尔文网络不再需要自己的验证人，原来用来激励KTON锁定者Staking的部分将会被用来奖励那些帮助达尔文网络进行DOT锁定竞价的参与者，也就是说，达尔文社区的DOT持有者将可以通过提供DOT竞价锁定凭证，获得RING网络收入奖励。

```angular2
（达尔文竞价锁定DOT，全部 KTON, Treasury）= 
[ (块奖励上限 + NETWORK_FEE) × X% ,  (块奖励上限 × RING锁定率 + NETWORK_FEE) × Y% , (块奖励上限 + NETWORK_FEE) ×(100-X-Y)%) ]
```


## 其他架构参考

- [Cosmos Staking](https://blog.cosmos.network/economics-of-proof-of-stake-bridging-the-economic-system-of-old-into-the-new-age-of-blockchains-3f17824e91db)
- [Polkadot Staking](https://medium.com/polkadot-network/polkadot-proof-of-concept-4-arrives-with-new-ways-to-stake-3b27037346cc)
- [Polkadot Parachain Slot Auction](https://wiki.polkadot.network/en/latest/polkadot/learn/auction/)



# 参考和实现
[reference-level-explanation]: #reference-level-explanation

## 代码库

[WIP] https://github.com/evolutionlandorg/darwinia-appchain

## 主要特性和创新[WIP]

- 支持Solo模式和波卡连接模式的无缝切换
- 二阶Staking模型：锁定的氪石相当于二阶的锁定RING
- 氪石是根据古灵阁氪石利息算法生成的，鼓励长期锁定和长期投入者
- Staking权益和投票权的通证化，Staking后的锁定氪石即为投票权。
- 应用层收入和达尔文收入分层设计，将进化星球应用层与达尔文跨链网络协议层解耦
- 波卡连接模式，类似一种众筹DOT抵押参与Polkadot Slot竞价拍卖的模式，并且参与达尔文网络Staking分成


# 缺点
[drawbacks]: #drawbacks

- 通证氪石的设计同进化星球古灵阁。进化星球的古灵阁功能中的RING存取(氪石功能)将会迁移至达尔文中继链。
- 设计变更: 取消Bancor挂钩的发行模型
- 设计变更: 应用层面的流动性模型可以采取类似Uniswap模型的方案
- 设计变更: 按照大陆通胀，改成按照协议和网络时间通胀.

# 理由[WIP]
[rationale-and-alternatives]: #rationale-and-alternatives


# 现有技术
[prior-art]: #prior-art

- https://github.com/evolutionlandorg/bank
- https://github.com/evolutionlandorg/darwinia-appchain/tree/master/srml/token

# 问题
[unresolved-questions]: #unresolved-questions

[WIP]


# 未来的可能性
[future-possibilities]: #future-possibilities

### KTON虚拟银行未来商业拓展计划之贷款业务

当未来RING有足够的流动性，且虚拟银行中有锁定的RING的时候，任何玩家可以通过抵押足够(3倍)的资产(例如ETH)，向虚拟银行贷款，但是需要在贷款时支付氪石贷款利息 D。用户到期后，可以返回借出的RING，换回抵押资产。

```
D(N, X, S) = R(N, X, S) * (贷款倍数) 暂定贷款倍数为2
```

借贷者缴纳的氪石贷款利息将会被虚拟银行销毁。

任何时候如果虚拟银行发现抵押不充足(平仓线，低于1.3倍)时，任何人可以通过平仓动作，支付RING给虚拟银行，换回锁定的抵押物。(这个部分设计可以参考MakerDAO)

氪石将作为RING长期持有者和价值投资者的奖励，在系统重要投票和系统创始道具购买上扮演重要角色，例如某些保留的地块，只能用氪石购买。



# 参考

- [1] [进化星球虚拟银行和氪石](https://forum.evolution.land/topics/55)
- [2] [PoW的好处](https://mp.weixin.qq.com/s/-Va8Q8I6zTtpNdJImkslrg)
- [3] [年化利率](https://baike.baidu.com/item/%E5%B9%B4%E5%8C%96%E5%88%A9%E7%8E%87/5834305)
