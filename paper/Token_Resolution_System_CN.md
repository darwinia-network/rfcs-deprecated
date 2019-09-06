#Token识别和解析系统RFC

##概述
跨链技术可以极大的帮助通证在更广泛的区块链网络中实现互联互通，但是同时，也给开发者和用户带来了一些认知和使用门槛，其中就包括通证可识别性的问题。

当我们给出一个NFT的Token ID时，我们无法确定它目前所在区块链网络是哪个，其所有者是谁，因为目前的通证标准，例如ERC20或ERC721，只记录的其在某个特定链上的所有权信息，没有考虑到通证有可能会同时存在于两个区块链网络。当通证同时存在于两个区块链网络时，我们需要一套识别和解析系统帮助用户和通证应用来解析和查询当前的通证状态。

跨链环境下，Token面临的识别性问题，需要新的解决方案和标准来解决。Token包括同质Token和非同质Token。

达尔文网络提出一个识别和解析系统，通过引入Token解析合约(脚本)来记录和更新Token的协议、跨链、权利和其他信息。

这样一个识别和解析系统，将对于消除用户在跨链场景下的认知和使用门槛起到非常关键的作用。



##问题

为了方便的标记一个物品或者一个资产，我们会用一个唯一的标识来标记它，不同的物品具有不同的标识。我们先拿物理空间里面的物品举例，在理想情况下，所有的物品都应该在同一个时空里面，这样大家都能观察的到，并且方便做区分和标识。但是现实情况是，不同的物品可能存在于不同的时空里面，并且观察者也不一定能看到每一个物品。同样的情况，在虚拟资产世界，因为存在不同的账本或称区块链网络(简称域)，不同的物品在同一个域里面因为有不同的标识，所以可以区分，但是该域里面的观察者无法识别来自外部域的物品标识。

目前现有的很多通证标准的设计，都主要是针对域内资产进行标识设计，没有将不同域内的资产复用考虑进来，这样导致在对非同质资产进行复用时，单独的Token ID无法标识唯一的资产，还需要带上很多域信息，实现起来十分复杂。

同时，目前通证标准主要的设计是针对所有权信息进行记录，但是并没有对通证的跨链转账，使用权，类型，生产商等信息进行记录，使得通证合约对通证的描述并不全面，也没有提供可扩展的方法来增加其他的信息。

之前的星际资产编码标准解决方案，尝试通过在标识内部嵌入信息的方式，同时解决全局唯一性和跨域扩展等问题，但是由于标识ID的存储空间有限，具备一些缺陷，包括 

1. 编码内容应用专用化，通用性不好

2. 不具备很强的可扩展性，无法引入新的定义和脚本 

3. 对于现有标准的支持和兼容有难度，一定程度上需要通证实现者进行支持，不利于构建适配器和普及标准。

4. 因为每个区块链网络都有自己希望编码进去的信息，所以全局一致性会比较差。

因此我们引入Token识别和解析系统来替代之前的方案，原先的编码方式，由[解析合约地址+Token_Index]代替。


##技术方案


###通证解析合约
通证解析合约是存在于(达尔文)中继链上的一种标准合约，用于记录和解析当前通证在中继链范围内的全局状态，包括跨链历史，各个区块链网路对应的所有权合约地址，其他权利和信息。


[
协议，
跨链信息，
权利(所有权<chain_id, ownership_contract>，使用权)，
信息(类型，生产商)
]

####接入SPREE模块
通过在解析合约内定义约束条件，例如全局的通证总量，发行规则，并部署至SPREE模块，可以实现中继网络管辖范围的验证和可信互操作。


更多关于SPREE模块的介绍，参考 https://wiki.polkadot.network/en/latest/polkadot/learn/spree
[WIP]

####基础设施支持
类似钱包和区块链浏览器这样的基础设施将可以很好的支持跨链通证，通过接入通证解析合约，可以很方便的定位和浏览该通证的全局信息，并进行相关操作。
[WIP]

####XClaim跨链转接桥的集成
对于基于XClaim技术搭建的跨链转接桥，其Token的跨链是通过在对手链上构建超额抵押的对称CBA来实现的。虽然严格意义上讲，CBA不等同于原通证，但是从用户视角看其效果非常接近。

对于这类跨链通证的支持仍有希望通过通证解析合约来描述和解析其跨链转接桥过程，只需跟中继链和平行链模式的跨链通证类型稍作区分，便可帮助开发者和用户理解其跨链通证(CBA)和原有通证的区别。
标准接口
WIP
推荐实现
WIP

###全局唯一标识

To harmonise existing practice in identifier assignment and resolution, to support resources in implementing community standards and to promote the creation of identifier services.

通证解析合约的地址(UINT128)将可以作为该Token在跨链网络中的全局Token标识(Base Token ID)。

对于非同质Token来说，将可以使用解析合约地址加上一个Token内索引(UINT128)得到的编码作为全局唯一标识。



对于同质Token来说，因为没有通证的索引，只有数量的概念，解析合约地址就是全局通证地址。


###链上数据和链下数据
Token相关的数据分为链上和链下两种，其作用和价值不一样，链上数据可以很方便的用于智能合约和交易处理，而链下数据更多的用于描述，表达和引用资源文件。
Onchain Linked Data
[WIP]

####Offchain Metadata and ontology tooling
[WIP]

####Token Schema
To encourage the use of schema.org markup within token web resources to improve discoverability of information. [WIP]


###适配器

对于那些使用已有区块链网路的通证标准实现的通证，可以通过在区块链网路内部实现一个适配器合约，以接入这套识别和解析系统，这个适配器可能是通证跨链转接桥的一个部分。

对于支持跨链消息协议的区块链网路，将可以实现通证跨链消息通信。

对于支持SPREE协议或跨链转接桥的区块链网路，将可以实现通证跨链可信转账和互操作。

下面是一些常见通证标准的适配器参考实现：
####以太坊ERC20适配器
[WIP]
####以太坊ERC721适配器
[WIP]
####以太坊ERC1155适配器
[WIP]
####EOS dGoods适配器
[WIP]
####Cocos BCX NHAS-1808适配器
[WIP]


###SDK和工具集

####Token Service Framework

To identify valuable interoperability services within Polkadot and support their improvement. 

To identify existing services outside Polkadot and develop of strategic partnerships with them.

To identify the interoperability services that need to be developed.
Workflow and Tool interoperability

####Interoperability Knowledge Hub

####Implementation Studies



##参考

https://eprint.iacr.org/2018/643.pdf

https://elixir-europe.org/platforms/interoperability

https://github.com/AlphaWallet/TokenScript

https://github.com/darwinia-network/rfcs/blob/v0.1.0/zh_CN/0005-interstella-asset-encoding.md

https://onlinelibrary.wiley.com/doi/pdf/10.1087/20120404

https://wiki.polkadot.network/en/latest/polkadot/learn/spree/

https://en.wikipedia.org/wiki/Unique_identifier

https://en.wikipedia.org/wiki/Identifiers.org

https://schema.org/

https://medium.com/drep-family/cross-chains-a-bridge-connecting-reputation-value-in-silo-b65729cb9cd9
