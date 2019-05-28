- 功能描述: 新版古灵阁银行和氪石利息
- 开始时间: 2019-04-28
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary

原分散在各个大陆的古灵阁银行功能(包括Bancor和氪石存取)，及其他星球货币系统的核心业务将会被迁移至达尔文网络，也就是所有的RING的发行及氪石最终将会在达尔文网络上进行，但是在达尔文网络发布前存在一个过渡期，过渡期内，这部分功能将会先存在于大陆应用链。


# 动机和目的
[motivation]: #motivation

KTON可以使用获得系统的收入分成，在第一个版本的以太坊大陆和波场大陆中，氪石的分成通过通道代理实现了几乎实时的分成，但是在后续的版本这个特性将会稍作改变。当氪石相关功能迁移到达尔文网络中时，氪石获得的RING分成将会先在系统中锁定一个星期，一个星期到期后才可以提取到账户中用于转账等功能。

- 需要支持氪石分成锁定功能。
- POS共识的Staking方式可能需要采取氪石Staking，这个部分可能需要作为另一个单独的RFC. [WIP]


# Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

旧版的氪石设计可以参考：

- [进化星球虚拟银行和氪石](https://forum.evolution.land/topics/55)

进化星球中的氪石基于未来锁定币龄的二阶投票，用户为氪石投票决策承担后果（解锁RING时的价格上涨或下跌），同时随着时间推移，新的氪石会不断通过锁定RING币龄发行给当前RING持有者，以削弱曾经RING持有者手中的氪石票权，减少交易所代持或者通过Defi借贷出来的氪石的票权比重。
Polkadot的POS分享好像也有很多是基于锁定在系统中的Bonds，我认为也属于一种承诺并锁定的未来币龄。


关于Staking POS共识算法的一些讨论

- https://www.chainnews.com/articles/362444363153.htm



# 参考和实现
[reference-level-explanation]: #reference-level-explanation

在以太坊大陆和波场大陆上已经有了古灵阁银行和氪石的对应实现。

- https://github.com/evolutionlandorg/bank
- https://github.com/evolutionlandorg/tron-contracts/tree/master/contracts/bank

# 缺点
[drawbacks]: #drawbacks

[WIP]

# 理由
[rationale-and-alternatives]: #rationale-and-alternatives

- 跟Bancor模型迁移至达尔文网络的理由一样，出于安全考虑，应该将核心经济系统由安全度不一的各个分散大陆迁移至安全度较高的达尔文网络。
- 方便模型的升级和KTON发行，KTON将可以通过Token跨链在各个大陆流转

# 现有技术
[prior-art]: #prior-art


古灵阁银行和氪石的SRML模块需要实现一下。[WIP]

共识模块和Staking模块[WIP]

# 问题
[unresolved-questions]: #unresolved-questions

[WIP]


# 未来的可能性
[future-possibilities]: #future-possibilities

氪石的利息的治理和升级给未来的核心经济系统带来了弹性，特别是可以考虑增加进古灵阁操作手续费的部分，为未来氪石的通胀和Staking带来空间。

关于古灵阁和氪石手续费来说，举例说明：

目前的氪石手续费大概是每1万RING存一年是1个氪石，可以考虑改成1.1氪石，但是0.1氪石作为手续费通过Coinbase发给验证人，用户还是可以拿到一个氪石。通过这个方式，可以鼓励验证人多Staking氪石以获得更多氪石激励。

[WIP]


# 参考

- [1] https://mp.weixin.qq.com/s/-Va8Q8I6zTtpNdJImkslrg
- [2] https://baike.baidu.com/item/%E5%B9%B4%E5%8C%96%E5%88%A9%E7%8E%87/5834305
