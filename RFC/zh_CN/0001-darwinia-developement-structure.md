- 功能描述: 达尔文网络的开发架构描述
- 开始时间: 2019-04-28
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary

达尔文网络使用Polkadot和Substrate的技术构建跨链网络，可以被看做一个独立的网络，但是由于Polkdot网络提供了一套开放的异构网络接入方式，为了达到更多网络经济效益，相对于Polkdot的Relay-chain，达尔文网络自身也被设计成可以接入Polkdot relay-chain的parachain。同时，达尔文网络内部存在各种异构的大陆子网络，因此达尔文网络的链也会包含一个Relay chain。


从技术角度来说，达尔文网络可以被看做是Polkadot的一个二阶relay-chain (2nd order relay-chain)，同时也是Polkadot上的一个parachain，关于relay-chain和parachain的概念可以详细参考Polkadot的白皮书[2]。同时，各个大陆所在的链将会以两种方式，作为达尔文网络parachain接入达尔文网络自身的relay-chain，RING将作为达尔文网络内作为Validator bond抵押的通证。如果该大陆所在链是以太坊或波场等公链，将会参考Polkadot异构链的接入方式，采取Swap-Out合约加桥(Mulit-entity Bridge)的方式接入一个对应的以太坊Parachain或波场Parachain，如果该大陆本身就是parachain，那么可以直接接入，因此达尔文网络自己搭建的大陆应用链，也将采取substrate [3]的框架开发，以方便直接作为parachain接入达尔文网络。


# 动机和目的
[motivation]: #motivation

达尔文网络需要一个很好的跨链技术架构来支撑进化星球的业务体系。

# Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

关于Polkdot的网络拓扑可以参考其白皮书，其网络拓扑的发展会有点像分形结构，即局部的网络拓扑和整体的网络拓扑会是同构且比较相似。，下面的图片列出了达尔文网络可能在网络中的位置，以及达尔文网络与各个大陆链的关系。


![Polkadot and Darwinia networks](images/0001-darwinia.png)


# Reference-level explanation
[reference-level-explanation]: #reference-level-explanation

关于Substrate框架的详细介绍，可以参考下面的一些代码库和文档。

- [https://github.com/paritytech/substrate](Substrate)
- [https://polkadot.js.org/](Polkadot和Substrate工具，接口和JS库).
- [https://docs.substrate.dev/](Substrate文档和上手资料)

# 缺点
[drawbacks]: #drawbacks

比较依赖Substrate的开发设计和进度。

# 理由
[rationale-and-alternatives]: #rationale-and-alternatives

- Substrate是Polkadot底层的框架，符合达尔文网络跨链的理念
- 最新的技术框架，比较好的底层模块解耦和支持，可以定制SRML
- 可以很方便的接入Polkadot，站在巨人的肩膀上

# 现有技术
[prior-art]: #prior-art

达尔文网络将同时使用Substrate的SRML模块开发，以及合约模块的Parity ink合约开发(基于WebAssembly)

- [https://github.com/paritytech/substrate-up] (构造开发SRML并且构造自己的链)
- [https://github.com/paritytech/ink](ink! - Parity's ink to write smart contracts)

# 问题
[unresolved-questions]: #unresolved-questions

- SPREE的细节实现，SPREE是Shared Protected Runtime Execution Enclaves，是实现跨链交互的关键模块。
- SRML的宏定义虽然给代码带来的简化，但是理解起来也比较复杂，需要阅读宏代码或者官方相关文档(暂时还比较缺少)

# 未来的可能性
[future-possibilities]: #future-possibilities

Polkdot最新公布了一些Parachain的竞价机制，需要锁定一定数量的DOT以租用Parachain，进化星球将会积极参加竞价，尽早拿到Parachain名额，以成为Polkdot在游戏领取的顶层并行链，并同时帮助游戏领取内的其他网络，连接和进入Polkdot网络，实现互联互通。

# 参考

- [1] https://github.com/cosmos/cosmos/blob/master/WHITEPAPER.md
- [2] https://github.com/w3f/polkadot-white-paper/raw/master/PolkaDotPaper.pdf
- [3] https://www.parity.io/substrate/
- [4] https://imgland.l2me.com/files/evolutionland/whitepaper_en.pdf
- [5] https://en.wikipedia.org/wiki/Triffin_dilemma
