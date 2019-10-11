---
Rfc: 11
Title: 0011-using-harberger-tax-to-find-price-for-xclaim-vault-collaterals
Status: Abandoned
Desc: XClaim Based NFT Solution Using Harberger Tax
---

# Using Harberger Tax to find price for XClaim Vault Collaterals

## Overview
In view of the lack of design of the feed mechanism for NFT in the XClaim framework, this paper proposes to solve the price discovery problem through the mechanism of the Haberg tax model.

## I. XClaim-Based NFT cross-chain protocol

### A. Blockchain model hypothesis

> In order to be compatible with XClaim, the assumptions for chain $B$ and chain $I$ are the same as XClaim, and do not make more assumptions.

Basic assumptions:

- *backing blockchain*, only the blockchain of the basic ledger function. For the NFT cross-chain, the only added assumption is that *chain $B$* native token supports NFT;

- *Issuing blockchain* , a blockchain that supports Turing's complete smart contracts;

Here we construct a cross-chain scenario:

Alice has $nft_b^n$ on *chain $B$*, and Dave has enough $i$ on chain $I$.  

1. Alice wants to issue a new NFT for $nft_b$ on chain $I$, ie $nft_i^{n'}$
2. After Alice has $nft_i^{n'}$, she wants to transfer it to Bob on chain $I$
3. Or at a later moment, Bob wants to redeem the asset from chain $I$ back to chain $B$ and get $nft_b^n$ again. 

In order to achieve the above scenario, the XClaim-based NFT cross-chain protocol needs to implement three protocols: *Issue, Trasnfer, Redeem*. To simplify the model, we omit the details of the relevant part of the fee here.



### B. Research basis

If the XClaim scheme is used as the basic scheme of cross-chain, then on this basis, only the pricing problem of the NFT needs to be solved, and the economic security of the system can be solved.

For the pricing problem of NFT, the solution given by the current centralized and decentralized transactions is handed over to the market. According to the dapp data statistics website, the number one daily user of the first NFT exchange Opensea [8] is only 42, the number of daily transactions is 73. Even if the same price scheme as XClaim is adopted, Oracle, in front of such a market, The price obtained is also difficult to represent.

Moreover, given the irreplaceability of NFT, there are also natural paradoxes in the method of market pricing. That is, the success of the sale can be priced; but the success of the sale also means the transfer of the owner.

At present, there is no solution for the pricing of NFT.



#### BI. What is Harberger Taxes

Markets and private property are two topics that are usually talked about together. It is hard to imagine in today's society. If you only talk about one of them alone, you don't mention another. However, in the nineteenth century, many European economists were also liberals and equal advocates. It was normal to embrace the market while being skeptical about private property.

Thus, it is entirely feasible to implement a system that includes the market but has no ownership: at the end of each year, the price of the item is collected, and at the beginning of the second year, the item belongs to a higher bidder. Although such a system is not feasible in reality, it has a significant advantage: to achieve configuration efficiency. Every year, every item belongs to someone who can get the most value from it (and therefore is willing to pay a higher price).

Eric Posner and Glen Weyl, authors of "radical market" proposed a scheme Harberger Taxes [9]: 1. Everyone evaluates a price for their property 2. Everyone pays a tax on a percentage of the assessed price, for example 2% 3. Others can buy their property at any time at a price not less than the estimated price. This forces everyone to evaluate the price of the item fairly and objectively. If the assessment is too high, they will have to pay more taxes. If the assessment is too low, others can get the consumer surplus.



#### B-II. Harberger Taxes in cross-chain applications

We propose to apply Harberger Taxes to the pricing of NFT. Rather than handing pricing issues to time and market, we propose to hand over pricing issues to the cross-chain initiators themselves.

Since the cross-chain does not require transactions involving the NFT, we only apply the part of the seller's valuation and tax payment of Harberger Taxes, and do not apply the part of the mandatory transaction.

The general idea is that a cross-chain initiator declares a price of $p$ for NFT $nft_b$ on chain $B$ that needs to be cross-linked, and pays a cross-chain fee at a certain percentage of the price; correspondingly, $ Vault$ needs to provide a value/value of $p$ for $p$ on chain $I$ at the price of $I$. If the cross-chain operation is completed correctly, the cross-chain fee will be paid to the corresponding $vault$; In the presence of malicious behavior that causes a cross-chain failure and a misdirect of the owner of $nft_b$, the mortgaged $i$ will be used to compensate for the loss of the cross-chain initiator.



### C. Component Definition

Here we will partially follow XClaim's declaration to maintain continuity:

- *Issuing blockchain*, the blockchain $I$, the new NFT distribution chain after the chain
- *backing blockchain*, the blockchain $B$, the chain where the NFT is in front of the chain
- *NFT identifier*, $nft_b^{n}$, representing the native NFT identified as $n$ on chain $B$, appearing in Chapter II
- *NFT identifier*, $nft_i^{n'}$, which represents the NFT that was newly added to the chain $I$ after the chain, and is identified as $n$, which appears in Chapter II.
- *native token on chain $I$*: $i$
- Mortgage token, $i\_col$ , indicating the token mortgaged on chain $I$

System participants:

- **Requester** : Lock $nft_b^n$ on chain $B$ and hope to get a new release of $nft_i^{n'}$ on $I$;
- **Sender**: has $nft_i^{n'}$ on $I$ and can transfer its ownership to others;
- **Receiver**: A person who accepts and obtains ownership of $nft_i^{n'}$ at $I$;
- **Redeemer**: Destroy $nft_i^{n'}$ on $I$ and then release $nft_b^n$ on $B$;
- **vault**: Third parties that do not need to trust, ensuring the economic security of the entire system with *Issue* and *Redeem*;
- **Issuing Smart Contract (iSC)**: A smart contract that is fully public on $I$ and is responsible for managing the $vault$ list and is responsible for issuing NFT assets $nft_i$
- **backing Smart Contract(bSC)**: A smart contract that is fully open on $B$ and is responsible for managing the frozen NFT asset $nft_b$ (appears in Chapter III)

Among them, *Requester, redeemer, vault* must have corresponding public and private keys on *chain $I$ and chain $B$*; *Sender, Receiver* only need to hold public and private keys on $I$; *iSC * is a fully open, auditable smart contract on $I$; *bSC* is an auditable smart contract that is fully public on $B$.

### D. Preliminary implementation plan

#### Protocol: Issue

> Alice (requester) locks $nft_b^n$ on $B$ at $vault$ in order to create $nft_i^{n'}$ on $I$.

(i) *** Prepare ***. Alice pre-declares a price of $p$, confirms that iSC is valid and looks for $vault$ with full/overcollateral ($i\_col$) in iSC.

(ii) ***Lock ***. Alice transfers $nft_b^n$ to $vault$ and declares her address on $I$; and pays a cross-chain fee;

(iii) *** issuance ***. $vault$ sends a signed message to iSC: agrees to issue new assets to Alice's address on $I$, iSC issues $nft_i^{n'}$ at Alice's address after confirming the signature of $vault$

#### Protocol: Transfer

> Alice (sender) sends $nft_i^{n'}$ to Bob (receiver) in chain $I$ 

(i) *** Transfer ***. Alice puts $nft_i^{n'}$ on $I$ in iSC, transferring ownership to Bob, referring to ERC721.

(ii) *** Witness ***. When the ownership of $nft_i^{n'}$ in iSC has shifted, the corresponding $vault$ should be able to witness. At this point, when Alice wants to redeem $nft_i^{n'}$ again, $vault$ should be banned after iSC found that the ownership of $nft_i^{n'}$ has been transferred to Bob.

It should be added that during the series of operations, the price of $nft_i^{n'}$ may fluctuate, and the current owner of the NFT can declare a new price for it at any time. Accordingly, $vault$ needs to satisfy the pledge. .

#### Protocol: Redeem

> Bob wants to redeem $nft_i^{n'}$ from $I$ to $B$, Bob needs to lock $nft_i^{n'}$ in iSC, so $vault$ is at $B$ The $nft_b^n$ will be released to Bob. Then $nft_i^{n'}$ will be destroyed in $I$.

(i) *** Prepare ***. Bob needs to create an address on $B$ now, holding the corresponding private key.

(ii) ***Lock ***. Bob locks $nft_i^{n'}$ on the iSC on $I$ and initiates a redemption request containing the address of Bob on $B$. Also, $vault$ should be aware of this process.

(iii) *** release ***. $vault$ can verify the lock operation and redemption request in iSC, then send the corresponding $nft_b^n$ to Bob's address on $B$.

(iv) *** Destroy ***. $vault$ submits a proof of release on $B$ to iSC, iSC automatically destroys $nft_i^{n'}$ after verifying proof and allows $vault$ to unfreeze the corresponding $i\_col$



![image-20190918160246144](https://tva1.sinaimg.cn/large/006y8mN6gy1g74nx78muuj31940eon04.jpg)

(Image from XClaim, to be modified)

### C. Design Roadmap

In the previous example description, the single $vault$ mode was defaulted. XClaim itself has an extended, more decentralized solution for this model, introducing *multi-vault*, allowing anyone to mortgage $i\_col$ to $vault$, minimizing single point of failure. The impact of the entire system. Therefore, the XClaim-based NFT cross-chain solution naturally supports this extension.

However, due to the irreplaceability of NFT, the valuation of NFT is not continuous and predictable, and there is a high probability of price fluctuations, which affects the security of the system. In order to minimize the impact of NFT price fluctuations on system security, we will introduce a new solution in III, based on a new and reasonable blockchain assumption, without relying on $vault$, ie in the case of *non-vault* Under, to achieve cross-chain security.

1. By inheriting XClaim's extension, first, reduce the trust dependency on $vault$ as much as possible, and even achieve 0 trust dependencies to achieve the robustness of the entire system. Here, we introduce $chain\relay$ (Chapter III) to provide iSC with the block and transaction proof on the chain $B$, which is open to anyone.
2. Throughout the cross-chain process, $vault$ is required to remain involved. To prevent a single point of failure for a single $vault$, here we also take the same approach as XClaim, opening the registration of $vault$, allowing any willing to mortgage Anyone or organization with $i\_col$ can become $vault$.
3. As mentioned above, even if the NFT price can be correctly evaluated, due to the discontinuity of the NFT price and the large fluctuation range, the mortgage of $vault$ may also have a large fluctuation. Therefore, in Section III, we introduced a cross-chain solution without $vault$. This has a higher assumption of the chain $B$ and a higher cost of technical maintenance. However, compared with XClaim, a large amount of mortgage funds have been deposited. However, there is currently no sustainable incentive program in the economy. We believe that the cost of technical maintenance is far less than the time cost of mortgage funds. Worth trying.


# II. Others
[WIP]