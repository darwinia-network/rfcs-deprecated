- 功能描述: 达尔文通证和Staking模型(Darwinia AppChain)
- 开始时间: 2019-05-23
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary
这边设计稿介绍达尔文网络的通证和Staking模型。

# 通证模型

## 通证RING

英文名: Darwinia Native Ring Coin

缩写Symbol: RING

精度: 18

最大发行量: 10 billion

初始发行量: 2 billion

发行: 按照固定的通胀率发行，剩余的8 billion将按照每年释放剩余发行量1/5的方式，作为奖励按照协议分发(Staking锁定空投)给贡献者。

销毁: 暂无

锁定: 锁定获得氪石

用途: RING 将会被用于系统Staking，生成氪石，支付燃料费，跨链费用和其他网络费用。

介绍
每一年的发行量，是上一年的⅘，即

Inflation (0) = 2 billion

Inflation(X) = Inflation(X - 1) * ⅘

每年通胀的RING数量:
![Plot[4^(5 + x) 5^(9 - x), {x, 0, 25}]](./images/0007-darwinia-token-1.jpeg)

按时间的RING发行量:
![Plot[2000000000 5 (1 - (4/5)^(x + 1)), {x, 0, 25}]](./images/0007-darwinia-token-2.jpeg)


## 通证KTON(氪石)
虚拟银行是进化星球上的一个奇怪的去中心化银行，通过智能合约实现，任何人可以选择将一定数量的RING存放至虚拟银行，并承诺锁定N个月不会取出，虚拟银行将会根据RING的数量和承诺锁定的月数，在存入时就发行一定数量的氪石利息，并奖励给承诺RING锁定的客户。

英文名: Darwinia Kryptonite

缩写Symbol: KTON

精度: 18

发行: 通过定存操作发行

销毁: 通过提前撤销罚款

锁定: 达尔文网络验证者Staking或者达尔文网络并行链Staking

### 虚拟银行RING定存业务
氪石利息的计算方式如下：
假设每个RING锁定一年期(12个月)的氪石利息回报是X个氪石。(暂定X=0.0005)，C*X是每个RING年化氪石回报率参数(暂定为C = 0.2，每万份一年定期可以获得一个氪石，C后面可以由系统调节)，那么锁定N月，S个RING的氪石利息R计算方式为

```
R(N, X, S) = [(1 + C)^(N/12) - 1] * X * S    { N: from 1 to 36 }
```

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

可以用于Staking激励的收入，分为通胀收入和网络服务收入。

```angular2
Staking_Income(RING) = Coinbase_Inflation + 达尔文网络应用RING收入
```

```angular2
达尔文网络应用RING收入 = 进化星球氪石分成 + 网络燃料费+ 其他收入
```



按照波卡的设计，并行链的安全性是由中继链保证的，所以并行链上线的时候可以不solo运行，而是直接连到中继链。

波卡上的Para并行链都存在Solo模式和连接模式的切换问题。连接模式的网络安全由波卡负责的话，也就不需要自己的验证者及相应staking保证共识安全。




下面分别解释波卡连接模式和Solo模式。


## Solo模式

```angular2
（锁定氪石，全部氪石）= （Staking_Income × Y%, Staking_Income × （100-Y）%）
```


## 波卡连接模式

达尔文中继链可能还需要设计一个功能，就是抵押staking DOT，去众筹bid竞价Polkadot的slot，如果成功连接至波卡的话，目前的氪石staking会切换成参与众筹staking的DOT持有者获得通胀出来的RING。

```angular2
（达尔文众筹Bid锁定的DOT，全部氪石）= （Staking_Income × Y%, Staking_Income × （100-Y）%）
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
