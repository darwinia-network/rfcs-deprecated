- 功能描述: 基于一篮子货币(类SDR)的Bancor发行机制
- 开始时间: 2019-04-28
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary

原先分散在各个大陆链，各自基于单一货币的Bancor发行机制面临一些问题，因此需要进行简化，并改进成基于一篮子货币作为抵押的Bancor发行机制。

由于通证发行的渠道有原来的分散在各个大陆的模式，变成了一篮子货币统一发行的方式，因此相关的发行方式也需要放到进化星球系统层面，也就是达尔文网络。因此在达尔文网络中，将包括RING发行机制的实现，以及相关的各资产的跨链转账，SDR封装和SDR拆除功能。


# 动机和目的
[motivation]: #motivation

## 目前RING的Bancor发行机制
进化星球中的系统通证叫做 RING（全称是 Evolution Land Global Token， 精度是 18 位）。在第⼀个⼤陆中的最大供应量是 20 亿，所有大陆的最⼤供应量 100 亿。上面的最大供应量只对发行量做了约束，目前具体的方式为在各个大陆中按照Bancor机制(CW为10%)发行，在以太坊大陆上储备金为ETH，在波场大陆上储备金为TRX。各个大陆分别用Bancor发行的机制为RING带来了很好的初期流动性，但是在不同链上使用不同的储备金发行的方式也存在一些问题，主要包括“劣币驱逐良币”的问题，和特里芬难题(即储备金的价格变化对RING的价格变化影响因子太大)。

## “劣币驱逐良币”问题
首先解释一下，“劣币驱逐良币”问题，因为目前的机制可以使用不同的储备金按照同样的CW发行RING，并且使用不同储备金通过Bancor发行出来的RING通证之间是无差别可以互相质换的。假设有A、B两种储备金资产，其中B是劣币，表示其价值和价格随着时间会长期处于下降趋势，那么，当B不断下跌的过程中，持有A资产储备发行出来的RING的用户，会倾向于将RING换成A资产，然后通过外部交易所换成B资产，以发行更多的RING。

可以发现，在这个过程中，更多数量的RING被发行出来了，但是其储备金更多的变成了B资产，储备金的价值反而没有增加或变得更少。

## 特里芬难题
美国经济学家罗伯特·特里芬在其《黄金与美元危机——自由兑换的未来》一书中提出“由于美元与黄金挂钩，而其他国家的货币与美元挂钩，美元虽然取得了国际核心货币的地位，但是各国为了发展国际贸易，必须用美元作为结算与储备货币，这样就会导致流出美国的货币在海外不断沉淀，对美国国际收支来说就会发生长期逆差；而美元作为国际货币核心的前提是必须保持美元币值稳定，这又要求美国必须是一个国际贸易收支长期顺差国。这两个要求互相矛盾，因此是一个悖论。”这一内在矛盾称为“特里芬难题(Triffin Dilemma)”。

简而言之，特里芬难题指的是由于单一储备货币导致的通证价格不稳定问题。

为了解决这个问题和上面提到的“劣币驱逐良币”问题，可以通过引入一篮子货币的概念，即将原来分散在各个大陆的储备金放到一个篮子里面，用这个篮子里面的“一篮子货币SDR”通证作为储备金来做Bancor发行。这样，任何一个RING通证都是有同样资产储备发行出来，不存在”不同的储备金”，也就没有优劣之分。因为篮子里面的资产具有多样性，不会因为单一储备品种的价格变化而发生太大影响，进而解决特里芬难题。


# Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

关于Bancor的详细解释可以参考：

- https://storage.googleapis.com/website-bancor/2018/04/01ba8253-bancor_protocol_whitepaper_en.pdf
- https://forum.evolution.land/topics/66
- https://forum.evolution.land/topics/68


关于SDR，一篮子货币以及特里芬难题的介绍可以参考:

- https://en.wikipedia.org/wiki/Special_drawing_rights

- https://zh.wikipedia.org/wiki/%E7%89%B9%E9%87%8C%E8%8A%AC%E5%9B%B0%E5%A2%83

- http://www.bis.org/review/r090402c.pdf



# 参考和实现
[reference-level-explanation]: #reference-level-explanation

目前已经有一些智能合约的参考实现，EOS上也有一些机制基于Bancor

- https://github.com/evolutionlandorg/bancor-contracts
- https://github.com/evolutionlandorg/tron-contracts/tree/master/contracts/bancor
- https://github.com/bancorprotocol/contracts_eos

# 缺点
[drawbacks]: #drawbacks

一篮子货币或SDR本质上也可以视作一种可质换代币，从这个角度上来看实现Bancor并不存在难点，但是从实用的角度上看，将用户熟悉的各种单一货币兑换成一篮子货币可能是一件困难的事情，这中间需要接入各种外部的兑换服务，以实现自动化和门槛的降低。

# 理由
[rationale-and-alternatives]: #rationale-and-alternatives

- 劣币驱逐良币的问题
- 利用达尔文网络，以实现核心经济规则(包括RING发行)的安全性，而不是更分散的依赖各个安全度不一样的大陆链来实现发行。
- 简化设计，区别于原来各个大陆都可以发行RING，新的模型在达尔文网络上发行，然后通过跨链通证的方式将RING转移到其他大陆。

# 现有技术
[prior-art]: #prior-art

一篮子货币的实现可以参考一下MakerDao的多资产抵押合约。

https://first.vip/shareReport?id=3316&uid=5046



Bancor的SRML模块需要实现一下。[WIP]



# 问题
[unresolved-questions]: #unresolved-questions

[WIP]


# 未来的可能性
[future-possibilities]: #future-possibilities

在实现RING发行功能的基础上，这一套基础设置也可作为跨链代币交易的一套服务，游戏方向的一些业务可以选择接入这些基础设施服务。

[WIP]


# 参考

- [1] https://github.com/EOSIO/Documentation/blob/master/TechnicalWhitePaper.md
- [2] https://arxiv.org/abs/1709.08881
- [3] https://ethresear.ch/t/draft-position-paper-on-resource-pricing/2838
