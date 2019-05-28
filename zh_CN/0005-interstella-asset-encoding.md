- 功能描述: 星际资产编码标准(IAE)
- 开始时间: 2019-04-28
- RFC PR: None
- Github Issue: None

# 概要
[summary]: #summary

# NFT跨链和星际资产编码标准
为了方便的标记一个物品或者一个资产，我们会用一个唯一的标识来标记它，不同的物品具有不同的标识。我们先拿物理空间里面的物品举例，在理想情况下，所有的物品都应该在同一个时空里面，这样大家都能观察的到，并且方便做区分和标识。但是现实情况是，不同的物品可能存在于不同的时空里面，并且观察者也不一定能看到每一个物品。同样的情况，在虚拟资产世界，因为存在不同的账本或称区块链网络(简称域)，不同的物品在同一个域里面因为有不同的标识，所以可以区分，但是该域里面的观察者无法识别来自外部域的物品标识。目前现有的很多ERC721的区块链应用所做的设计，都主要是针对域内资产进行标识设计，没有将不同域内的资产复用考虑进来，这样导致在对非同质资产进行复用时，单独的Token ID无法标识唯一的资产，还需要带上很多域信息，实现起来十分复杂。为了解决这个问题，进化星球提出了星际编码资产标准，将域信息和跨域信息也编码进Token ID，这样用户拿到经过星际编码后的Token ID，就能识别出广域内(星际范围)的不同物品，并且能达到这个Token ID的很多域信息，包括编码方式，链ID，合约ID，物品类型，所属空间(也称制造商，产地)，物品ID 等等。

通过这种方式，进化星球不但可以很好的管理内部二十六个大陆的资产，而且可以很容易的复用任何外部域的资产，而不会出现识别冲突。

同时，这个标准也是开放的，任何其他的应用也可以通过遵循这个标准达到同样的目的，而没有任何限制。

# 星际资产编码(IAE)标准简介
进化星球中的每一个物品在不同的时空可能存在多个镜像，但是他们仍然是同一个物品(目前仅在所有权意义上, aka. ERC721 standard)，同一个物品在不同时空的存在不同的token id (简称token)，在进化星球时空中存在的token id遵循星际物品编码标准。

进化星球中的Object和Token是两个概念，Object是原生Token和其生成的其他镜像Token的总称。(Object也称Item，后期可能会做区分，即一个Item可以有多个同质Object，但是在任意时空中共享同一个token id)


IOE Token ID编码的方式与传统的ERC721 Token ID编码兼容，也是uint256大小。分成了左右两个部分，左边的uint128用来记录域信息，右边的uint128用来在域内对物品进行标识和区分。



# 动机和目的
[motivation]: #motivation

- 跨链NFT。
- 全局唯一标识 [WIP]
- NFT标识反身性


# Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

- [ERC721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)
- [EIP1155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md)
- [ERC721.ORG](http://erc721.org/)



# 参考和实现
[reference-level-explanation]: #reference-level-explanation

下面分别是左边uint128部分的编码规则，和右边部分的编码规则，及其详细解释。

## 概览

| `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `9` | `10` | `11` | `12` | `13` | `14` | `15` | `16` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|       `<uint128: Base Type of Item>`                                                                |


| `17` | `18` | `19` | `20` | `21` | `22` | `23` | `24` | `25` | `26` | `27` | `28` | `29` | `30` | `31` | `32` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|       `Customized NFT Object Token Index Inside Contract(e.g. auto increasing)`                                                                |


## 每个标识的详细解释

| 序号     | 标识                                                                 | 描述                                   |
| ---------| --------------------------------------------------------------------|-------------------------------------------|
| 1        | Magic Number                                                        |用来标记文件或者协议的格式，Evolution Land的Magic Number是「42」，其余均为进化星球外部的Token|
| 2        | Chain ID                                                            |Token当前所在链的ID(参见 Chain ID 章节）|
| 3        | Reserved                                                            |保留位；用于扩展OwnerShip Contract ID等|
| 4        | Ownership Contract ID                                               |Token当前所有权控制合约的ID|
| 5        | Last Chain ID                                                       |Token镜像前“原Token”所在链的ID.|
| 6        | Reserved                                                            |保留位；用于扩展 Last Ownership Contract ID等|
| 7        | Last Contract ID                                                    |Token镜像前“原Token”的所有权控制合约的ID|
| 8        | Object Class ID                                                      |Token代表的Object的类型 (如：地块，使徒，宠物等等)|
| 9        | TokenIDConvertType                                                  |Token Convert用于进化星球外部的NFT镜像到进化星球上时，对应的Token ID相互转化方式；Token ID Convert Type用于定义Convert 合约相互转化。外部映射过来的物品Token ID Convert Type != 0。(进化星球内部的物品，Token ID Convert Type 设置为 0，此时Token Covert MetaData位置可以用作其他用途。当Token ID在进化星球内部做跨链转移的时候，(Chain ID, Contract ID)字段变化就行，其他字段不需要变化。)|
| 10-14    | Token ID Convert MetaData(Repeat Byte, start1, end1, start2, end2, EOF) | Toke Convert(适配器合约ID)相关的帮助转换的参数和元信息。 (未被分配时，可用做其他用途，例如染色、或者附带信息)|
| 15-16    | Space/Producer                   |出产地、制造商信息.  (进化星球内部26各大陆生产的物品分别为1-26，外部的物品（如加密猫）将被分配其他的属地信息)|
| 17-32    | Customized NFT Object Token Index Inside Contract(e.g. auto increasing) |右边的uint128表示当前链和合约的部分索引，ConvertType(Item_index, convert_meta_data) 可以计算出在原来链<last_chain, last_contract_id>上的部分索引(进化星球外部的可以计算出完全索引)，跨链协议借此实现跨链转移.     Convert(last_token_id, convert_type, convert_metadata)  <==> Index_of(token_id)  [Convert合约可能需要设计成双向的，即拿到token_id，可以生成last token_id]|

## Chain ID

| `KEY`     | Network                                  |
| ----------| -----------------------------------------|
| 0              | NAN                                 |
| 1              | Ethereum mainet                     |
| 2              | TRON mainet                         |
| 3              | EOS mainet                         |

## Contract ID

| `Chain Id`     | Chain Name                          | Contract Id      | Contract Name      | Contract Address      |
| ----------| -----------------------------------------| -----------------| -------------------| ----------------------|
| 0              | NAN                                 |                  |                    |                       |
| 1              | Ethereum mainet                     |                  |                    |                       |
|                |                                     | 0                | NaN                |                       |
|                |                                     | 1                | ObjectOwnership    |                       |
|                |                                     | 2                | Cryptokittie       |                       |
|                |                                     | 3                | Itering NFT        |                       |
| 2              | TRON mainet                         |                  |                    |                       |
|                |                                     | 0                | NaN                |                       |
|                |                                     | 1                | ObjectOwnership    |                       |
| 3              | EOS mainet                         |                  |                    |                       |
|                |                                     | 0                | NaN                |                       |
|                |                                     | 1                | dGoods(and symbol config)|                       |

## Object Class

| `Key     `     | Value(String)                       | Contract Name      | Contract Address      |
| ---------------| ------------------------------------|--------------------| ----------------------|
| 0              | NAN                                 |                    |                       |
| 1              | 地块                                | LandBase           |                       |                    
| 2              | 使徒                                | ApostleBase        |                       |                       
|                | 宠物                                |                   |                        |                       
| ...            |                                     |                   |                        |                       
|                |                                     |                   |                       |                       
| 255            | Unknown                             | UnknownNFT        |                       |                       
|                |                                     |                   |                       |                       
|                |                                     |                   |                       |                   

## Producer ID
| `Land Id`     | 属地、出生地、制造商                        | 链                 | 合约                | 其他      |
| --------------| -----------------------------------------| -------------------| -------------------| ----------------------|
| 0              | NAN                                     | NaN                | NaN                | NaN                   |
| 1              | Atlantis                                | Ethereum           |                    |                       |
| 2              | Byzantine                               | Tron               | NaN                |                       |
| 2              | TBD                                     | EOS                | NaN                |                       |
| ...            |                                         |                    | ObjectOwnership    |                       |
| 26             |                                         |                    | Cryptokittie       |                       |
| ...            |                                         |                    | Itering NFT        |                       |
| 255            |                                         |                    |                    |                       |
| 256            | 加密猫                                   | CryptoKitties      | NaN                | 外部导                |
| 257            | Itering                                 | Ethereum           | IteringNFT         | Unknown(nft.itering.com Free)     |

Note: Producer = (company, origin_chain_id, origin_contract_id)

## Right Index Convert Type

| `Convert Type(Byte)`     | Convert MetaData                       | Description                             | 案例                   |
| ---------------| -------------------------------------------------|-----------------------------------------| ----------------------|
| 0              | f(x) = x，前面不变                   |  original_contract_id == contract_id（目前只用到这个）  |   进化星球大陆        |
| 1              | f(x) = x, 前面只修改<Chain ID,Contract ID, Convert Type> | 进化星球内部跨链到另外一个大陆的资产(跨链1次)           |     A大陆出生的生物角色，跑到B大陆                  |                    
| 2              | f(x) = x, 前面只修改<Chain ID,Contract ID, Origin Chain ID, Origin Contract ID, ConvertTD>                                | 进化星球内部跨链到另外一个大陆的资产(跨链2次)，新的Origin Chain ID, Origin Contract ID存放在Metadata        |                       |                       
|                |                                     |                   |                        |                       
| ...            |                                     |                   |                        |                       
|                |                                     |                   |                       |                       
| 128            | original_contract_id 不在Contract注册表，属于星球外部资产，且原来的编码左边uint18一直为0         | 加密猫映射资产        |                       |                       
|                |                                     |                   |                       |                       
|                |                                     |                   |                       |  

# 缺点
[drawbacks]: #drawbacks

[WIP]

# 理由
[rationale-and-alternatives]: #rationale-and-alternatives

- 方便NFT的跨链
- 全局唯一的NFT标志位
- 提供NFT ID自带的反身性，即可以通过NFT ID获取所在链、合约、类型、生产商等信息。

# 现有技术
[prior-art]: #prior-art

[Solidity InterstellarEncoder](https://github.com/evolutionlandorg/common-contracts/blob/master/contracts/InterstellarEncoderV3.sol)

# 问题
[unresolved-questions]: #unresolved-questions

[WIP]


# 未来的可能性
[future-possibilities]: #future-possibilities

[TODO] 在达尔文网络上实现NFT跨链
[WIP]


# 参考

- [1] [NFT与星际编码标准](https://mp.weixin.qq.com/s/_ynNgx1mmFTxOU322It_9A)
