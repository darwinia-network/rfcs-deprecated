- 功能描述: 达尔文应用链(Darwinia AppChain)
- 开始时间: 2019-05-13
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary

<img src="https://raw.githubusercontent.com/evolutionlandorg/ELIPs/master/logo/darwinia_appchain.png" alt="drawing_appchain" width="400"/>

# 达尔文应用链简介
达尔文网络有一条枢纽链，被称为达尔文主链(Darwinia Hub)，可以作为ParaChain接入Polkadot，但是同时这个达尔文主链也被设计成一个Relay链，可以让各种的游戏链接入进来，为了方便游戏开发商和其他应用在不需要懂得太多区块链知识的基础上可以开发满足应用层面需求的区块链网络，达尔文网络基于Substrate和达尔文区块链内核(Darwinia Kernel)，设计开发一套应用区块链的框架，被称为达尔文应用链(Darwinia AppChain)。

首先达尔文应用链的设计目标是为了满足应用层面，甚至是业务层面的需求，而不是公链的平台需求，因此需要重视框架的灵活性，组件的多样性，在共识算法，出块速度，治理模式上与公链也会非常不同。

达尔文主链的主要设计目的是为了支持游戏的开放经济规则(跟Defi有点相似)，以及游戏资产的跨链，因为不适合作为游戏应用的区块链框架直接使用，因此需要区分出达尔文网络和应用链在概念上的区别。

达尔文应用链同样基于Substrate框架，使用与达尔文链同样的内核，同时达尔文应用链可以作为ParaChain连接至达尔文链。达尔文主链和应用链组成的网络被称之为达尔文网络。

# 动机和目的
[motivation]: #motivation

- 需要设计一个灵活的区块链框架和组件集，以支持应用层面的区块链开发需求和账本需求，包括未来进化星球大陆所需要运行的区块链网络
- 需要一个支持Darwinia ParaChain接口的区块链框架，帮助构建达尔文网路，并且帮助应用对接至外部区块链网络。
- 应用层面的需求与目前主链的需求和设计目标的不一致


# Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

## 达尔文主链与各应用链(包括大陆所在应用链)的关系（示意图WIP）


![达尔文应用链示意图](./images/0006-darwinia-appchain.png)

## 其他架构参考

- [Polkadot Parachain](https://medium.com/polkadot-network/polkadot-the-parachain-3808040a769a)
- [Nervos AppChain](https://www.jianshu.com/p/6f400407e56d)
- [Parity Substrate](https://www.parity.io/substrate/)
- [Graphene](https://github.com/cryptonomex/graphene/wiki)
- [Cosmos Zone](https://ethermint.zone/)



# 参考和实现
[reference-level-explanation]: #reference-level-explanation

## 代码库

[WIP] https://github.com/evolutionlandorg/darwinia-appchain

### 基于达尔文应用链的进化星球大陆(WIP)
除了该大陆应用层面的需求之外，该大陆可能还会支持达尔文主链部分核心功能，这部分的支持是过渡性的，在达尔文主链上线后将迁移至主链。

## 达尔文企业应用链(Darwinia Enterprise AppChain)

<img src="https://raw.githubusercontent.com/evolutionlandorg/ELIPs/master/logo/darwinia_enterprise_appchain.png" alt="drawing_enterprise_appchain" width="400"/>

达尔文企业应用链(简称 DEAC)会增加一些企业需要的可插拔组件和联盟链组件，因此也可以归类为联盟链范畴。DEAC适用于希望使用达尔文内核和组件的企业用户和行业用户。

达尔文企业应用链可以选择连接至达尔文网络，实现跨链资产的对接，也可以不用连接至达尔文网络。

## 主要特性[WIP]

- 支持合约
- 应用开发者可以为用户支付燃料费
- Finality比较好的简单共识算法
- 支持多种密码学算法ECDSA, EDDSA，Schnorr，BLS
- TPS高，出块速度快
- 支持进化星球星际资产编码标准


# 缺点
[drawbacks]: #drawbacks

[WIP]

# 理由
[rationale-and-alternatives]: #rationale-and-alternatives

- 应用层面降低用户门槛和改善用户体验的需要
- 面向应用定制化的需要

# 现有技术
[prior-art]: #prior-art

- https://github.com/paritytech/substrate
- https://www.itering.com/solution/dkms
- https://www.itering.com/solution/custom
- 链上随机数的服务(WIP)
- [跨链转换桥的对接](https://github.com/evolutionlandorg/darwinia-bridge)

# 问题
[unresolved-questions]: #unresolved-questions

[WIP]


# 未来的可能性
[future-possibilities]: #future-possibilities

- 改善存储模型
- 适合应用开发者的治理机制
- 满足企业用户需要


# 参考

- [1] [Substrate](https://github.com/paritytech/substrate)
- [2] [Darwinia Hub](https://github.com/evolutionlandorg/darwinia-hub)
- [3] [Darwinia Bridge](https://github.com/evolutionlandorg/darwinia-bridge)
