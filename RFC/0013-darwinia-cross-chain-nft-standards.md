---
Rfc: 13
Title: 0013-darwinia-cross-chain-nft-standards
Status: Draft
Desc: Darwinia Cross-chain NFT Standards

---

# Cross-chain NFT Standards

## I. Overview

To easily mark an item or an asset, we mark it with a unique identifier, which has different identifiers. Let us take the example of the items in the physical space. In an ideal situation, all the items should be in the same time and space, so that everyone can observe and facilitate the distinction and identification. But the reality is that different items may exist in different time and space, and the observer may not be able to see every item. In the same situation, in the virtual asset world, because there are different books or blockchain networks (referred to as domains), different items can be easily distinguished and located in the same domain because they have different identifiers, but the domain is inside. The observer does not recognize and parse the item ID from the external domain.

At present, many of the existing standards of the pass standard are mainly designed for the identification of intra-domain assets, and the reuse of assets in different domains is not taken into account. As a result, when the non-homogeneous assets are multiplexed, the individual Token ID cannot be To identify a unique asset, you also need to bring a lot of domain information, which is very complicated to implement.

Cross-chain technology can greatly help the exchange to achieve interoperability in a wider blockchain network, but at the same time, it also brings some cognition and usage thresholds to developers and users, including the identifiability of the certificate. The problem.

Because current pass standards, such as ERC20 or ERC721, only record ownership information on a particular chain, it is not considered that the pass may be distributed across two blockchain networks. When the pass is distributed across two blockchain networks, we need a set of identification and resolution systems to help the user and the pass application resolve and query the current pass status. When we give a NFT Token ID, we can't determine which blockchain network it is currently in, and who its owner is, because when the NFT cross-chain transfer, the pass is on one of the blockchain networks. It is active, while others are in an unavailable state, such as a locked state. In the absence of a pass-through resolution system, the out-of-chain operation cannot determine which chain the NFT is active on.

In a cross-chain environment, Token's identification and resolution problems require new solutions and standards to solve. Therefore, we introduce a analytic system based on the cross-chain certification of the pass to solve the positioning and analysis requirements of the cross-chain of the pass. Through the census system and the unique identifier in the domain, we can have the relationship between the certificate and the certificate of different domains. Map them up and identify the same and different between them.

This article will further refine the NFT-related standards and design details based on [RFC-0010 Darwinia Cross-chain NFT Bridge Protocol](./0010-darwinia-cross-chain-nft-bridge-protocol.md).



## II. Standard solution

### A. Target

- Recognizable. NFT in the cross-chain process should ensure that the NFT token id can be traced. Because the token ids of different blockchains are of different types, the contents and types of token ids may change during the process of NFT flowing between different blockchains; even the same NFT crosses from chain A to chain. B. After the chain A is returned to the chain A, the token id on the chain A may also change. The unidentifiable token id directly causes the asset value to be zero. Therefore, unlike the fungible token, maintaining the NFT's identifiability is an important part of the NFT cross-chain security.
- Traceable. Because the token id is constantly changing during the NFT process, understanding the token id of the same NFT on different chains can greatly help to establish more complex logic in the application layer.
- Visit friendly. In view of the need to interact with external wallet/RPC clients, reducing the cost of external access, improving efficiency and friendliness is also an important part of the NFT cross-chain. In [0010-darwinia-cross-chain-nft-bridge-protocol](https://github.com/darwinia-network/rfcs/blob/master/RFC/en_US/0010-darwinia-cross-chain-nft-bridge -protocol.md) In the implementation, as more NFTs flow through the Bridge Core, more information is deposited in the Bridge Core. Therefore, the external wallet/RPC client only needs to request the Bridge Core once, and can obtain the local token id information of the NFT in all chains. Instead of requesting a separate request for each chain.



### B. Terminology

- **GID / Global ID**, which represents the globally unique identifier of the NFT in all chains. Scope of application: global

- **Local ID / Local token id**, indicating the token id of the NFT in different blockchains. Scope: A blockchain



### C. Globally uniquely identifies the GID and Local ID

In view of the NFT cross-chain goal, the scheme will assign a unique global ID to the NFT when it is cross-chained, and retain its local token id on the external chain within the cross-chain bridge to achieve identifiability, traceability, and accessibility. aims.

(For details on the implementation of the Cross-Bridge Bridge Core, see [0010-darwinia-cross-chain-nft-bridge-protocol](https://github.com/darwinia-network/rfcs/blob/master/RFC/en_US/0010 -darwinia-cross-chain-nft-bridge-protocol.md))[1]

In order to standardize the different standard pass identifiers, to provide identification and analysis methods, coordinate and interface with existing standards, and meet the standard requirements of community infrastructure construction. The cross-chain system will assign a global ID (global_id) to each cross-chain pass.

#### GID generation method

As the global identifier of the NFT, the GID needs to be unique. Therefore, different NFTs can allocate a GID by means of self-increment when they are cross-chained.

#### CID-based Local ID Encoding

**Local ID** To ensure its cross-chain identifiability, you need to include three fields:

```python
<chain id><contract id><token id>
```

Different blockchains have different data types and encryption methods, so the local token id is likely to vary greatly from content to type.

Here, we draw on the coding method of CID in IPLD [2]. Since IPLD is used to solve the problem of content addressing on different blockchains, it is also very suitable for solving the index problem of local token id here.

```python
<mbase><version><chain id><data>
```

Explanation:

- **mbase**: encoding, base58, base64 etc.

- **version**: Version information.

- **chain id**: chain id information

- **data**: contains the following two fields

  ```python
  <contract id><token id>
  ```

  The contract id and token id follow the following format:

  ```python
  <hash func><len><value>
  ```

  So the complete data field is as follows:

  ```python
  <hash func><len><contract id content><hash func><len><token id content>
  ```

Through this coding method, the local token id can be clearly addressed, and the number of bytes is saved, which improves the transmission efficiency.

### D. Utlilising Fungible/Non-fungible assets on Polkadot

Based on the existing polkadot internal fungible asset identification and usage scheme [3] extension, we can use the following line of URI format identification to facilitate the access of the wallet / RPC client:

The same NFT asset can be used:

```html
Polkadot://<nft|ft flag>/<Local ID>
```

Can use:

```python
Polkadot://<nft|ft flag>/<Global ID>/<chain ID>
```

To represent.

> where nft|ft flag, 0 means fungible token, 1 means non-fungible token

For example: suppose `z43AaGEvwdfzjrCZ3Sq7DKxdDHrwoaPQDtqF4jfdkNEVTiqGVFW` indicates that the contract on the Ethereum is `0x14a4123da9ad21b2215dc0ab6984ec1e89842c6d`, the NFT with the token id is `0x01`, and its corresponding GID is `42`, then

```python
Polkadot://1/z43AaGEvwdfzjrCZ3Sq7DKxdDHrwoaPQDtqF4jfdkNEVTiqGVFW
```

Said that you can also use:

```python
Polkadot://1/42/eth
```

Said.

These two URIs are addressed to the same NFT. Because Bridge Core already provides a relational topology between GID and Local ID.



### E. Data Request Format

If the wallet/RPC client requests the topology information of the NFT from the Bridge Core, the local ID information of all known chains can be obtained according to the GID:

```html
{
	GID: 42,
	Total: [
		{
			Chain_id: eth,
		  Contract_id: 0x1234,
			Token_id: 0x01
     },
		{
			Chain_id: eos,
			Asset_id: dgoods,
			Token_id: 1.2.3
		},
	  ...
	]
}
```

### F. Resolution System

The pass-through parsing module is a module embedded in the NFT cross-chain protocol for recording and parsing the global status of the current pass in the relay chain on the *Issuing chain* or its connected relay chain, and normalizing it. A way to parse the format to provide pass-through parsing queries and traceability for cross-chain networks.



### G. Ownership Management

[WIP]

Reference will be made to the ERC721 and ERC1155 standards in Ethereum. The ownership management module or contract will use GID directly as the ID of the NFT certificate, and the GID is managed and generated by the UNFO module, which is different from ERC721, because in ERC721, the NFT contract is responsible for managing and generating the Token ID of the NFT. .



### H. Inter-parachain NFT Transfers

[WIP]

Cross-chain transfers between different parallel chains are facilitated by introducing an associated SPREE module. (Refer to the Polkadot related scheme [3] implementation.)

### Reference

[1] https://github.com/darwinia-network/rfcs/blob/master/RFC/en_US/0010-darwinia-cross-chain-nft-bridge-protocol.md

[2] https://ipld.io/

[3] https://hackmd.io/gQKQGf42TeOODid3hM4_1w