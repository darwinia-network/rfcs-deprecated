- 功能描述: NFT在EOS上的星际资产编码设计
- 开始时间: 2019-05-27
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary
这篇文稿介绍NFT在EOS上星际资产编码相关的设计，主要提到如何基于EOS dgoods标准进行编码和映射。

![dGoods Compatible](https://github.com/MythicalGames/dgoods/raw/master/media/badge.png)

# 动机和目的
[motivation]: #motivation

以太坊上已经有比较成熟且广泛认可的NFT标准，但是EOS上的NFT标准还未完全成熟和确立，因此给设计和实现，包括以后的可扩展性带来了一定不确定性，这其中就包括星际资产编码相关的设计。

- EOS dgoods标准的兼容和映射，为后期跨链NFT做准备
- doods标准的合约结构差异处理
- 星际资产编码标准EOS相关规范细节。

# Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

- [ERC721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)
- [ERC721.ORG](http://erc721.org/)
- [dGoods](https://github.com/MythicalGames/dgoods/blob/master/dGoods_spec_%E4%B8%AD%E6%96%87.md)

# 参考和实现
[reference-level-explanation]: #reference-level-explanation

## uint256标识编码解释

如下表所示，主要解决dGoods的合约(sym)，category, token name 和dGoods id如何映射到uint256相应标识位上的问题
将需要开发实现一个独立的映射合约来设置和查询这个映射关系，这样任何一个EOS上的NFT应该可以用一个全局的uint256 NFT token id表示。


[dGoods NFT表结构](https://github.com/evolutionlandorg/eos-contracts/blob/master/dgoods/dgoods.hpp#L122)


| 序号     | 标识                                                                 | 描述                                   |
| ---------| --------------------------------------------------------------------|-------------------------------------------|
| 1        | Magic Number                                                        |42|
| 2        | Chain ID                                                            |EOS Chain ID|
| 3        | Reserved                                                            |保留位|
| 4        | Ownership Contract ID                                               |合约账户对应的ID & Symbol|
| 5        | Last Chain ID                                                       ||
| 6        | Reserved                                                            |保留位|
| 7        | Last Contract ID                                                    ||
| 8        | Object Class ID                                                     |Category 类别, dGoods Category|
| 9        | TokenIDConvertType                                                  ||
| 10-13    | Token ID Convert MetaData(Repeat Byte, start1, end1, start2, end2, EOF) ||
| 14       | Reserved                                                                |dGoods Token Name, reserved is not used|
| 15-16    | Space/Producer                   |出产地、制造商信息.  (进化星球内部26各大陆生产的物品分别为1-26，外部的物品（如加密猫）将被分配其他的属地信息)|
| 17-32    | Customized NFT Object Token Index Inside Contract(e.g. auto increasing) |dGoods Id|



## 代码库

[WIP] https://github.com/evolutionlandorg/eos-contracts/tree/master/dgoods
[WIP] 编码实现TODO


# 缺点
[drawbacks]: #drawbacks

- 在原来的星际编码表中并未保留token name的位置，感觉dGoods的这个设计只是为了记录token名字，但确实进化星球在以太坊的实现中没有区分Token Name(都叫 EVO Object)

# 理由[WIP]
[rationale-and-alternatives]: #rationale-and-alternatives


# 现有技术
[prior-art]: #prior-art

- https://github.com/evolutionlandorg/common-contracts/blob/master/contracts/InterstellarEncoderV3.sol
- hhttps://github.com/evolutionlandorg/tron-contracts/blob/master/contracts/common/InterstellarEncoderV3.sol

# 问题
[unresolved-questions]: #unresolved-questions

[WIP]


# 未来的可能性
[future-possibilities]: #future-possibilities

因为dGoods的标准目前还是Beta版本，还没有最终确定，因此有可能因为dGoods标准发生变化，导致相关设计发生变更。



# 参考

- [1] [达尔文网络星际资产编码标准RFC](https://github.com/evolutionlandorg/ELIPs/blob/master/rfcs/zh_CN/0007-dawinia-token-staking-model.md)
